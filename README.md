# K8s Microservice Monitoring Platform
<p align="center"><img width="500" alt="dashboard" src="https://github.com/user-attachments/assets/9a7b890b-1d7c-4c96-826f-e019df475dfb" /></p>

Go + FastAPI 마이크로서비스 기반 쿠버네티스 모니터링 플랫폼으로, 실시간 지표 수집과 대시보드를 제공합니다.

**키워드**: `Go` | `FastAPI` | `Kubernetes` | `WebSocket` | `Docker`

## 이 프로젝트가 보여주는 것

| 역량 | 증거 |
|---|---|
| 마이크로서비스 설계 | Go (API Gateway, Load Balancer) + FastAPI (Auth, User, Blog) 6개 서비스 |
| K8s 배포 및 운영 | Kustomize base/overlay, Skaffold, CronJob 백업, 네임스페이스 분리 |
| 실시간 모니터링 | `/stats` 병렬 수집 (goroutine), Chart.js 대시보드, WebSocket 하트비트 |

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
├── load-tests       # 부하 테스트 셸 스크립트
├── docker-compose.yml
└── skaffold.yaml
```

## 아키텍처 개요

| 서비스 | 기술 | 역할 | 상세 |
|---|---|---|---|
| **Load Balancer** | Go | 요청 프록시 + `/stats` 집계 | [README](load-balancer/README.md) |
| **API Gateway** | Go | `/api/*` 라우팅, 리버스 프록시 | [README](api-gateway/README.md) |
| **User Service** | FastAPI + Redis | 사용자 CRUD, Cache-Aside 패턴 | [README](user-service/README.md) |
| **Auth Service** | FastAPI | JWT 발급/검증 | [README](auth-service/README.md) |
| **Blog Service** | FastAPI | 게시물 CRUD + SPA | [README](blog-service/README.md) |
| **Dashboard UI** | Chart.js | 실시간 모니터링 대시보드 | [README](dashboard-ui/README.md) |

**서비스 간 통신**:
- 외부 → Load Balancer(:7100) → API Gateway(:8000) → auth/user/blog 서비스
- auth-service → user-service (credential 검증 위임)
- blog-service → auth-service (JWT 검증 위임)
- user-service → Redis (캐시) + SQLite (저장)

## 주요 설계 결정

- **성능 목표**: 100 RPS 안정 처리. 서비스 기본 2 Pod (상태 저장형은 1)
- **타임아웃 격리**: LB→서비스 `2s`, Gateway Transport `2s` — 느린 서비스가 전체에 영향 주지 않도록 백프레셔 적용. 상세: [api-gateway/README.md](api-gateway/README.md), [load-balancer/README.md](load-balancer/README.md)
- **WebSocket 하트비트**: HTTP 하트비트가 측정 제외 정책과 충돌하여 WS 채택. 5초 ping, IDLE 상태 감지. 상세: [dashboard-ui/README.md](dashboard-ui/README.md)
- **트래픽 집계**: `/api/*` 실트래픽만 집계, HEAD/하트비트 제외. 10초 슬라이딩 윈도우 RPS 계산. 상세: [load-balancer/README.md](load-balancer/README.md)

## 실행 방법

### Docker Compose

```bash
docker-compose up --build
```

- 대시보드 + API: <http://localhost:7100>

### Kubernetes (Skaffold)

**전제 조건**: Docker, kubectl, Skaffold, minikube 또는 kind

```bash
# 클러스터 준비 (minikube)
minikube start
eval "$(minikube -p minikube docker-env)"

# 배포
skaffold dev

# 상태 확인
kubectl -n titanium-local get pods,svc

# 접속
minikube service local-load-balancer-service -n titanium-local --url

# 집계 지표 확인
curl -s http://localhost:7100/stats | jq .

# 종료
Ctrl + C && skaffold delete
```

### 의존성

- Docker / Docker Compose
- kubectl, Skaffold, Kustomize
- Go 1.24+, Python 3.10+

## 부하 테스트

```sh
cd load-tests
sh ./mixed_load.sh --url http://127.0.0.1:30700 --duration 60s --rate-list 64 --rate-detail 12 --rate-create 4
```

CRUD 전체 + 정리 등 상세 시나리오: [load-tests/README.md](load-tests/README.md)

## 개발 도구

- **Claude Code**: worktree 기반 피처 격리 개발
- **MCP (Playwright)**: 브라우저 자동화

## 향후 계획

기존 모니터링 인프라(`/stats` 집계, 서비스 상태 감지)를 MCP Server로 래핑하고, LangGraph 기반 Agent로 장애 진단 워크플로우를 자동화하는 확장을 계획하고 있습니다.

> 상세 설계: [AI Agent 확장 설계](docs/ai-agent-design.md)
