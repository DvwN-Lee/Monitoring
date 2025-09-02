# 네트워크 통계(성공률, 에러율, 평균 지연) 미반영

## 개요
- “네트워크 통계” 위젯이 `/stats`의 최신 값을 반영하지 않고 기본값에 머물거나 갱신이 지연됩니다.

## 기대 동작
- 성공률(`success_rate`), 에러율(`100 - success_rate`), 평균 지연(`avg_response_time_ms`)이 매 새로고침 시점에 최신으로 표시되어야 합니다.

## 재현 절차
- 대시보드 접속: `http://localhost:7100`
- 정상/실패 요청(예: `401`, `404`)을 섞어 발생시키고 위젯 변화 관찰

## 확인용 명령
```bash
curl -s http://localhost:7100/stats | jq '.["load-balancer"]'
```

## 영향 범위
- 신뢰할 수 없는 상태 지표로 운영 판단에 오류 유발 가능

## 원인 가설
- UI 바인딩 누락 또는 기본값이 실제 값을 덮어씀
- `/stats` 필드명/경로 매칭 오류

## 수정 방향
- `statusModule.update`에서 최신 payload로 모든 네트워크 지표를 직접 세팅
- 데이터가 존재할 때 기본값을 사용하지 않도록 방어 코드 정비

## 수용 기준 (Acceptance Criteria)
- 성공률/에러율/평균 지연이 매 새로고침마다 최신 값으로 갱신
- `/stats`의 `load-balancer` 값과 UI 표기가 일치

## 관련 파일/엔드포인트
- Dashboard UI: `dashboard-ui/script.js` (statusModule.update)
- 확인: `GET http://localhost:7100/stats`

