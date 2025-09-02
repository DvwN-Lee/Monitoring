# Monitoring

마이크로서비스 기반의 쿠버네티스 모니터링 대시보드 프로젝트입니다. 각 서비스는 독립적으로 컨테이너화되어 있으며 로드밸런서를 통해 트래픽이 분배되고, 대시보드를 통해 실시간 상태를 확인할 수 있습니다.

## 프로젝트 구조

```
.
├── api-gateway      # Go 기반 API 게이트웨이
├── auth-service     # 사용자 인증 서비스 (FastAPI)
├── blog-service     # 블로그 예제 서비스 (FastAPI)
├── user-service     # 사용자 관리 서비스 (FastAPI + Redis)
├── analytics-service# 로그 수집 및 통계 서비스 (FastAPI)
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
- **Analytics Service**: 접근 로그를 수집하고 시스템 통계를 조회할 수 있는 REST API를 제공합니다.
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
