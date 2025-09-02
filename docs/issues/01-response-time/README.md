# 대시보드 응답 시간이 1.333으로 고정됨

## 개요
- “응답 시간 추이” 차트와 네트워크 통계의 평균 응답 시간이 1.333(또는 고정값)으로 표시되며, 트래픽이 변해도 값이 갱신되지 않습니다.

## 기대 동작
- 평균 응답 시간이 새로고침 주기마다 최신 값으로 갱신되고, `GET /stats`의 `load-balancer.avg_response_time_ms`값과 일치해야 합니다.

## 재현 절차
- 스택 실행: `skaffold dev` 또는 Docker Compose/로컬 실행
- 브라우저 대시보드 접속: `http://localhost:7100`
- 트래픽 발생 후 `/stats` 응답과 차트 비교

## 확인용 명령
```bash
curl -s http://localhost:7100/stats | jq '.["load-balancer"].avg_response_time_ms'
```

## 영향 범위
- 실시간 성능 가시성 저하, 장애 탐지 지연

## 원인 가설
- UI에서 기본값/플레이스홀더가 실제 값을 덮어씀
- Load Balancer의 평균 계산이 전체(lifetime) 평균만 반영되어 변화가 둔감함
- 통계 미들웨어가 일부 라우트를 미포함하거나 업데이트 타이밍 문제

## 수정 방향
- UI가 반드시 `stats['load-balancer'].avg_response_time_ms`를 사용하도록 바인딩 확인
- 필요 시 LB 평균을 최근 N초(예: 10초) 기준 롤링 평균으로 개선
- 통계 미들웨어가 `/`와 `/api/` 모두를 감싸도록 확인

## 수용 기준 (Acceptance Criteria)
- 차트의 평균 응답 시간이 트래픽 변화에 따라 갱신됨
- `/stats`의 `avg_response_time_ms`와 UI 표시가 근사하게 일치
- 하드코딩/기본값이 실제 값을 가리지 않음

## 관련 파일/엔드포인트
- Load Balancer: `load-balancer/main.go` (/stats 집계, statsMiddleware)
- Dashboard UI: `dashboard-ui/script.js` (chartModule.update, statusModule.update)
- 확인: `GET http://localhost:7100/stats`

