# RPS(처리량)가 대시보드에 반영되지 않음

## 개요
- “처리량 (RPS)” 차트와 지표가 0.0 또는 고정값으로 유지되어 실제 부하가 반영되지 않습니다.

## 기대 동작
- `stats['load-balancer'].requests_per_second` 값을 기준으로 새로고침 주기마다 RPS가 갱신되어야 합니다.

## 재현 절차
- 스택 실행 후 대시보드 접속: `http://localhost:7100`
- 동시 요청 발생(예: `hey`, `ab`) 후 RPS 변화 확인

## 확인용 명령
```bash
curl -s http://localhost:7100/stats | jq '.["load-balancer"].requests_per_second'
# 예) 간단 부하 (설치되어 있다면)
# hey -z 10s http://localhost:7100/api/posts
# 또는 ab -n 200 -c 20 http://localhost:7100/api/posts
```

## 영향 범위
- 처리량 가시성 상실, 용량/성능 진단 어려움

## 원인 가설
- UI의 `requests_per_second` 바인딩 누락/기본값 덮어쓰기
- LB의 RPS 계산 윈도우(최근 10초/10)와 기대치 차이
- fetch 주기/오류 처리로 최신 값 미적용

## 수정 방향
- 차트/네트워크 통계 모두 `requests_per_second`를 사용하도록 UI 바인딩 확인
- 필요 시 LB의 계산 윈도우/HTTP 클라이언트 타임아웃 조정

## 수용 기준 (Acceptance Criteria)
- 부하 발생 시 RPS 값이 눈에 띄게 변화
- `/stats`의 값과 UI 표기가 합리적 오차 내에서 일치

## 관련 파일/엔드포인트
- Load Balancer: `load-balancer/main.go` (RPS 계산 로직)
- Dashboard UI: `dashboard-ui/script.js` (chartModule.update, statusModule.update)
- 확인: `GET http://localhost:7100/stats`

