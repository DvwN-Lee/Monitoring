#!/usr/bin/env bash
set -euo pipefail

# Defaults
NAMESPACE="titanium-local"
SERVICE="local-load-balancer-service"
PATH_PREFIX="/api/posts"
RATE="100"          # RPS (vegeta/hey 기준)
DURATION="30s"      # 총 테스트 시간
CONCURRENCY="20"    # 동시 접속 (hey/curl 폴백에서 사용)
URL=""              # 미지정 시 minikube service로 추론
MODE="auto"         # auto|vegeta|hey|curl
WARMUP="true"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --url URL             Base URL (e.g., http://127.0.0.1:30700)
  --namespace NS        K8s namespace (default: ${NAMESPACE})
  --service NAME        LB service name (default: ${SERVICE})
  --path PATH           API path (default: ${PATH_PREFIX})
  --rate RPS            Requests per second (default: ${RATE})
  --duration DUR        Test duration, e.g., 30s, 2m (default: ${DURATION})
  --concurrency N       Concurrency for hey/curl (default: ${CONCURRENCY})
  --mode M              auto|vegeta|hey|curl (default: ${MODE})
  --no-warmup           Skip warmup requests
  -h, --help            Show help
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) URL="$2"; shift 2;;
    --namespace) NAMESPACE="$2"; shift 2;;
    --service) SERVICE="$2"; shift 2;;
    --path) PATH_PREFIX="$2"; shift 2;;
    --rate) RATE="$2"; shift 2;;
    --duration) DURATION="$2"; shift 2;;
    --concurrency) CONCURRENCY="$2"; shift 2;;
    --mode) MODE="$2"; shift 2;;
    --no-warmup) WARMUP="false"; shift ;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown option: $1"; usage; exit 1;;
  esac
done

# Infer URL via minikube if empty
if [[ -z "${URL}" ]]; then
  if command -v minikube >/dev/null 2>&1; then
    echo "Deriving URL via minikube service..."
    URL="$(minikube service "${SERVICE}" -n "${NAMESPACE}" --url | head -n1)"
  else
    echo "ERROR: --url not provided and minikube not found." >&2
    exit 1
  fi
fi

TARGET="${URL%/}${PATH_PREFIX}"

echo "==== Load Test Config ===="
echo "URL        : ${URL}"
echo "Target     : ${TARGET}"
echo "Namespace  : ${NAMESPACE}"
echo "Service    : ${SERVICE}"
echo "Rate       : ${RATE} rps"
echo "Duration   : ${DURATION}"
echo "Concurrency: ${CONCURRENCY}"
echo "Mode       : ${MODE}"
echo "Warmup     : ${WARMUP}"
echo "=========================="

# Quick health check
set +e
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${TARGET}")
set -e
if [[ "${HTTP_CODE}" != "200" ]]; then
  echo "WARN: Initial GET ${TARGET} returned HTTP ${HTTP_CODE} (continuing)..."
fi

# Show LB stats before
echo "[BEFORE] LB /stats:"
curl -s "${URL%/}/stats" | jq . 2>/dev/null || curl -s "${URL%/}/stats" || true

# Optional warmup
if [[ "${WARMUP}" == "true" ]]; then
  echo "Warming up target..."
  for _ in $(seq 1 10); do
    curl -s -o /dev/null "${TARGET}" || true
  done
fi

run_with_vegeta() {
  echo "Running vegeta: rate=${RATE}, duration=${DURATION}"
  echo "GET ${TARGET}" | vegeta attack -rate="${RATE}" -duration="${DURATION}" \
    -connections="${CONCURRENCY}" | tee /tmp/vegeta.bin | vegeta report
}

run_with_hey() {
  echo "Running hey: qps=${RATE}, duration=${DURATION}, concurrency=${CONCURRENCY}"
  hey -z "${DURATION}" -q "${RATE}" -c "${CONCURRENCY}" "${TARGET}"
}

run_with_curl_fallback() {
  echo "Running curl fallback: best-effort ${CONCURRENCY} workers for ${DURATION}"
  # Convert duration to seconds (support s/m suffix)
  dur_s="${DURATION}"
  if [[ "${DURATION}" =~ ^([0-9]+)s$ ]]; then dur_s="${BASH_REMATCH[1]}";
  elif [[ "${DURATION}" =~ ^([0-9]+)m$ ]]; then dur_s="$(( ${BASH_REMATCH[1]} * 60 ))";
  fi
  end=$(( $(date +%s) + dur_s ))
  worker() {
    while [[ $(date +%s) -lt ${end} ]]; do
      curl -s -o /dev/null "${TARGET}" || true
    done
  }
  for _ in $(seq 1 "${CONCURRENCY}"); do worker & done
  wait
  echo "curl fallback finished."
}

# Choose mode
if [[ "${MODE}" == "auto" ]]; then
  if command -v vegeta >/dev/null 2>&1; then MODE="vegeta";
  elif command -v hey >/dev/null 2>&1; then MODE="hey";
  else MODE="curl"; fi
fi

case "${MODE}" in
  vegeta) command -v vegeta >/dev/null 2>&1 || { echo "vegeta not found"; exit 1; }; run_with_vegeta;;
  hey)    command -v hey    >/dev/null 2>&1 || { echo "hey not found"; exit 1; };    run_with_hey;;
  curl)   run_with_curl_fallback;;
  *)      echo "Unknown mode: ${MODE}"; exit 1;;
esac

# Show LB stats after
echo "[AFTER] LB /stats:"
curl -s "${URL%/}/stats" | jq . 2>/dev/null || curl -s "${URL%/}/stats" || true

echo "Done."
