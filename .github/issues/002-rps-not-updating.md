Title: RPS not reflected in dashboard — wire load balancer RPS to UI

Summary
- The “처리량 (RPS)” chart and related metric do not show changing values even under load. The load balancer computes RPS in `/stats`, but the UI appears not to reflect it.

Current Behavior
- RPS displays as 0.0 or a static value.

Expected Behavior
- RPS updates each refresh interval using `stats['load-balancer'].requests_per_second`.

Where to look
- UI: `dashboard-ui/script.js` (chartModule.update, statusModule.update)
- Backend: `load-balancer/main.go` (RPS calculation window: recent 10s / 10)

Repro Steps
1. Run stack and open http://localhost:7100.
2. Send concurrent requests (e.g., `hey -z 10s http://localhost:7100/api/posts` or `ab -n 200 -c 20 ...`).
3. Observe RPS chart and compare with `curl -s http://localhost:7100/stats | jq '.["load-balancer"].requests_per_second'`.

Acceptance Criteria
- UI charts and metrics visibly change with load and match LB `requests_per_second` within reasonable tolerance.
- No client-side fallbacks override the backend value.

Technical Notes
- Confirm stats middleware wraps both `"/api/"` and `"/"` (UI) handlers so requests are captured.
- Ensure the UI calls `chartModule.update(stats)` on every fetch and passes the latest `stats`.

Checklist
- [ ] Validate LB RPS math and time window.
- [ ] Bind UI to `requests_per_second` in both chart and network metric widget.
- [ ] Manual test with simple load generation.

