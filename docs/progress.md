# 개발 진행 현황

> 최종 업데이트: 2026-04-28

## 전체 진행률

| Phase | 내용 | 상태 | 진행률 |
|-------|------|------|--------|
| **Phase A** | Backend + DB | ✅ 완료 | 100% |
| **Phase B** | Web Client (Next.js) | 🔨 진행중 | 30% (B1~B2 완료) |
| **Phase C** | Mobile Client (Flutter) | ⬜ 미착수 | 0% |

**전체 진행률: 52% (Phase A 19일 + Phase B 2.5일 = 21.5일 of 42일)**

---

## Phase A: Backend + DB (19일) — ✅ 완료

### A1. 프로젝트 초기화 (2일) — ✅ 완료
- **완료일:** 2026-04-27
- Spring Boot 3.5.0 + Java 21 + Gradle 프로젝트 생성
- 핵심 의존성: spring-boot-starter-web/data-jpa/security/validation/mail, mssql-jdbc, jjwt-0.12.6, springdoc-openapi-2.8.6, firebase-admin-9.4.3, lombok
- application.yml (환경변수 기반 설정), application-local.yml
- 10개 패키지 구조 생성 (config, domain, repository, service, controller, dto/request, dto/response, security, exception, util)
- 임시 SecurityConfig (permitAll), SwaggerConfig (OpenAPI 3.0 + JWT Bearer)
- `./gradlew build` — BUILD SUCCESSFUL

### A2. DB 스키마 생성 (1일) — ✅ 완료
- **완료일:** 2026-04-27
- SQL 마이그레이션 7개 파일 생성:
  - V001: `users` 테이블 (email, role, fcm_token, is_active)
  - V002: `asset_categories` 테이블 (계층 3단계, 자기참조 FK)
  - V003: `assets` 테이블 (asset_code, status, ai_classified, technical_specs JSON)
  - V004: `rentals` 테이블 (extension_count 추가, max 1회)
  - V005: `notifications` 테이블 (reference_id 추가)
  - V006: 시드 데이터 — 16개 카테고리 (3대분류/8중분류/5소분류)
  - V007: 시드 데이터 — admin@jobmoa.kr 관리자 계정

