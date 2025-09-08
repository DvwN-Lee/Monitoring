# Monitoring

마이크로서비스 기반의 쿠버네티스 모니터링 대시보드 프로젝트입니다. 각 서비스는 독립적으로 컨테이너화되어 있으며 로드밸런서를 통해 트래픽이 분배되고, 대시보드를 통해 실시간 상태를 확인할 수 있습니다.

## 프로젝트 구조

```
.
├── api-gateway      # Go 기반 API 게이트웨이
├── auth-service     # 사용자 인증 서비스 (FastAPI)
├── blog-service     # 블로그 예제 서비스 (FastAPI)
├── user-service     # 사용자 관리 서비스 (FastAPI + Redis)
├── load-balancer    # Go 로드밸런서 및 통계 수집기
├── dashboard-ui     # Chart.js 기반 모니터링 대시보드
├── k8s-manifests    # Kustomize 기반 쿠버네티스 매니페스트
├── docker-compose.yml
└── skaffold.yaml
```

## 서비스 개요

- **Load Balancer**: 각 서비스와 UI로의 요청을 프록시하고 `/stats` 엔드포인트에서 전체 지표를 집계합니다.
- **API Gateway**: `/api/*` 경로를 내부 서비스로 라우팅하여 인증, 사용자, 블로그 API를 단일 진입점으로 제공합니다.
- **User Service**: 사용자 등록·조회·인증 및 DB/캐시 상태를 반환하는 `/stats` 엔드포인트를 제공합니다.
- **Auth Service**: 로그인과 JWT 토큰 검증 기능을 제공하며 `/stats` 로 간단한 상태 정보를 반환합니다.
- **Blog Service**: 게시물 조회·등록 API와 샘플 SPA 페이지를 포함하는 예제 서비스입니다.

## 비기능 요구사항 (요약)

- **성능 목표**: 안정적 처리량 100 RPS.
- **확장성(기본 복제 수)**: 고가용성 확보를 위해 서비스 기본 2 Pod(상태 저장/인프라형은 1). 예) `api-gateway` 2, `load-balancer` 2, `auth-service` 2, `user-service` 2, `dashboard-ui` 2, `redis` 1, `blog-service` 1.
- **안정성(Timeouts)**: 서비스 간 호출에 짧은 타임아웃을 적용하여 장애 전파를 차단.

## 안정성 설계 (Timeouts)

- **Load Balancer → 각 서비스 `/stats` 호출**:
  - **HTTP 클라이언트 타임아웃**: `2s` 적용
  - 코드: `load-balancer/main.go`의 `/stats` 핸들러 내 `http.Client{ Timeout: 2 * time.Second }`
  - 개별 서비스 호출: 완전한 URL(`.../stats`)을 사용해 고루틴 병렬 수집
- **API Gateway → 내부 서비스 프록시**:
  - **Transport 타임아웃**: `ResponseHeaderTimeout=2s`, `IdleConnTimeout=30s`, `ExpectContinueTimeout=1s`
  - **Server 타임아웃**: `ReadHeaderTimeout=2s`, `WriteTimeout=10s`, `IdleTimeout=60s`
  - 코드: `api-gateway/main.go`의 `httputil.ReverseProxy.Transport` 및 `http.Server` 설정

## 대시보드 하트비트 (WebSocket)

- **엔드포인트**: `ws(s)://<LB>/api/ws-heartbeat` (gorilla/websocket)
- **역할**: 연결이 유지되는 동안 주기적 ping/pong 및 메시지로 “실제 활동”을 LB가 감지하여 IDLE 상태를 방지
- **대시보드 토글**: `index.html`의 `#toggle-ws-heartbeat-btn` 버튼으로 ON/OFF 제어
  - ON: 클라이언트가 5초마다 `"hb"` 메시지를 전송, 끊기면 2초 후 자동 재연결
  - OFF: 연결 종료 및 전송 중단
- **HTTP 하트비트**: 기본 비활성화. 필요 시 `script.js`의 `config.heartbeat`로 GET `/api/health`를 사용할 수 있음

## 트래픽 집계 기준 (IDLE 관련)

- **집계 기준**: LB 미들웨어는 `/api/*` 경로의 요청만 “실제 API 트래픽”으로 집계하며, `HEAD` 요청과 `X-Heartbeat: true`는 제외
- **IDLE 판단**: 최근 10초간 실제 API 트래픽(또는 WS 활동)이 없으면 `has_real_traffic=false`로 보고, 대시보드가 IDLE을 표기
- **해결 방법**: 실제 API 호출 또는 WS 하트비트(권장)를 활성화하면 IDLE이 해제되고 지표가 업데이트됨

## 부하 테스트 가이드 (예시)

- **목표**: 100 RPS 유지 시 에러율과 지연이 목표 수준 이내인지 확인
- **예시 도구**: `vegeta`, `hey`
  - hey 예시: `hey -z 30s -q 100 http://<LB_HOST>:7100/api/health`
  - vegeta 예시: `echo "GET http://<LB_HOST>:7100/api/health" | vegeta attack -duration=30s -rate=100 | vegeta report`
- **Dashboard UI**: Chart.js와 바닐라 JS로 구현된 대시보드로, 각 서비스의 `/stats` 를 주기적으로 호출하여 상태와 지표를 시각화합니다.

## 로컬 실행

### Docker Compose

```bash
docker-compose up --build
```

- 로드밸런서: <http://localhost:7100>
- 대시보드: <http://localhost:7100>
- API 게이트웨이: <http://localhost:7100/api/>

### Kubernetes (Skaffold)

아래 단계대로 실행하면 로컬 클러스터에서 대시보드를 확인할 수 있습니다.

1) 전제 조건 설치
- Docker, kubectl, Skaffold
- 로컬 K8s 클러스터(택1): minikube 또는 kind

2) 클러스터 준비
- minikube 사용 시
  ```bash
  minikube start
  # skaffold가 빌드한 이미지를 바로 사용하도록 로컬 Docker 데몬 연결
  eval "$(minikube -p minikube docker-env)"
  ```
- kind 사용 시 (최초 1회)
  ```bash
  kind create cluster
  # skaffold가 빌드 이미지를 kind 노드에 자동 로드하도록 설정
  skaffold config set --global local-cluster true
  ```

3) 배포 실행 (프로젝트 루트에서)
```bash
skaffold dev
```
빌드 완료 후 `titanium-local` 네임스페이스로 리소스가 배포됩니다.

4) 상태 확인
```bash
kubectl -n titanium-local get pods,svc
```

5) 브라우저 접속
- minikube:
  ```bash
  minikube service local-load-balancer-service -n titanium-local --url
  ```
  출력된 URL을 브라우저로 열기 (예: http://127.0.0.1:30700)
- kind/그 외:
  ```bash
  kubectl -n titanium-local port-forward svc/local-load-balancer-service 7100:7100
  ```
  브라우저에서 http://localhost:7100 접속

6) 동작 확인
```bash
curl -s http://localhost:7100/stats | jq .   # 집계 지표
```

7) 종료/정리
```bash
# skaffold 개발 모드 중지
Ctrl + C
# 배포 리소스 정리
skaffold delete
```

## 의존성

- Docker / Docker Compose
- kubectl, Skaffold, Kustomize
- Go 1.22+, Python 3.10+
