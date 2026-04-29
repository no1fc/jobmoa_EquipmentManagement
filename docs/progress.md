# 개발 진행 현황

> 최종 업데이트: 2026-04-29 (B7 사용자 관리 완료)

## 전체 진행률

| Phase | 내용 | 상태 | 진행률 |
|-------|------|------|--------|
| **Phase A** | Backend + DB | ✅ 완료 | 100% |
| **Phase B** | Web Client (Next.js) | ✅ 완료 | 100% |
| **Phase C** | Mobile Client (Flutter) | ⬜ 미착수 | 0% |

**전체 진행률: 69% (Phase A 19일 + Phase B 10일 = 29일 of 42일)**

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
| B3 | 대시보드 | 1.5 | ✅ 완료 |
| B4 | 장비 관리 화면 | 2.5 | ✅ 완료 |
| B5 | 대여 관리 화면 | 2 | ✅ 완료 |
| B6 | 알림 UI | 0.5 | ✅ 완료 |
| B7 | 사용자 관리 | 1 | ✅ 완료 |

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

### B3. 대시보드 (1.5일) — ✅ 완료
- **완료일:** 2026-04-28
- **React Query 커스텀 훅** (`hooks/useDashboard.ts`):
  - `useDashboardStats()` — 대여 대시보드 통계 (5분 자동 갱신)
  - `useOverdueRentals()` — 연체 대여 목록 (5분 자동 갱신)
  - `useAssetSummary()` — 장비 상태 요약
- **StatCards** (`components/dashboard/StatCards.tsx`):
  - 4개 통계 카드: 대여 중(blue), 연체(red), 반납 임박(amber), 오늘 반납(green)
  - Skeleton 로딩 UI, 조건부 색상 (0건일 때 muted)
- **OverdueRentalsTable** (`components/dashboard/OverdueRentalsTable.tsx`):
  - 연체 대여 테이블 (장비명/장비코드/대여자/반납기한/연체일수)
  - 빈 상태(긍정 메시지), 에러 상태, Skeleton 로딩
  - 10건 초과 시 전체 보기 링크 (`/rentals?status=OVERDUE`)
- **QuickActions** (`components/dashboard/QuickActions.tsx`):
  - 빠른 메뉴 3개: 장비 등록, 대여 관리, 장비 목록
  - base-ui `render` prop으로 Button + Link 연동
- **대시보드 페이지** (`app/(authenticated)/dashboard/page.tsx`):
  - Client Component, 3개 훅으로 데이터 fetch
  - 레이아웃: StatCards → (OverdueRentalsTable 2/3 + QuickActions 1/3)
- **빌드:** `npm run build` PASS (package.json build 스크립트 수정: `-p 4580` 플래그 제거)

### B4. 장비 관리 화면 (2.5일) — ✅ 완료
- **완료일:** 2026-04-28
- **React Query 커스텀 훅** (`hooks/useAssets.ts`, `hooks/useCategories.ts`):
  - `useAssets(params)` — 장비 목록 (필터/페이지네이션, keepPreviousData)
  - `useAsset(id)` — 장비 상세
  - `useCreateAsset()`, `useUpdateAsset()`, `useDeleteAsset()`, `useUpdateAssetStatus()` — CRUD mutations + toast 알림
  - `useCategoryTree()` — 카테고리 트리 (10분 staleTime)
- **Zod 검증 스키마** (`lib/validations/asset.ts`):
  - `assetFormSchema` — categoryId(필수), assetName(필수), 선택 필드 10개
- **공통 컴포넌트** (`components/assets/`):
  - `AssetStatusBadge` — 5개 상태별 색상 배지 (blue/purple/red/gray/amber)
  - `CategoryCascadeSelect` — 3단계 캐스케이드 셀렉트 (대/중/소분류), allowAll 옵션
  - `AssetImageUpload` — 이미지 선택/미리보기/삭제, 5MB 제한, Next.js Image 사용
- **장비 목록 페이지** (`app/(authenticated)/assets/page.tsx`):
  - `AssetFilters` — 검색(debounce 300ms) + 상태 필터 + 카테고리 캐스케이드 + 초기화
  - `AssetTable` — 정렬 가능 헤더(장비코드/장비명/등록일), Skeleton 로딩, 빈 상태
  - `AssetPagination` — 이전/다음, "N/M 페이지 (총 X건)" 표시
- **장비 등록 페이지** (`app/(authenticated)/assets/new/page.tsx`):
  - `AssetForm` — react-hook-form + zod, 2컬럼 그리드, 13개 필드
  - 카테고리 Controller, 상태등급 Select, 이미지 업로드 통합
- **장비 수정 페이지** (`app/(authenticated)/assets/[id]/edit/page.tsx`):
  - 기존 데이터 로드 → AssetForm(edit 모드), Next.js 16 async params
- **장비 상세 페이지** (`app/(authenticated)/assets/[id]/page.tsx`):
  - `AssetDetailInfo` — 4개 Card 섹션 (기본정보/장비상세/위치부서/기술사양)
  - `StatusChangeDialog` — 상태 변경 다이얼로그 (현재 상태 제외 옵션)
  - `DeleteConfirmDialog` — 삭제 확인 (MANAGER 역할만 표시)
  - 액션 버튼: 수정/상태변경/삭제 (역할 기반)
- **빌드:** `npm run build` PASS, `npm run lint` PASS

### B5. 대여 관리 화면 (2일) — ✅ 완료
- **완료일:** 2026-04-29
- **React Query 커스텀 훅** (`hooks/useRentals.ts`):
  - `useRentals(params)` — 대여 목록 (필터/페이지네이션, keepPreviousData)
  - `useRental(id)` — 대여 상세
  - `useCreateRental()`, `useReturnRental()`, `useExtendRental()`, `useCancelRental()` — CRUD mutations + toast 알림