### A3. 공통 인프라 (2일) — ✅ 완료
- **완료일:** 2026-04-27
- `BaseTimeEntity` — @MappedSuperclass, JPA Auditing (createdAt, updatedAt)
- `ApiResponse<T>` — 통일 응답 envelope (success, data, message, timestamp)
- `PageResponse<T>` — 페이지네이션 응답 (content, page, size, totalElements, totalPages, last)
- `ErrorCode` enum — 30+ 에러 코드 (Auth, User, Category, Asset, Rental, Notification, File)
- 커스텀 예외: BusinessException, NotFoundException, DuplicateException, UnauthorizedException
- `GlobalExceptionHandler` — @RestControllerAdvice (Validation, FileSize, 일반 예외 처리)
- `CorsConfig` — 명시적 origin (localhost:3000, :8080), credentials 허용
- `WebMvcConfig` — /uploads/** 정적 리소스 매핑
- `FileUploadUtil` — 파일 검증(확장자/크기), 저장, 삭제

### A4. 인증 모듈 (3일) — ✅ 완료
- **완료일:** 2026-04-27
- `User` Entity + `Role` enum (COUNSELOR, MANAGER)
- `UserRepository` — findByEmail, existsByEmail, 필터 검색
- `JwtTokenProvider` — Access Token(30분) + Refresh Token(7일) 생성/검증
- `JwtAuthenticationFilter` — OncePerRequestFilter, Bearer 토큰 파싱
- `CustomUserDetails` / `CustomUserDetailsService`
- `SecurityConfig` — JWT 필터 통합, @EnableMethodSecurity, PUBLIC_URLS 설정
- **API 엔드포인트:**
  - `POST /api/v1/auth/login` — 로그인
  - `POST /api/v1/auth/refresh` — 토큰 갱신
  - `POST /api/v1/auth/logout` — 로그아웃

### A5. 사용자 관리 (1.5일) — ✅ 완료
- **완료일:** 2026-04-27
- DTO: UserCreateRequest, UserUpdateRequest, ProfileUpdateRequest, PasswordChangeRequest, UserResponse
- `UserService` — CRUD, 프로필 수정, 비밀번호 변경
- **API 엔드포인트 (8개):**
  - `GET /api/v1/users` — 목록 (MANAGER, 페이지네이션/역할 필터/검색)
  - `GET /api/v1/users/{id}` — 상세 (MANAGER)
  - `POST /api/v1/users` — 생성 (MANAGER)
  - `PUT /api/v1/users/{id}` — 수정 (MANAGER)
  - `DELETE /api/v1/users/{id}` — 비활성화 (MANAGER, soft delete)
  - `GET /api/v1/users/me` — 내 프로필
  - `PUT /api/v1/users/me` — 프로필 수정
  - `PUT /api/v1/users/me/password` — 비밀번호 변경

### A6. 카테고리 관리 (1일) — ✅ 완료
- **완료일:** 2026-04-27
- `AssetCategory` Entity — 자기참조 (parent/children), 3단계 계층
- DTO: CategoryCreateRequest, CategoryUpdateRequest, CategoryResponse, CategoryTreeResponse
- `CategoryService` — CRUD, 트리 조회, 하위 카테고리 조회
- **API 엔드포인트 (7개):**
  - `GET /api/v1/categories` — 전체 목록 (?level= 필터)
  - `GET /api/v1/categories/tree` — 트리 구조
  - `GET /api/v1/categories/{id}` — 단건 조회
  - `GET /api/v1/categories/{id}/children` — 하위 카테고리
  - `POST /api/v1/categories` — 생성 (MANAGER)
  - `PUT /api/v1/categories/{id}` — 수정 (MANAGER)
  - `DELETE /api/v1/categories/{id}` — 삭제 (MANAGER, 연결 자산/하위 없을 때만)

### A7. 장비 관리 (3일) — ✅ 완료
- **완료일:** 2026-04-27
- `Asset` Entity + `AssetStatus` enum (IN_USE, RENTED, BROKEN, IN_STORAGE, DISPOSED)
- `AssetCodeGenerator` — AST-YYYYMM-NNNN 형식 자동 생성
- DTO: AssetCreateRequest, AssetUpdateRequest, AssetStatusRequest, AssetResponse, AssetDetailResponse (카테고리 경로 포함), AssetSummaryResponse
- `AssetService` — CRUD, 상태 변경, 이미지 업로드, 대시보드 요약
- **API 엔드포인트 (7개):**
  - `GET /api/v1/assets` — 목록 (상태/카테고리/위치/검색 필터, 페이지네이션)
  - `GET /api/v1/assets/{id}` — 상세 (카테고리 경로, 등록자 정보)
  - `POST /api/v1/assets` — 등록 (Multipart: JSON + image)
  - `PUT /api/v1/assets/{id}` — 수정 (Multipart)
  - `DELETE /api/v1/assets/{id}` — 삭제 (MANAGER, 대여 중 아닐 때만)
  - `PATCH /api/v1/assets/{id}/status` — 상태 변경
  - `GET /api/v1/assets/summary` — 대시보드용 상태별 카운트

### A8. 대여 관리 (3.5일) — ✅ 완료
- **완료일:** 2026-04-27
- `Rental` Entity + `RentalStatus` enum (RENTED, RETURNED, OVERDUE, CANCELLED)
- DTO: RentalCreateRequest (dueDays 1-30), RentalReturnRequest, RentalExtendRequest (max 14일), RentalResponse, RentalDashboardResponse
- `RentalService` — 대여 생성/반납/연장/취소, 대시보드, 연체 목록, 자산별 이력
- `OverdueCheckScheduler` — 매일 09:00 연체 자동 체크 (RENTED → OVERDUE)
- **비즈니스 규칙:**
  - 대여 가능: IN_USE 또는 IN_STORAGE 상태만
  - 대여 생성 → asset.status = RENTED
  - 반납 → asset.status = IN_USE, rental.returnDate = now
  - 연장: extension_count < 1, 최대 +14일
- **API 엔드포인트 (9개):**
  - `GET /api/v1/rentals` — 목록 (상태/대여자/자산 필터)
  - `GET /api/v1/rentals/{id}` — 상세
  - `POST /api/v1/rentals` — 대여 생성
  - `PUT /api/v1/rentals/{id}/return` — 반납
  - `PUT /api/v1/rentals/{id}/extend` — 연장
  - `PUT /api/v1/rentals/{id}/cancel` — 취소
  - `GET /api/v1/rentals/dashboard` — 대시보드 요약
  - `GET /api/v1/rentals/overdue` — 연체 목록
  - `GET /api/v1/rentals/asset/{assetId}/history` — 자산별 대여 이력

### A9. 알림 시스템 (2일) — ✅ 완료
- **완료일:** 2026-04-27
- `Notification` Entity + `NotificationType` (RENTAL_DUE, RENTAL_OVERDUE, SYSTEM) + `NotificationChannel` (IN_APP, EMAIL, PUSH)
- `NotificationService` — 알림 CRUD, 읽음 처리, 알림 생성
- `EmailService` — Spring Mail 비동기 이메일 발송
- `FcmService` — FCM 푸시 알림 스텁 (Phase C6에서 완성)
- `NotificationScheduler` — 매일 08:00 실행 (D-3, D-1 반납 예정 + 연체 알림)
- **API 엔드포인트 (4개):**
  - `GET /api/v1/notifications` — 내 알림 목록 (?isRead= 필터)
  - `GET /api/v1/notifications/unread-count` — 읽지 않은 수
  - `PUT /api/v1/notifications/{id}/read` — 읽음 처리
  - `PUT /api/v1/notifications/read-all` — 전체 읽음

### 추가: V008 부서 컬럼 (2026-04-28)
- **완료일:** 2026-04-28
- `assets` 테이블에 `managing_department` (관리 부서), `using_department` (사용 부서) NVARCHAR(100) 컬럼 추가
- Asset Entity, Request/Response DTO, Service, Frontend 타입 일괄 반영

---

## Phase B: Web Client — Next.js (10일) — 🔨 진행중

| 단계 | 내용 | 예상 일수 | 상태 |
|------|------|-----------|------|
| B1 | 프로젝트 초기화 | 1 | ✅ 완료 |
| B2 | 인증 (로그인) | 1.5 | ✅ 완료 |
| B3 | 대시보드 | 1.5 | ⬜ |
| B4 | 장비 관리 화면 | 2.5 | ⬜ |
| B5 | 대여 관리 화면 | 2 | ⬜ |
| B6 | 알림 UI | 0.5 | ⬜ |
| B7 | 사용자 관리 | 1 | ⬜ |

### B1. 프로젝트 초기화 (1일) — ✅ 완료
- **완료일:** 2026-04-28
- Next.js 16.2.4 (App Router, Turbopack) + TypeScript
- **의존성:** axios (보안 검증 통과), @tanstack/react-query v5, zustand v5, react-hook-form, zod, @hookform/resolvers
- **UI:** shadcn/ui v2 (base-ui 기반) — 14개 컴포넌트 설치 (button, input, select, dialog, badge, card, table, dropdown-menu, sonner, separator, skeleton, sheet, label, textarea)
- **인프라:**
  - axios 인스턴스 (JWT 인터셉터, 401 자동 refresh)
  - 토큰 관리 유틸 (localStorage)
  - TypeScript 타입 6개 파일 (백엔드 38 API 대응)
  - API 함수 모듈 6개 파일 (전체 엔드포인트)
  - Zustand 스토어 (auth, ui)
  - QueryProvider + AuthProvider
- **레이아웃:** Sidebar (역할 기반 메뉴) + Header (UserMenu) + (authenticated) route group
- **페이지 스텁:** 9개 라우트 (login, dashboard, assets, rentals, notifications, users, profile)
- **빌드:** `npm run build` PASS, `npm run lint` PASS

### B2. 인증 — 로그인 (1.5일) — ✅ 완료
- **완료일:** 2026-04-28
- `LoginForm` — react-hook-form + zod 검증 (이메일 형식, 비밀번호 8자+)
- API 연동: login → setTokens → setUser → /dashboard 리다이렉트
- 에러 처리: API 실패 메시지 표시, 로딩 상태
- `AuthGuard` — 토큰 미보유 시 /login 리다이렉트
- (authenticated) layout에 AuthGuard 래핑

---

## Phase C: Mobile Client — Flutter (13일) — ⬜ 미착수

| 단계 | 내용 | 예상 일수 | 상태 |
|------|------|-----------|------|
| C1 | 프로젝트 초기화 | 1.5 | ⬜ |
| C2 | 인증 | 1.5 | ⬜ |
| C3 | 장비 관리 화면 | 2 | ⬜ |
| C4 | 대여 관리 화면 | 2 | ⬜ |
| C5 | AI 장비 등록 | 4 | ⬜ |
| C6 | 알림 (FCM) | 2 | ⬜ |

---

## API 엔드포인트 요약 (총 38개)

| 모듈 | 엔드포인트 수 | 인증 필요 |
|------|-------------|-----------|
| Auth | 3 | 로그인/갱신은 No, 로그아웃은 Yes |
| User | 8 | 관리(MANAGER) 5개 + 본인(ALL) 3개 |
| Category | 7 | 조회(ALL) 4개 + 관리(MANAGER) 3개 |
| Asset | 7 | 삭제(MANAGER) 1개 + 나머지(ALL) |
| Rental | 9 | ALL |
| Notification | 4 | ALL |

---

## SQL 마이그레이션 현황

| 파일 | 내용 | MSSQL 적용 |
|------|------|-----------|
| V001 | users 테이블 | 수동 실행 필요 |
| V002 | asset_categories 테이블 | 수동 실행 필요 |
| V003 | assets 테이블 | 수동 실행 필요 |
| V004 | rentals 테이블 | 수동 실행 필요 |
| V005 | notifications 테이블 | 수동 실행 필요 |
| V006 | 카테고리 시드 (16개) | 수동 실행 필요 |
| V007 | 관리자 계정 시드 | 수동 실행 필요 |
| V008 | assets 부서 컬럼 추가 | 수동 실행 필요 |

---

## 빌드 상태

| 항목 | 상태 | 명령어 |
|------|------|--------|
| Backend 컴파일 | ✅ PASS | `./gradlew build` |
| Backend 테스트 | ✅ PASS | `./gradlew test` (H2 인메모리) |
| Frontend 빌드 | ✅ PASS | `npm run build` |
| Frontend Lint | ✅ PASS | `npm run lint` |
| Mobile | ⬜ 미착수 | — |

---

## 기술 스택 변경 이력

| 날짜 | 항목 | 변경 내용 |
|------|------|----------|
| 2026-04-28 | shadcn/ui | v2 (base-ui 기반) 적용, toast → sonner 교체 |
| 2026-04-28 | Next.js | v16.2.4 적용, middleware → proxy 경고 확인 |
| 2026-04-28 | DB 스키마 | V008: assets에 managing_department, using_department 추가 |
