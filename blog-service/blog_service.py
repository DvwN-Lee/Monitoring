import os
import logging
from fastapi import FastAPI, Request, HTTPException, Form
from fastapi.responses import JSONResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel

# --- 기본 로깅 설정 ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('BlogServiceApp')

app = FastAPI()

# --- 정적 파일 및 템플릿 설정 ---
templates = Jinja2Templates(directory="templates")
app.mount("/blog/static", StaticFiles(directory="static"), name="static")


# --- 임시 데이터 저장소 ---
posts_db = {}
users_db = {}

# --- Pydantic 모델 ---
class UserLogin(BaseModel):
    username: str
    password: str

class UserRegister(BaseModel):
    username: str
    password: str

# --- API 핸들러 함수 ---
@app.get("/api/posts")
async def handle_get_posts():
    """모든 블로그 게시물 목록을 반환합니다."""
    return JSONResponse(content=list(posts_db.values()))

@app.get("/api/posts/{post_id}")
async def handle_get_post_by_id(post_id: int):
    """ID로 특정 게시물을 찾아 반환합니다."""
    post = posts_db.get(post_id)
    if post:
        return JSONResponse(content=post)
    raise HTTPException(status_code=404, detail={'error': 'Post not found'})

@app.post("/api/login")
async def handle_login(user_login: UserLogin):
    """사용자 로그인을 처리합니다."""
    user = users_db.get(user_login.username)
    if user and user['password'] == user_login.password:
        return JSONResponse(content={'token': f'session-token-for-{user_login.username}'})
    raise HTTPException(status_code=401, detail={'error': 'Invalid credentials'})

@app.post("/api/register", status_code=201)
async def handle_register(user_register: UserRegister):
    """사용자 등록을 처리합니다."""
    if not user_register.username or not user_register.password:
        raise HTTPException(status_code=400, detail={'error': 'Username and password are required'})
    if user_register.username in users_db:
        raise HTTPException(status_code=409, detail={'error': 'Username already exists'})

    users_db[user_register.username] = {'password': user_register.password}
    logger.info(f"New user registered: {user_register.username}")
    return JSONResponse(content={'message': 'Registration successful'})

@app.get("/health")
async def handle_health():
    """쿠버네티스를 위한 헬스 체크 엔드포인트"""
    return {"status": "ok", "service": "blog-service"}

@app.get("/stats")
async def handle_stats():
    """대시보드를 위한 통계 엔드포인트"""
    return {
        "blog_service": {
            "service_status": "online",
            "post_count": len(posts_db)
        }
    }

# --- 웹 페이지 서빙 (SPA) ---
@app.get("/blog/{path:path}")
async def serve_spa(request: Request, path: str):
    """메인 블로그 페이지를 렌더링합니다."""
    return templates.TemplateResponse("index.html", {"request": request})


# --- 애플리케이션 시작 시 샘플 데이터 설정 ---
@app.on_event("startup")
def setup_sample_data():
    """서비스 시작 시 샘플 데이터를 생성합니다."""
    global posts_db, users_db
    posts_db = {
        1: {"id": 1, "title": "첫 번째 블로그 글", "author": "admin",
            "content": "마이크로서비스 아키텍처에 오신 것을 환영합니다! 이 블로그는 FastAPI로 리팩터링되었습니다."},
        2: {"id": 2, "title": "Kustomize와 Skaffold 활용하기", "author": "dev",
            "content": "인프라 관리가 이렇게 쉬울 수 있습니다. CI/CD 파이프라인을 통해 자동으로 배포됩니다."},
    }
    users_db = {
        'admin': {'password': 'password123'}
    }
    logger.info(f"{len(posts_db)}개의 샘플 게시물과 {len(users_db)}명의 사용자로 초기화되었습니다.")

if __name__ == "__main__":
    import uvicorn
    port = 8005
    logger.info(f"✅ Blog Service starting on http://0.0.0.0:{port}")
    uvicorn.run(app, host="0.0.0.0", port=port)