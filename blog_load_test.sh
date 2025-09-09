#!/bin/sh
set -eu

# Minimal, unified interface load test script
# Usage:
#   sh ./blog_load_test.sh --url http://127.0.0.1:63990 --rate 80 --duration 60s

# Defaults
URL=""
RATE="80"         # requests per second
DURATION="60s"    # e.g., 60s, 2m
CONCURRENCY="20"  # for hey/curl fallback
PATH_PREFIX="/api/posts"  # assume blog path (avoids 308 redirect)
MODE="auto"       # auto|vegeta|hey|curl

usage() {
  echo "Usage: sh ./blog_load_test.sh --url <BASE_URL> --rate <RPS> --duration <SECONDS|Xm|Xs> [--concurrency N] [--mode auto|vegeta|hey|curl]";
}

# Parse args (minimal required: url, rate, duration)
while [ $# -gt 0 ]; do
  case "$1" in
    --url) URL="$2"; shift 2 ;;
    --rate) RATE="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --concurrency) CONCURRENCY="$2"; shift 2 ;;
    --mode) MODE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [ -z "$URL" ]; then
  echo "ERROR: --url is required" >&2
  usage
  exit 1
fi

TARGET="${URL%/}${PATH_PREFIX}"

echo "==== Load Test Config ===="
echo "URL        : ${URL}"
echo "Target     : ${TARGET}"
echo "Rate       : ${RATE} rps"
echo "Duration   : ${DURATION}"
echo "Concurrency: ${CONCURRENCY}"
echo "Mode       : ${MODE}"
echo "=========================="

# Quick health check (non-fatal)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${TARGET}" || echo 000)
if [ "$HTTP_CODE" != "200" ]; then
  echo "WARN: Initial GET ${TARGET} returned HTTP ${HTTP_CODE} (continuing)..."
fi

echo "[BEFORE] LB /stats:"
curl -s "${URL%/}/stats" | jq . 2>/dev/null || curl -s "${URL%/}/stats" || true

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
  dur_s="$DURATION"
  case "$DURATION" in
    *s) dur_s="${DURATION%?}" ;;
    *m) mins="${DURATION%?}"; dur_s=$(( mins * 60 )) ;;
    *) : ;; # assume seconds already
  esac
  end=$(( $(date +%s) + dur_s ))
  worker() {
    while [ $(date +%s) -lt "$end" ]; do
      curl -s -o /dev/null "${TARGET}" || true
    done
  }
  i=1
  while [ "$i" -le "$CONCURRENCY" ]; do
    worker &
    i=$(( i + 1 ))
  done
  wait
  echo "curl fallback finished."
}

if [ "$MODE" = "auto" ]; then
  if command -v vegeta >/dev/null 2>&1; then MODE="vegeta";
  elif command -v hey >/dev/null 2>&1; then MODE="hey";
  else MODE="curl"; fi
fi

case "$MODE" in
  vegeta)
    command -v vegeta >/dev/null 2>&1 || { echo "vegeta not found"; exit 1; }
    run_with_vegeta
    ;;
  hey)
    command -v hey >/dev/null 2>&1 || { echo "hey not found"; exit 1; }
    run_with_hey
    ;;
  curl)
    run_with_curl_fallback
    ;;
  *) echo "Unknown mode: $MODE"; exit 1 ;;
esac

# Show LB stats after
echo "[AFTER] LB /stats:"
curl -s "${URL%/}/stats" | jq . 2>/dev/null || curl -s "${URL%/}/stats" || true

echo "Done."
