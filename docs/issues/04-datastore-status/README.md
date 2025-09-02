# 데이터 저장소 상태가 OFFLINE으로 표기됨

## 개요
- 대시보드의 “데이터 저장소 상태”에서 DB가 OFFLINE, 캐시는 unhealthy/히트율 0%로 표시됩니다. `user-service`의 `/stats`는 DB/Redis 상태를 제공하고, Load Balancer가 이를 최상위 `database`, `cache` 키로 승격해 반환합니다. UI가 이를 정확히 반영해야 합니다.

## 기대 동작
- DB 상태: SQLite 동작 정상 시 ONLINE
- Cache 상태: Redis 연결 가능 시 ONLINE, 다운 시 OFFLINE
- 히트율: 트래픽/캐시 미스에 따라 0%일 수 있으나 상태는 실제 연결 여부를 반영

## 재현 절차
- Docker Compose로 실행 시 `redis` 포함 후 대시보드 접속: `http://localhost:7100`
- Redis 중지/재시작 하여 캐시 상태 변화 확인

## 확인용 명령
```bash
curl -s http://localhost:7100/stats | jq '{database: .database, cache: .cache}'
```

## 영향 범위
- 저장소/캐시 상태 오판 → 운영 이슈 대응 지연

## 원인 가설
- 로컬 개발 모드에서 `REDIS_HOST`/`REDIS_PORT` 미설정 (기본: `redis-service`)
- UI가 LB의 최상위 `database`, `cache` 키를 제대로 읽지 않음

## 수정 방향
- 로컬 실행 시 환경 변수 설정: `export REDIS_HOST=localhost REDIS_PORT=6379`
- UI에서 `stats.database.status`, `stats.cache.status`, `stats.cache.hit_ratio` 바인딩 확인
- Compose/K8s에서 Redis 서비스/ConfigMap 값 확인

## 수용 기준 (Acceptance Criteria)
- Redis 가동 시 Cache ONLINE, 중지 시 OFFLINE으로 전환
- DB 상태 ONLINE 유지(기본 SQLite 사용)
- `/stats` 값과 UI 표기가 일치

## 관련 파일/엔드포인트
- User Service: `user-service/user_service.py` (/stats), `user-service/cache_service.py`
- 인프라: `docker-compose.yml` (redis), `k8s-manifests/*` (ConfigMap/redis)
- UI: `dashboard-ui/script.js` (statusModule.update)
- 확인: `GET http://localhost:7100/stats`