- **Zod 검증 스키마** (`lib/validations/rental.ts`):
  - `rentalCreateSchema` — assetId(필수), dueDays(1~30), borrowerName/rentalReason(선택)
  - `rentalReturnSchema` — returnCondition(선택)
  - `rentalExtendSchema` — extensionDays(1~14)
- **공통 컴포넌트** (`components/rentals/`):
  - `RentalStatusBadge` — 4개 상태별 색상 배지 (blue/red/green/gray)
  - `RentalFilters` — 검색(debounce 300ms) + 상태 필터 + 초기화
  - `RentalTable` — 정렬 가능 헤더(대여일/반납기한), 연체 행 강조(bg-red), Skeleton 로딩
  - `RentalPagination` — 이전/다음, 페이지 정보 표시
  - `CreateRentalDialog` — 대여 등록 (react-hook-form + zod, 장비ID/대여자/사유/기간)
  - `ReturnDialog` — 반납 처리 (반납 상태 메모)
  - `ExtendDialog` — 연장 (1~14일, 최대 1회)
  - `CancelConfirmDialog` — 취소 확인
  - `RentalDetailInfo` — 상세 정보 2개 Card (대여정보/장비정보)
- **대여 목록 페이지** (`app/(authenticated)/rentals/page.tsx`):
  - 필터 + 테이블 + 페이지네이션 + 새 대여 다이얼로그
- **대여 상세 페이지** (`app/(authenticated)/rentals/[id]/page.tsx`):
  - 상세 정보 + 반납/연장/취소 액션 버튼 (상태 기반 조건부 표시)
- **빌드:** `npm run build` PASS, `npm run lint` PASS

### B6. 알림 UI (0.5일) — ✅ 완료
- **완료일:** 2026-04-29
- **React Query 커스텀 훅** (`hooks/useNotifications.ts`):
  - `useNotifications(params)` — 알림 목록 (isRead 필터, 페이지네이션, keepPreviousData)
  - `useUnreadCount()` — 미읽음 카운트 (30초 refetchInterval 폴링)
  - `useMarkAsRead()`, `useMarkAllAsRead()` — 읽음 처리 mutations
- **Header 알림 벨** (`components/layout/NotificationBell.tsx`):
  - 벨 아이콘 + Notion Blue 미읽음 카운트 배지 (99+ 표시)
  - Header에 UserMenu 왼쪽 배치
- **알림 아이템** (`components/notifications/NotificationItem.tsx`):
  - 타입별 아이콘 (RENTAL_DUE: 시계, RENTAL_OVERDUE: 경고, SYSTEM: 정보)
  - 읽음/미읽음 상태 표시 (파란 점 + 폰트 굵기)
  - 상대 시간 표시 ("3분 전", "2시간 전")
  - 클릭 시 읽음 처리 + referenceId 기반 네비게이션
- **알림 목록** (`components/notifications/NotificationList.tsx`):
  - 필터: 전체 / 읽지 않음 (토글 버튼)
  - "모두 읽음" 버튼 (미읽음 있을 때만)
  - Skeleton 로딩, 빈 상태 (BellOff 아이콘), 페이지네이션
- **알림 페이지** (`app/(authenticated)/notifications/page.tsx`):
  - 스텁 → 완성: NotificationList 통합
- **빌드:** `npm run build` PASS, `npm run lint` PASS

### B7. 사용자 관리 (1일) — ✅ 완료
- **완료일:** 2026-04-29
- **React Query 커스텀 훅** (`hooks/useUsers.ts`):
  - `useUsers(params)` — 사용자 목록 (역할/검색 필터, 페이지네이션)
  - `useUser(id)` — 사용자 상세
  - `useCreateUser()`, `useUpdateUser()`, `useDeleteUser()` — CRUD mutations
  - `useMyProfile()`, `useUpdateProfile()`, `useChangePassword()` — 프로필 관련
- **Zod 검증 스키마** (`lib/validations/user.ts`):
  - `userCreateSchema` — 이메일(필수/형식), 비밀번호(8자+), 이름(필수), 역할(필수)
  - `userUpdateSchema` — 이름(필수), 역할(필수), 지점/연락처(선택)
  - `profileUpdateSchema` — 이름(필수), 연락처(선택)
  - `passwordChangeSchema` — 현재/새/확인 비밀번호 + 일치 검증
- **사용자 관리 컴포넌트** (`components/users/`):
  - `RoleBadge` — 역할별 색상 배지 (관리자: purple, 상담사: blue)
  - `UserFilters` — 검색(debounce 300ms) + 역할 필터 + 초기화
  - `UserTable` — 이름/이메일/역할/지점/연락처/상태/관리, Skeleton 로딩
  - `CreateUserDialog` — 등록 폼 (6개 필드, react-hook-form + zod)
  - `EditUserDialog` — 수정 폼 (4개 필드, 기존 데이터 로드)
  - `DeleteUserDialog` — 비활성화 확인
- **사용자 관리 페이지** (`app/(authenticated)/users/page.tsx`):
  - 목록 + 필터 + 페이지네이션 + 등록/수정/비활성화 다이얼로그 통합
- **프로필 페이지** (`app/(authenticated)/profile/page.tsx`):
  - 기본 정보 카드: 이메일/역할/지점(읽기전용) + 이름/연락처(수정 가능)
  - 비밀번호 변경 카드: 현재/새/확인 비밀번호 + 일치 검증
  - Skeleton 로딩 상태
- **빌드:** `npm run build` PASS, `npm run lint` PASS

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
