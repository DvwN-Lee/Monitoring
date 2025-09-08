Title: Register returns 500 on first attempt, then 400 “Username already exists”

Summary
- First POST to `/api/register` results in `500 Internal Server Error`.
- Second POST with the same payload returns `400 Username already exists`.
- Root cause: `user-service` creates the row, but crashes when trying to fetch the created user because `get_user_by_id` is not implemented in `database_service.py`.

Current Behavior
1) API Gateway rewrites `/api/register` → User Service `/users` (OK).
2) User Service handler (`user_service.py:63-69`) calls:
   - `user_id = await db.add_user(...)` (insert succeeds)
   - `created_user = await db.get_user_by_id(user_id)` (method missing) → raises exception → 500
3) A subsequent request with the same `username` attempts another insert, SQLite UNIQUE constraint triggers, and the service returns `400 Username already exists` (as designed).

Expected Behavior
- First POST `/api/register` should respond `201 Created` with the newly created user (id, username, email) and never 500.

Where to Look
- `user-service/user_service.py` (POST `/users`): uses `db.get_user_by_id` after insert.
- `user-service/database_service.py`: no `get_user_by_id` implementation; add it or change retrieval strategy after insert.
- `api-gateway/main.go`: routing for `/api/register` already points to User Service.

Repro Steps
1. Deploy the stack (Skaffold or Compose).
2. Call register twice:
   - `curl -X POST http://<LB>/api/register -H 'Content-Type: application/json' -d '{"username":"test","email":"test@example.com","password":"secret"}'`
   - First call → 500; second call → 400 "Username already exists".

Acceptance Criteria
- First register request returns `201` with a valid `UserOut` payload; no 500.
- Second register with same username returns `400 Username already exists` (unchanged).
- No unhandled exceptions logged by `user-service` during the first registration.

Technical Notes / Options
- Implement `get_user_by_id(id: int) -> Optional[Dict]` in `database_service.py` and use it after insert.
- Or, replace the fetch-by-id with `get_user_by_username(username)` or construct the `UserOut` from known values + the returned `lastrowid` after insert.
- Consider aligning cache API to use `username` consistently (separate follow-up).

