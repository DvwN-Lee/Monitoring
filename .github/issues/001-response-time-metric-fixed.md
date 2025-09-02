Title: Dashboard response time stuck at 1.333 — should reflect live average

Summary
- The “응답 시간 추이” chart and network metrics show a constant average response time of 1.333ms and do not vary with traffic. This should reflect the live average from the load balancer’s aggregated stats.

Current Behavior
- Response time appears fixed (e.g., 1.333) and does not change even when generating load.

Expected Behavior
- Response time updates every refresh interval, matching `load-balancer`’s `avg_response_time_ms` in `GET /stats`.

Where to look
- UI: `dashboard-ui/script.js` (chartModule.update, statusModule.update)
- Backend: `load-balancer/main.go` (statsMiddleware, /stats aggregation)

Repro Steps
1. Run stack (Compose or Skaffold).
2. Open http://localhost:7100 and watch the “응답 시간 추이”.
3. Generate traffic to `http://localhost:7100/api/...` and compare chart vs. `curl -s http://localhost:7100/stats`.

Acceptance Criteria
- The response time line chart changes when traffic characteristics change.
- `dashboard-ui` uses `stats['load-balancer'].avg_response_time_ms` with no hard-coded fallback that masks real values.
- Manual verification shows chart closely tracking values in `/stats`.

Technical Notes
- In `load-balancer/main.go`, avg is computed as `totalResponseTime / totalRequests` (ms). Confirm the interceptor measures only proxied paths (both `/` and `/api/`).
- In `dashboard-ui/script.js`, ensure `chartModule.update()` and “네트워크 통계” read the same `avg_response_time_ms` source without defaulting to a constant.

Checklist
- [ ] Verify LB avg calculation correctness over rolling window vs. lifetime.
- [ ] Ensure UI binds to `avg_response_time_ms` and updates at `config.refreshInterval`.
- [ ] Add a quick load-gen note in README for manual validation.

