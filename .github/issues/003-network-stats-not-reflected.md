Title: Network stats widget not reflecting live data (success rate, error rate, avg latency)

Summary
- The “네트워크 통계” widget does not consistently reflect the values from `/stats` (success rate, avg response time, error rate). Values appear stale or zeroed.

Current Behavior
- Success rate and error rate remain at defaults; avg response time matches the stuck value from Issue #1.

Expected Behavior
- Network stats update in sync with `/stats` and reflect live traffic.

Where to look
- UI: `dashboard-ui/script.js` (statusModule.update)
- Backend: `load-balancer/main.go` (fields: `success_rate`, `avg_response_time_ms`, derived error rate)

Repro Steps
1. Open http://localhost:7100 and generate mixed success/failure requests to change success rate.
2. Compare widget values with `curl -s http://localhost:7100/stats | jq '.["load-balancer"]'`.

Acceptance Criteria
- Success rate, error rate, and average latency update every refresh.
- Error rate equals `100 - success_rate` in the UI unless the backend supplies a dedicated field.

Technical Notes
- Verify UI binds to `stats['load-balancer'].success_rate` and computes error rate as `100 - success_rate`.
- Ensure `statusModule.update(stats, isFetchSuccess)` sets all network fields from the latest payload.

Checklist
- [ ] Bind fields in UI to backend values.
- [ ] Add defensive checks to avoid defaulting when data exists.
- [ ] Manual verification under varying load patterns.

