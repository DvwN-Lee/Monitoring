Title: Datastore status shows OFFLINE — wire DB/cache health from User Service

Summary
- The dashboard’s “데이터 저장소 상태” shows DB as OFFLINE and cache hit rate as 0%, even when services are running. The `user-service` exposes DB/cache health via `/stats`, and the load balancer lifts those fields to top-level keys; the UI should consume them correctly. Also ensure Redis is reachable in the chosen run mode.

Current Behavior
- DB status: OFFLINE; Cache: unhealthy / hit ratio 0.0 regardless of Redis state.

Expected Behavior
- DB status reflects `user-service` SQLite health; Cache reflects Redis connectivity and returns a hit ratio (0% is acceptable if no cache yet, but status should be healthy when Redis is reachable).

Where to look
- Service: `user-service/user_service.py` (`/stats` and `health_check()`), `cache_service.py` (Redis ping)
- Infra: `docker-compose.yml` (redis service, env `REDIS_HOST/REDIS_PORT`), `k8s-manifests/*` (ConfigMap values, redis deployment)
- UI: `dashboard-ui/script.js` (statusModule.update)

Repro Steps
1. Start with Docker Compose which includes `redis`.
2. Open http://localhost:7100 and observe DB/Cache metrics.
3. Kill Redis and confirm cache status flips to unhealthy, then restore.

Acceptance Criteria
- DB status shows ONLINE when SQLite operations are healthy.
- Cache status shows ONLINE when Redis is reachable; OFFLINE when Redis is down.
- UI reads `stats.database.status` and `stats.cache.status` lifted by the load balancer.

Technical Notes
- Compose sets `REDIS_HOST=redis`; local dev (non-Docker) should export `REDIS_HOST=localhost`.
- The LB code elevates `user_service.database` and `.cache` to top-level keys in `/stats`; the UI reads those without defaults that mask the true value.

Checklist
- [ ] Confirm Redis connectivity per environment and document required env vars.
- [ ] Verify `/stats` includes `database.status` and `cache.status` and UI binds to them.
- [ ] Manual test by toggling Redis to see status change.

