# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

잡모아 지점 상담사를 위한 AI 기반 장비/자산 관리 시스템 (PC/Mobile).
온디바이스 AI(Gemma 4 E2B)로 장비 촬영 → 자동 분류 → Human-in-the-loop 등록.

## 빌드/실행 명령어

```bash
# Backend (Spring Boot 3.5.0 + Java 21, 포트 4590)
cd backend && ./gradlew bootRun          # 개발 서버 (spring.profiles.active=local)
cd backend && ./gradlew test             # 전체 테스트
cd backend && ./gradlew test --tests "com.jobmoa.equipment.service.AssetServiceTest"  # 단일 테스트 클래스
cd backend && ./gradlew build            # 빌드
cd backend && ./gradlew jacocoTestReport # 커버리지 리포트

# Frontend (Next.js 16 + React 19, 포트 4580)
cd frontend && npm install
cd frontend && npm run dev               # 개발 서버
cd frontend && npm run build             # 프로덕션 빌드
cd frontend && npm run lint              # ESLint
cd frontend && npm test                  # Vitest
cd frontend && npx vitest run src/hooks/useAssets.test.ts  # 단일 테스트

# Mobile (Flutter, 아직 미착수)
cd mobile && flutter pub get && flutter run
cd mobile && flutter test
```

## 아키텍처

### 3-tier 구조

```
[Flutter App] ──┐
                ├── REST API (JWT) ──→ [Spring Boot :4590] ──→ [MSSQL :1433]
[Next.js :4580] ┘
```

### Backend 레이어 흐름

```
Controller (@RestController)
  → DTO (Record: *Request / *Response)
    → Service (@Service, 생성자 주입)
      → Repository (Spring Data JPA)
        → Entity (@Entity, @Setter 금지)
```

- **API 응답 envelope**: `ApiResponse<T>` — `{ success, data, message, timestamp }`, `PageResponse<T>` — 페이지네이션
- **예외 처리**: `ErrorCode` enum → `BusinessException` → `GlobalExceptionHandler` (@RestControllerAdvice)
- **인증**: JWT (Access 30분 + Refresh 7일), `JwtTokenProvider` → `JwtAuthenticationFilter` (SecurityFilterChain)
- **스케줄러**: `OverdueCheckScheduler` (반납 연체 체크), `NotificationScheduler` (알림 발송)
- **파일 업로드**: `FileUploadUtil` → `./uploads/` (max 10MB, jpg/jpeg/png/webp)
- **SQL 마이그레이션**: `backend/src/main/resources/sql/V{NNN}__description.sql` — JPA hibernate.ddl-auto=none, SQL 직접 관리
- **테스트 데이터**: `TestDataInitializer` (config/) — local 프로파일 시 시드 데이터 자동 로드

### Frontend 레이어 흐름

```
App Router (page.tsx)
  → React Query hooks (useAssets, useDashboard...)
    → API 함수 (lib/api/*.ts)
      → Axios 인스턴스 (interceptor: JWT 자동 첨부, 401 시 refresh)
```

- **상태관리**: Zustand (`authStore`, `uiStore`) + TanStack React Query (서버 상태)
- **폼 처리**: react-hook-form + zod validation
- **인증 라우팅**: `(authenticated)/` 그룹 레이아웃 → `AuthGuard` 컴포넌트
- **토큰 관리**: `lib/auth/token.ts` — localStorage 기반, Axios 인터셉터가 401 시 자동 refresh 후 재시도 (큐잉 방식)
- **UI**: Tailwind CSS 4 + shadcn/ui + lucide-react 아이콘 + sonner 토스트
- **디자인 시스템**: `frontend/DESIGN.md` — Notion-inspired 디자인 가이드. UI 작업 시 반드시 참조

### 주요 도메인 관계

```
User ←(registeredBy)── Asset ←(asset)── Rental ──(borrower)→ User
                          ↑
                    AssetCategory (3단계 계층: 대분류/중분류/소분류)
```

### Mobile (Flutter) 레이어 흐름

```
GoRouter (AppRouter, 인증 guard)
  → Screen (Riverpod ConsumerWidget)
    → AsyncNotifier (상태관리)
      → Repository 구현체 (Dio + ApiClient)
        → REST API
```

