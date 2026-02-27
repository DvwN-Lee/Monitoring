# AI Agent 포트폴리오 재구성 전략서

> 작성 기준: 현재 README.md, eval-hiring-manager.md, session-context.md 분석 기반
> 목표: 채용담당자 평가 5.5/10 → 8+/10 달성

---

## Part 1: 3가지 재구성 접근법 비교

### 접근법 A: "Above the Fold 최적화" (최소 변경)

**설명**: 기존 README 구조를 유지하되, 상단 30줄 이내에 AI Agent 핵심 역량을 집중 배치. 제목은 유지하고, 부제와 뱃지로 AI 포지셔닝 추가.

**구체적 변경**:
- 제목 유지 `# Monitoring Service` + 부제 1줄 추가
- 스크린샷 2개 → 1개로 축소 (대시보드만)
- 스크린샷 바로 아래에 "AI Agent 설계 하이라이트" 3줄 박스 추가
- 키워드 뱃지에 `MCP Server` `Multi-Agent IPC` `Claude Code Agent Teams` 추가
- 기존 AI Agent 섹션에 누락 역량(Multi-Agent IPC, 3회 재구축) 2-3줄 추가

**장점**:
- 구현 난이도 최저, 기존 문서와의 일관성 유지
- diff가 작아 리뷰 부담 없음
- 기존 인프라 내용의 신뢰도(7.5/10)를 훼손하지 않음

**단점**:
- 근본적 문제(제목이 "Monitoring Service") 해결 못함
- 30초 스캔 시 여전히 "인프라 프로젝트 + AI 약간" 인상
- 누락 역량 반영이 피상적

**예상 효과**: 5.5/10 → **6.5~7/10**
**구현 난이도**: 낮음 (1-2시간)

---

### 접근법 B: "듀얼 아이덴티티" (프로젝트 포지셔닝 전환) ⭐ 추천

**설명**: 프로젝트 정체성을 "모니터링 서비스"에서 **"AI Agent가 운영하는 마이크로서비스 플랫폼"**으로 전환. README 상단 절반을 AI Agent/MCP 역량 중심으로 완전 재구성하고, 기존 인프라 내용은 하단 "Infrastructure Detail"로 이동.

**구체적 변경**:
- 제목 변경: `# AI-Powered Kubernetes Operations Platform`
  - 부제: `MCP Server + LangGraph Agent로 설계한 자동 장애 진단 시스템`
- **Above the Fold (30줄 이내)**:
  1. 한 줄 요약: "실제 운영 중인 마이크로서비스 인프라를 AI Agent의 Tool로 변환하는 프로젝트"
  2. 핵심 기술 뱃지 (MCP, LangGraph, Multi-Agent IPC, Go, K8s)
  3. "이 프로젝트가 보여주는 것" 3가지 불릿:
     - MCP Server 설계 + npm 퍼블리시 실전 경험 (gemini-mcp)
     - Multi-Agent 시스템 내부 프로토콜 분석 (Claude Code Agent Teams)
     - 동일 플랫폼 3회 재구축을 통한 시스템 설계 성장
  4. 아키텍처 다이어그램 (현재 Mermaid 다이어그램 축소 버전)
- **중단 섹션**: AI Agent 설계 상세 (현재 내용 + 누락 역량 추가)
  - 신규 추가: "개발 프로세스" 섹션 (Claude Code + worktree 기반 개발)
  - 신규 추가: "Multi-Agent 시스템 분석 경험" 독립 섹션화
  - 신규 추가: "기술적 성장 타임라인" (v1→v2→v3 재구축 스토리)
- **하단 섹션**: 기존 인프라 상세 (서비스 개요, 안정성 설계, 부하 테스트 등 그대로 유지)

**장점**:
- 30초 스캔에서 "AI Agent 사람"으로 즉시 분류됨
- 누락된 5개 역량 모두 자연스럽게 반영 가능
- 기존 인프라 코드/문서 일체 수정 불필요 (위치만 재배치)
- "인프라를 AI의 Tool로 변환"이라는 고유한 스토리라인 형성
- 채용담당자 eval에서 지적된 모든 문제점 해결

**단점**:
- README 구조 변경 폭이 큼 (리뷰 시간 필요)
- 제목 변경이 기존 레포를 아는 사람에게 혼란 줄 수 있음
- "설계만 있고 구현 없음"이라는 본질적 약점은 여전히 존재 (정직하게 명시)

**예상 효과**: 5.5/10 → **8~8.5/10**
**구현 난이도**: 중간 (3-4시간)

---

### 접근법 C: "포트폴리오 허브" (메타 프로젝트화)

