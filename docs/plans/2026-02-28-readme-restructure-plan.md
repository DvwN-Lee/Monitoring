# README 포트폴리오 재구성 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** README를 AI Agent 개발자 포트폴리오에 맞게 재배치하여 30초 스캔 최적화

**Architecture:** 기존 콘텐츠의 순서/구조만 변경. AI Agent 설계 섹션을 인프라 상세 앞으로 이동하고, 외부 프로젝트 참조를 제거.

**Tech Stack:** Markdown (README.md 편집만)

---

### Task 1: 제목 및 스크린샷 변경

**Files:**
- Modify: `README.md:1-4`

**Step 1: 제목 변경**

현재 (line 1):
```markdown
# Monitoring Service
```

변경:
```markdown
# AI-Powered K8s Operations Platform
```

**Step 2: 블로그 스크린샷 제거**

현재 (line 3):
```html
<p align="center"><img width="700" height="800" alt="blog" src="https://github.com/user-attachments/assets/338f5ded-daa4-46fa-9487-46ec1c058d7e" /></p>
```

이 줄을 삭제.

**Step 3: 확인**

README.md 상단이 다음과 같은지 확인:
```markdown
# AI-Powered K8s Operations Platform
<p align="center"><img width="700" height="800" alt="dashboard" src="https://github.com/user-attachments/assets/9a7b890b-1d7c-4c96-826f-e019df475dfb" /></p>
```

---

### Task 2: AI Agent 확장 설계 섹션의 소개 인용블록 수정

**Files:**
- Modify: `README.md` — AI Agent 확장 설계 섹션 첫 인용블록

**Step 1: 외부 프로젝트 참조 제거**

현재 (AI Agent 확장 설계 섹션 첫 인용블록):
```markdown
> 이 섹션은 기존 모니터링 인프라를 AI Agent의 Tool로 확장하기 위한 아키텍처 설계입니다.
> 현재 코드베이스에는 AI Agent Layer가 포함되어 있지 않으며, 실제 MCP Server 개발 경험([gemini-mcp](https://www.npmjs.com/package/@dongju101/gemini-mcp), npm 퍼블리시)을 기반으로 설계되었습니다. stats-mcp부터 순차적으로 구현할 계획입니다.
```

변경:
```markdown
> 이 섹션은 기존 모니터링 인프라를 AI Agent의 Tool로 확장하기 위한 아키텍처 설계입니다.
> 현재 코드베이스에는 AI Agent Layer가 포함되어 있지 않으며, stats-mcp부터 순차적으로 구현할 계획입니다.
```

---

### Task 3: 관련 경험 인용블록 제거

**Files:**
- Modify: `README.md` — AI Agent 확장 설계 섹션 하단

**Step 1: gemini-mcp 관련 경험 제거**

현재 (### 관련 경험 섹션 전체):
```markdown
### 관련 경험

> **MCP Server 개발 경험**: [gemini-mcp](https://www.npmjs.com/package/@dongju101/gemini-mcp) — Gemini CLI를 MCP Server로 래핑한 TypeScript 패키지 (npm 퍼블리시)
> - FastMCP v3.33.0 기반, 2,062 lines 소스 / 2,869 lines 테스트
> - 멀티세션 아키텍처, 토큰 자동 리셋, fallback chain 구현
> - 이 경험을 바탕으로 기존 모니터링 인프라의 MCP Tool 변환을 설계했습니다.

> **Multi-Agent 시스템 분석 경험** (별도 프로젝트)
> - Claude Code Agent Teams 내부 프로토콜 분석 (메시지 라우팅, 세션 관리)
> - Named Pipe / inotify 기반 Multi-Agent IPC 직접 구현
> - 이 경험이 LangGraph Agent의 상태 관리 및 에스컬레이션 설계에 반영되었습니다.

---
```

이 전체 블록을 삭제 (### 관련 경험 ~ 다음 --- 까지). --- 구분선은 유지하되 AI Agent 섹션 끝에 위치.

---

### Task 4: 섹션 순서 재배치

**Files:**
- Modify: `README.md` — 전체 섹션 순서 변경

**Step 1: AI Agent 확장 설계 섹션 이동**

현재 순서:
```
## 서비스 개요
---
## AI Agent 확장 설계 (현재 여기에 위치)
## 비기능 요구사항
```

이미 현재 README에서는 서비스 개요 바로 다음에 AI Agent 섹션이 있으므로,
섹션 순서는 이미 올바른 위치에 있음. 순서 변경 불필요.

실제로 필요한 것: 서비스 개요와 AI Agent 섹션 사이의 `---` 구분선 유지 확인.

**Step 2: 앵커 링크 업데이트**

현재 (소개문의 앵커 링크):
```markdown
> AI Agent 자동 장애 진단 설계 → [AI Agent 확장 설계](#ai-agent-확장-설계)
```

섹션 제목이 변경되지 않았으므로 앵커 링크 유지. 변경 불필요.

---

### Task 5: 최종 확인 및 커밋

**Step 1: 변경 사항 diff 확인**

Run: `git diff README.md`

예상 변경:
- Line 1: 제목 변경
- Line 3: 블로그 스크린샷 삭제
- AI Agent 섹션 소개 인용블록: gemini-mcp 참조 제거
- 관련 경험 섹션: 전체 삭제

**Step 2: GitHub에서 Mermaid 렌더링 확인이 필요한 경우 메모**

변경된 부분에 Mermaid 다이어그램은 없으므로 렌더링 영향 없음.

**Step 3: 커밋**

```bash
git add README.md
git commit -m "docs: restructure README for AI Agent portfolio positioning

- Change title to AI-Powered K8s Operations Platform
- Remove blog screenshot (keep dashboard only)
- Remove external project references (gemini-mcp, Multi-Agent IPC)
- Clean up AI Agent section intro

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```
