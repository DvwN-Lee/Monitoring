import logging
from fastapi import FastAPI, Request, HTTPException
from pydantic import BaseModel, Field
from typing import Optional

# 핸들러 함수들을 임포트
import logging_handler
import statistics_handler

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI()

# --- Pydantic 모델 정의 ---
class LogRequest(BaseModel):
    user_id: Optional[int] = None
    endpoint: str
    method: str
    status_code: int
    response_time: float
    server_instance: str = "unknown"

# --- API 엔드포인트 ---

@app.post("/logs", status_code=202)
async def handle_log_request(log_data: LogRequest, request: Request):
    """POST /logs: 접근 로그를 받아 기록을 위임"""
    try:
        await logging_handler.record_access_log(
            user_id=log_data.user_id,
            endpoint=log_data.endpoint,
            method=log_data.method,
            status_code=log_data.status_code,
            response_time=log_data.response_time,
            server_instance=log_data.server_instance,
            ip_address=request.client.host,
            user_agent=request.headers.get('User-Agent', '')
        )
        return {"message": "Log accepted"}
    except Exception as e:
        logger.error(f"Log handler error: {e}", exc_info=True)
        raise HTTPException(status_code=400, detail="Bad Request")

@app.get("/statistics")
async def handle_statistics_request():
    """GET /statistics: 통계 조회를 위임"""
    stats = await statistics_handler.get_system_statistics()
    if 'error' in stats:
        raise HTTPException(status_code=500, detail=stats)
    return stats

@app.get("/health")
async def handle_health_request():
    """GET /health: 상태 확인을 위임"""
    health_status = await statistics_handler.check_health()
    status_code = 200 if health_status['status'] == 'healthy' else 503
    if status_code != 200:
        raise HTTPException(status_code=status_code, detail=health_status)
    return health_status

# --- Uvicorn으로 앱 실행 ---
if __name__ == '__main__':
    import uvicorn
    port = 8004
    logger.info(f"🚀 Analytics Service starting on port {port}")
    uvicorn.run(app, host="0.0.0.0", port=port)