**설명**: 이 레포를 단독 프로젝트가 아닌, 전체 AI Agent 포트폴리오의 허브로 변환. gemini-mcp, Monitoring v2/v3, exam-platform 등 모든 프로젝트를 관통하는 "AI Agent 개발자 이동주" 포트폴리오 페이지로 재구성.

**구체적 변경**:
- 제목: `# AI Agent Developer Portfolio — 이동주`
- 프로젝트별 카드 형태로 나열 (gemini-mcp, Monitoring Platform, exam-platform)
- 각 프로젝트 카드에서 핵심 역량 하이라이트
- 기존 Monitoring README 내용은 별도 `docs/monitoring-detail.md`로 분리

**장점**:
- 한 곳에서 모든 역량을 볼 수 있음
- GitHub 프로필 핀 전략과 시너지

**단점**:
- "Monitoring" 레포의 정체성이 완전히 변함 → 프로젝트 README로서의 가치 상실
- 다른 레포(gemini-mcp)와 중복 정보 발생
- 채용담당자가 "실제 프로젝트가 아닌 자기소개 페이지"로 인식할 위험
- **과장/허세 느낌**을 줄 수 있음 (정직함 원칙 위배)

**예상 효과**: 5.5/10 → **6~7/10** (역효과 가능성 있음)
**구현 난이도**: 높음 (5-6시간)

---

### 접근법 비교 매트릭스

| 기준 | A: Above the Fold | B: 듀얼 아이덴티티 ⭐ | C: 포트폴리오 허브 |
|---|---|---|---|
| 30초 스캔 효과 | 6/10 | **9/10** | 7/10 |
| 누락 역량 반영도 | 3/5개 | **5/5개** | 5/5개 |
| 정직함 유지 | 높음 | **높음** | 중간 |
| 기존 코드 영향 | 없음 | **없음** | 있음 (구조 변경) |
| 구현 난이도 | 낮음 | **중간** | 높음 |
| 예상 최종 점수 | 6.5~7 | **8~8.5** | 6~7 |
| 리스크 | 낮음 | **낮음** | 높음 (역효과 가능) |

**결론: 접근법 B "듀얼 아이덴티티" 추천**

---

## Part 2: 접근법 B 구체적 실행 계획

### 2-1. README 구조 변경안

```
===== ABOVE THE FOLD (30초 스캔 영역) =====

# AI-Powered Kubernetes Operations Platform
> MCP Server + LangGraph Agent 기반 자동 장애 진단 시스템 설계
> 실제 운영 중인 마이크로서비스 인프라 위에 AI Agent Layer를 설계한 프로젝트

[뱃지: MCP Server | LangGraph | Multi-Agent | Go | FastAPI | K8s]

<대시보드 스크린샷 1개 (현재 2개 → 1개로 축소)>

## 이 프로젝트가 보여주는 것  ← 핵심! 30초 안에 전달

| 역량 | 증거 |
|---|---|
| MCP Server 설계 + 실전 | gemini-mcp npm 퍼블리시 (2,062L 소스 / 2,869L 테스트) |
| Multi-Agent 시스템 이해 | Claude Code Agent Teams 프로토콜 분석, Named Pipe IPC 구현 |
| 프로덕션 인프라 설계 | Go + FastAPI 마이크로서비스, K8s, 동일 플랫폼 3회 재구축 |
| AI Agent Tool 변환 설계 | 기존 /stats, kubectl, logs → MCP Server Layer 매핑 |

===== AI AGENT 설계 영역 =====

## AI Agent 확장 설계
  (기존 내용 유지: 설계 배경, 아키텍처, MCP Tool 매핑, LangGraph 워크플로우)
  + "향후 구현 예정" 명시 유지

## 개발자 역량 상세   ← 신규 섹션

### MCP Server 실전 경험
  - gemini-mcp 상세 (현재 인용블록 → 독립 섹션으로 승격)
  - Memory MCP / Context7 / Playwright MCP 운영 경험

### Multi-Agent 시스템 분석
  - Claude Code Agent Teams 아키텍처 분석 경험
  - Named Pipe / inotify 기반 IPC 구현
  - 이 경험이 LangGraph Agent 설계에 반영된 지점

### 기술적 성장: 동일 플랫폼 3회 재구축
  v1 (현재): Go + FastAPI, K8s, 100 RPS 목표
  v2: CloudStack/Terraform/Istio, P99 99.5% 감소, 224 커밋
  v3: GCP/K3s/ArgoCD, 237 커밋, GCP 실배포
  → 각 버전에서 무엇을 배웠고, 왜 다시 만들었는지

### 개발 프로세스
  - Claude Code Agent Teams 활용 개발
  - worktree 기반 격리된 피처 개발
  - AI 코드 리뷰 + 사람 리뷰 병행

===== 인프라 상세 영역 (기존 내용 그대로) =====

## Infrastructure Detail

### 프로젝트 구조      (기존 유지)
### 서비스 개요        (기존 유지)
### 안정성 설계        (기존 유지)
### 프록시/집계 최적화  (기존 유지)
### 대시보드           (기존 유지)
### 부하 테스트        (기존 유지)
### 로컬 실행          (기존 유지)
### 의존성             (기존 유지)
### 데이터 백업        (기존 유지)
```