- **상태관리**: Riverpod v2 (AsyncNotifier + FamilyAsyncNotifier)
- **네비게이션**: GoRouter v15 (4탭: 대시보드/장비/대여/알림 + 인증 guard)
- **네트워크**: Dio v5 + AuthInterceptor (401 자동 refresh + 큐잉)
- **토큰 저장**: FlutterSecureStorage
- **디자인**: Material 3 + Notion-inspired 커스텀 테마 (AppColors, AppTheme)
- **구조**: Feature-First (features/{도메인}/data·domain·presentation)

## ⚠️ Next.js 16 주의사항

이 프로젝트는 Next.js 16을 사용하며, 이전 버전과 **Breaking Changes**가 있음.
코드 작성 전 반드시 `frontend/node_modules/next/dist/docs/`의 관련 가이드를 읽을 것.
Deprecation 경고에 주의. shadcn/ui v2는 내부적으로 base-ui를 사용하므로, 컴포넌트 API가 이전 버전(Radix 기반)과 다름 — `render` prop 패턴 등에 유의.

## API 엔드포인트 (모두 `/api/v1/` prefix)

| 도메인 | 엔드포인트 | 비고 |
|--------|-----------|------|
| Auth | `POST /auth/login`, `/auth/refresh`, `/auth/logout` | login/refresh는 공개 |
| Assets | CRUD + `PUT /{id}/status` | 상태: IN_USE, RENTED, BROKEN, IN_STORAGE, DISPOSED |
| Rentals | CRUD + `/return`, `/extend`, `/cancel`, `/dashboard`, `/overdue` | 연장 최대 1회(+14일) |
| Categories | CRUD + `GET /tree` | 3단계 계층 |
| Users | CRUD + `GET /me` | Role: COUNSELOR, MANAGER |
| Notifications | 목록, 읽음 처리, 미읽음 카운트 | FCM + Email |

## 환경 설정

- Backend `.env`: `backend/src/main/resources/.env` (spring-dotenv로 로드)
- Frontend `.env.local`: `NEXT_PUBLIC_API_URL=http://localhost:4590`
- CORS 허용 origin: `CorsConfig.java`에 명시 (와일드카드 * 금지)

## 커밋 컨벤션

```
<type>: <description>

Types: feat, fix, refactor, docs, test, chore, perf, ci
```

## 핵심 규칙

### 보안 (Privacy-First)
- AI 촬영 이미지는 **절대 외부 서버로 전송하지 않음** (온디바이스 처리)
- JWT Secret, DB Password 등 시크릿은 **환경변수**에서 로드
- SQL은 반드시 **파라미터 바인딩** 사용 (문자열 결합 금지)
- CORS origin 명시 (와일드카드 * 금지)

### 코딩
- Java: 생성자 주입, Record DTO, @Setter 금지, `@Autowired` 금지
- Flutter: Feature-First 구조, Sealed class 상태 패턴
- Next.js: Server/Client Component 분리, `any` 타입 금지, `useEffect` 데이터 fetching 금지
- MSSQL: NVARCHAR (한글), DATETIME2, OFFSET-FETCH 페이지네이션

### 테스트
- TDD 필수 (RED → GREEN → REFACTOR)
- 커버리지 80% 이상
- AAA 패턴 (Arrange-Act-Assert)

## 에이전트 사용 가이드

| 상황 | 에이전트 |
|------|---------|
| 새 기능 구현 계획 | `planner` |
| 아키텍처 결정 | `architect` |
| 새 기능/버그 수정 | `tdd-guide` |
| 코드 작성 후 | `code-reviewer` |
| 보안 관련 코드 | `security-reviewer` |
| 빌드 실패 | `build-error-resolver` |
| API 설계 | `api-designer` |
| DB 변경 | `db-migrator` |
| 문서 업데이트 | `doc-updater` |

## 진행 현황 추적

개발 단계 시작/완료 시 반드시 `docs/progress.md`와 Notion 페이지(ID: 34f2af5a-9ceb-8174-8067-c0753266d8fc)를 동시 업데이트할 것.
상세 규칙: `.claude/rules/progress-tracking.md` 참조.

## 외부 리소스
- **GitHub**: https://github.com/no1fc/jobmoa_EquipmentManagement
- **Notion**: 프로젝트 관리 페이지 (ID: 34f2af5a-9ceb-8174-8067-c0753266d8fc)