### 2-2. 프로젝트 포지셔닝 변경

**현재 포지셔닝**: "마이크로서비스 모니터링 플랫폼" (인프라 프로젝트)

**변경 포지셔닝**: "AI Agent가 Tool로 활용하도록 설계된 마이크로서비스 플랫폼"

**핵심 전환 로직**:
- "인프라를 만들었다" → "인프라를 AI Agent의 Tool로 변환하는 설계를 했다"
- 동일한 코드, 동일한 기능이지만 **바라보는 관점**을 전환
- 인프라는 AI Agent의 "전제 조건"이자 "도메인 전문성"으로 재프레이밍

**제목 선택지 (우선순위)**:
1. `AI-Powered Kubernetes Operations Platform` — 가장 직관적
2. `MCP-Ready Monitoring Platform` — MCP 강조
3. `Intelligent Operations Platform` — 범용적

**정직함 유지 전략**:
- "향후 구현 예정" 표시는 반드시 유지
- "설계" vs "구현"을 섹션 레벨에서 명확히 구분
- AI Agent Layer가 아직 코드에 없다는 점을 첫 문단에서 투명하게 밝힘
- 대신, **설계의 근거가 되는 실전 경험**(gemini-mcp, Multi-Agent IPC)을 강조

### 2-3. 누락 역량 반영 방법

| 누락 역량 | 반영 위치 | 반영 방법 |
|---|---|---|
| Claude Code Agent Teams 프로토콜 분석 | "Multi-Agent 시스템 분석" 독립 섹션 | 메시지 라우팅, 세션 관리 분석 과정과 인사이트 3-5줄 기술 |
| Named Pipe/inotify IPC 구현 | 위 섹션 내부 | "분석에서 그치지 않고 IPC를 직접 구현"한 점 강조 |
| MCP Server 실무 운영 | "MCP Server 실전 경험" 독립 섹션 | Memory MCP, Context7, Playwright MCP를 실무에서 어떻게 활용했는지 |
| 동일 플랫폼 3회 재구축 | "기술적 성장" 독립 섹션 | 각 버전의 핵심 차이와 학습 포인트를 타임라인으로 |
| gemini-mcp npm 퍼블리시 | Above the Fold 테이블 + MCP 섹션 | 현재 인용블록에서 독립 섹션으로 승격, 구체적 기술 결정 포함 |

### 2-4. Above the Fold 전략 (30초 스캔 최적화)

**원칙**: 채용담당자가 스크롤 없이 보는 영역(약 800px, README 상단 25-30줄)에서 3가지 질문에 답해야 함.

| 채용담당자 질문 | 30줄 내 답변 |
|---|---|
| "이 사람이 뭘 할 수 있지?" | 제목 + 부제로 즉시 전달: MCP + LangGraph + K8s |
| "증거가 있나?" | "이 프로젝트가 보여주는 것" 테이블: gemini-mcp npm, Multi-Agent IPC, 3회 재구축 |
| "더 볼 가치가 있나?" | 아키텍처 다이어그램 미리보기 + 앵커 링크 |

**스크린샷 전략**:
- 현재 2개 → 1개로 축소 (대시보드만 유지)
- 스크린샷이 Above the Fold의 50%를 차지하는 현재 상태는 비효율적
- 텍스트 정보의 밀도를 높여야 함

**뱃지/키워드 전략**:
```
`MCP Server` `LangGraph Agent` `Multi-Agent IPC` `Go` `FastAPI` `Kubernetes` `Claude Code`
```
- AI 관련 키워드를 앞에 배치
- 인프라 키워드는 뒤에 배치하되 유지 (Go + Python 양쪽 역량 어필)

---

## Part 3: 한국 AI Agent 시장 차별화 포인트

### "이 사람이 다른 50명과 다른 점" — 30초 전달 전략

#### 한국 AI Agent 시장의 전형적 지원자 프로필

대부분의 지원자:
- LangChain/LangGraph로 RAG 챗봇 만들어봄
- OpenAI API 호출 경험
- 포트폴리오 = "~~ 챗봇", "~~ RAG 시스템"
- MCP는 들어봤지만 구현 경험 없음
- Multi-Agent는 CrewAI 튜토리얼 수준

#### 이동주의 차별화 축 3가지

**1. "MCP를 실제로 만들어서 npm에 올린 사람" (희소성: 상위 5%)**
- gemini-mcp: 단순 래퍼가 아닌 멀티세션/토큰 리셋/fallback chain 구현
- 2,869줄 테스트 — "튜토리얼 수준이 아닌 프로덕션 수준"
- **30초 전달**: `npm 퍼블리시된 MCP Server 개발 (2,062L 소스 / 2,869L 테스트)`

**2. "AI Agent 시스템의 내부를 뜯어본 사람" (희소성: 상위 1-3%)**
- Claude Code Agent Teams의 메시지 라우팅, 세션 관리를 프로토콜 레벨에서 분석
- Named Pipe/inotify 기반 IPC를 직접 구현 — "Agent 간 통신이 실제로 어떻게 작동하는지 아는 사람"
- **30초 전달**: `Claude Code Multi-Agent 내부 프로토콜 분석 + IPC 직접 구현`

**3. "인프라 위에 AI Agent를 올리는 관점을 가진 사람" (희소성: 높음)**
- 대부분: Python으로 AI 프로젝트만 함 → 인프라 모름
- 대부분: DevOps만 함 → AI Agent 모름
- 이동주: Go + FastAPI 마이크로서비스를 직접 만들고, 그 위에 MCP/Agent Layer를 설계
- 3회 재구축 경험 → 시스템 설계의 trade-off를 체감으로 아는 사람
- **30초 전달**: `Go+Python 마이크로서비스 3회 재구축 → AI Agent Tool로 변환 설계`

#### 차별화 요약 (한 문장)

> "AI Agent 프레임워크를 사용한 사람"이 아니라, **"AI Agent 시스템이 내부에서 어떻게 작동하는지 분석하고 직접 구현한 사람"**

이 한 문장이 50명의 LangChain 챗봇 프로젝트와 즉시 구분되는 포인트.

#### README 상단에서의 구현

```markdown
# AI-Powered Kubernetes Operations Platform

> 실제 운영 중인 마이크로서비스 인프라를 AI Agent의 Tool로 변환하는 프로젝트
> MCP Server 설계 | LangGraph Agent 워크플로우 | Multi-Agent IPC 구현 경험

| 핵심 역량 | 증거 |
|---|---|
| **MCP Server 설계 + 실전** | [gemini-mcp](npm 링크) npm 퍼블리시 — 2,062L 소스 / 2,869L 테스트 |
| **Multi-Agent 시스템 분석** | Claude Code Agent Teams 프로토콜 분석, Named Pipe/inotify IPC 구현 |
| **프로덕션 인프라** | Go + FastAPI 마이크로서비스, K8s, 동일 플랫폼 3회 재구축 |
```

이렇게 하면 채용담당자가 30초 안에 볼 수 있는 정보:
1. **제목**: AI + Kubernetes — "아, 인프라도 알고 AI도 아는 사람"
2. **부제**: MCP + LangGraph + Multi-Agent — "핵심 기술 스택이 명확하다"
3. **테이블 첫 번째 줄**: npm 퍼블리시 — "이건 실전이다"
4. **테이블 두 번째 줄**: 프로토콜 분석 + IPC 구현 — "이건 다른 사람이 안 하는 것이다"

---

## Part 4: 실행 우선순위

### Phase 1 (즉시, 가장 높은 ROI)
1. README 제목 + 부제 변경
2. Above the Fold 영역 재구성 (스크린샷 축소 + 역량 테이블 추가)
3. 키워드 뱃지 재배치

### Phase 2 (핵심)
4. "개발자 역량 상세" 섹션 신규 작성
   - MCP Server 실전 경험
   - Multi-Agent 시스템 분석
   - 기술적 성장 타임라인 (3회 재구축)
   - 개발 프로세스 (Claude Code + worktree)
5. 기존 인프라 섹션을 "Infrastructure Detail" 헤더 아래로 재배치

### Phase 3 (마무리)
6. 전체 검토 및 톤 통일
7. 앵커 링크 동작 확인
8. Mermaid 다이어그램 GitHub 렌더링 확인

---

## 부록: 예상 점수 변화 (접근법 B 적용 시)

| 항목 | 현재 | 변경 후 (예상) | 변화 근거 |
|---|---|---|---|
| 첫인상 (30초) | 5/10 | **9/10** | 제목/부제/테이블로 AI Agent 즉시 인식 |
| JD 매칭도 | 6/10 | **8/10** | Multi-Agent, MCP, 개발 프로세스 추가 |
| 차별화 | 7/10 | **9/10** | 누락 역량 5개 모두 반영 |
| 실력 증거 | 7.5/10 | **8/10** | 기존 신뢰도 유지 + 추가 증거 |
| 레드플래그 | 2/10 | **2/10** | 변화 없음 (정직함 유지) |
| **종합** | **5.5/10** | **8~8.5/10** | |
| 면접 판단 | Maybe | **Yes** | |
