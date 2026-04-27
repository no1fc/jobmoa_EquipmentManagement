# 마스터 개발 계획: 국민취업지원제도 AI 장비 관리 시스템

## Context
국민취업지원제도 지점 상담사용 AI 기반 장비/자산 관리 시스템의 MVP 구현 계획.
1인 개발, 개발 순서: **Backend+DB → Web(Next.js) → Mobile(Flutter+AI)**.
총 42일(약 8.5주) 예상.

## 추가 확정사항
- 사진 저장: 서버 로컬 파일시스템 (`uploads/`)
- 대여 규칙: 최대 30일 + 1회 연장(+14일), 연체 시 알림
- 상태 관리: Web=Zustand, Mobile=Riverpod

---

## PHASE A: BACKEND + DB (19일)

### A1. 프로젝트 초기화 (2일)

**생성 파일:**
```
backend/
├── build.gradle          # Spring Boot 3.4.x + Java 21 + 전체 의존성
├── settings.gradle
├── src/main/resources/
│   ├── application.yml   # MSSQL, JWT, Upload, Mail 설정 (환경변수)
│   └── application-local.yml
└── src/main/java/com/jobmoa/equipment/
    ├── EquipmentManagementApplication.java
    ├── config/ | domain/ | repository/ | service/
    ├── controller/ | dto/request/ | dto/response/
    ├── security/ | exception/ | util/
```

**핵심 의존성:** spring-boot-starter-web, data-jpa, security, validation, mail, mssql-jdbc, jjwt 0.12.x, lombok, springdoc-openapi, firebase-admin

**검증:** `./gradlew bootRun` → MSSQL 연결 성공, Swagger UI 접근 가능

---

### A2. DB 스키마 생성 (1일)

**SQL 마이그레이션 파일:**
```
backend/src/main/resources/sql/
├── V001__create_users_table.sql
├── V002__create_asset_categories_table.sql
├── V003__create_assets_table.sql      # extension_count 컬럼 추가
├── V004__create_rentals_table.sql
├── V005__create_notifications_table.sql
├── V006__seed_categories.sql          # 16개 카테고리 (3대/8중/5소)
└── V007__seed_admin_user.sql          # admin@jobmoa.kr
```

**rentals 테이블 추가 컬럼:** `extension_count INT DEFAULT 0`

---

### A3. 공통 인프라 (2일)

**생성 파일:**
```
dto/response/ApiResponse.java          # record: success, data, message, timestamp
dto/response/PageResponse.java         # record: content, page, size, totalElements, totalPages, last
domain/BaseTimeEntity.java             # @MappedSuperclass, createdAt, updatedAt
exception/GlobalExceptionHandler.java  # @RestControllerAdvice
exception/NotFoundException.java       # → 404
exception/DuplicateException.java      # → 409
exception/BusinessException.java       # → 400
exception/UnauthorizedException.java   # → 401
exception/ErrorCode.java               # enum
config/CorsConfig.java                 # 명시적 origin
config/SwaggerConfig.java              # OpenAPI 3.0
config/WebMvcConfig.java
config/FileStorageConfig.java          # /uploads/** 정적 리소스 매핑
util/FileUploadUtil.java               # 파일 검증, 저장, 경로 생성
```

---

### A4. 인증 모듈 (3일)

**생성 파일:**
```
domain/user/User.java                  # Entity
domain/user/Role.java                  # enum: COUNSELOR, MANAGER
repository/UserRepository.java
security/JwtTokenProvider.java         # 생성, 검증, 파싱
security/JwtAuthenticationFilter.java  # OncePerRequestFilter
security/CustomUserDetailsService.java
security/CustomUserDetails.java
security/SecurityConfig.java           # SecurityFilterChain
dto/request/LoginRequest.java
dto/request/TokenRefreshRequest.java
dto/response/LoginResponse.java        # accessToken, refreshToken, user
dto/response/TokenResponse.java
service/AuthService.java
controller/AuthController.java
```

**API 엔드포인트:**

| Method | URL | Auth | 설명 |
|--------|-----|------|------|
| POST | `/api/v1/auth/login` | No | `{email, password}` → `{accessToken, refreshToken, user}` |
| POST | `/api/v1/auth/refresh` | No | `{refreshToken}` → `{accessToken, refreshToken}` |
| POST | `/api/v1/auth/logout` | Yes | 로그아웃 |

**테스트:** JWT 생성/검증, 로그인 성공/실패, 보호 엔드포인트 401/200

---

### A5. 사용자 관리 (1.5일)

**API 엔드포인트:**

| Method | URL | Role | 설명 |
|--------|-----|------|------|
| GET | `/api/v1/users` | MANAGER | 사용자 목록 (페이지네이션, 역할 필터, 검색) |
| GET | `/api/v1/users/{id}` | MANAGER | 사용자 상세 |
| POST | `/api/v1/users` | MANAGER | 사용자 생성 `{email, password, name, role, branchName, phone}` |
| PUT | `/api/v1/users/{id}` | MANAGER | 사용자 수정 |
| DELETE | `/api/v1/users/{id}` | MANAGER | 비활성화 (soft delete) |
| GET | `/api/v1/users/me` | ALL | 내 프로필 |
| PUT | `/api/v1/users/me` | ALL | 프로필 수정 `{name, phone}` |
| PUT | `/api/v1/users/me/password` | ALL | 비밀번호 변경 `{currentPassword, newPassword}` |

---

### A6. 카테고리 관리 (1일)

**API 엔드포인트:**

| Method | URL | Role | 설명 |
|--------|-----|------|------|
| GET | `/api/v1/categories` | ALL | 전체 목록 (`?level=1` 필터 가능) |
| GET | `/api/v1/categories/tree` | ALL | 트리 구조 (중첩 children) |
| GET | `/api/v1/categories/{id}` | ALL | 단건 조회 |
| GET | `/api/v1/categories/{id}/children` | ALL | 하위 카테고리 |
| POST | `/api/v1/categories` | MANAGER | 생성 `{parentId?, categoryName, categoryLevel}` |
| PUT | `/api/v1/categories/{id}` | MANAGER | 수정 |
| DELETE | `/api/v1/categories/{id}` | MANAGER | 삭제 (연결 자산 없을 때만) |

---

### A7. 장비 관리 (3일)

**생성 파일:**
```
domain/asset/Asset.java
domain/asset/AssetStatus.java          # enum: IN_USE, RENTED, BROKEN, IN_STORAGE, DISPOSED
repository/AssetRepository.java        # 커스텀 검색/필터 쿼리
dto/request/AssetCreateRequest.java    # @Valid: assetName, categoryId 필수
dto/request/AssetUpdateRequest.java
dto/request/AssetSearchRequest.java
dto/response/AssetResponse.java
dto/response/AssetDetailResponse.java  # + technicalSpecs, categoryPath
dto/response/AssetSummaryResponse.java # 상태별 카운트
service/AssetService.java
controller/AssetController.java
util/AssetCodeGenerator.java           # AST-YYYYMM-NNNN 형식
```

**API 엔드포인트:**

| Method | URL | Role | 설명 |
|--------|-----|------|------|
| GET | `/api/v1/assets` | ALL | 목록 `?page=0&size=20&status=&categoryId=&search=&location=&sort=createdAt,desc` |
| GET | `/api/v1/assets/{id}` | ALL | 상세 (카테고리 경로, 등록자 정보 포함) |
| POST | `/api/v1/assets` | ALL | 등록 (Multipart: JSON + image) → asset_code 자동생성 |
| PUT | `/api/v1/assets/{id}` | ALL | 수정 (Multipart: JSON + image) |
| DELETE | `/api/v1/assets/{id}` | MANAGER | 삭제 (대여중이 아닐 때만) |
| PATCH | `/api/v1/assets/{id}/status` | ALL | 상태 변경 `{status}` |
| GET | `/api/v1/assets/summary` | ALL | 대시보드용 상태별 카운트 |

**이미지 업로드:** `uploads/assets/{assetId}_{uuid}.{ext}`, 최대 10MB, jpg/png/webp

**자산 코드:** `AST-YYYYMM-NNNN` (월별 시퀀스)

---

### A8. 대여 관리 (3.5일)

**생성 파일:**
```
domain/rental/Rental.java
domain/rental/RentalStatus.java        # enum: RENTED, RETURNED, OVERDUE, CANCELLED
repository/RentalRepository.java
dto/request/RentalCreateRequest.java   # assetId, borrowerId?, rentalReason, borrowerName?, dueDays(1-30)
dto/request/RentalReturnRequest.java   # returnCondition?
dto/request/RentalExtendRequest.java   # extensionDays(max 14)
dto/response/RentalResponse.java
dto/response/RentalDetailResponse.java
dto/response/RentalDashboardResponse.java  # totalActive, overdueCount, dueSoon, returnedToday
service/RentalService.java
controller/RentalController.java
scheduler/OverdueCheckScheduler.java   # 매일 09:00 연체 체크
```

**API 엔드포인트:**

| Method | URL | Role | 설명 |
|--------|-----|------|------|
| GET | `/api/v1/rentals` | ALL | 목록 `?page=&status=&borrowerId=&assetId=&sort=dueDate,asc` |
| GET | `/api/v1/rentals/{id}` | ALL | 상세 |
| POST | `/api/v1/rentals` | ALL | 대여 생성 → asset.status=RENTED |
| PUT | `/api/v1/rentals/{id}/return` | ALL | 반납 → asset.status=IN_USE |
| PUT | `/api/v1/rentals/{id}/extend` | ALL | 연장 (최대 1회, +14일) |
| PUT | `/api/v1/rentals/{id}/cancel` | ALL | 취소 |
| GET | `/api/v1/rentals/dashboard` | ALL | 대시보드 요약 |
| GET | `/api/v1/rentals/overdue` | ALL | 연체 목록 |
| GET | `/api/v1/rentals/asset/{assetId}/history` | ALL | 자산별 대여 이력 |

**비즈니스 규칙:**
- 대여 가능: status=IN_USE 또는 IN_STORAGE인 자산만
- 대여 생성 → asset.status = RENTED
- 반납 → asset.status = IN_USE, rental.returnDate = now
- 연장: extension_count < 1, 최대 +14일
- 연체 스케줄러: 매일 09:00, dueDate < now인 RENTED → OVERDUE 변경

---

### A9. 알림 시스템 (2일)

**생성 파일:**
```
domain/notification/Notification.java
domain/notification/NotificationType.java    # RENTAL_DUE, RENTAL_OVERDUE, SYSTEM
domain/notification/NotificationChannel.java # IN_APP, EMAIL, PUSH
repository/NotificationRepository.java
dto/response/NotificationResponse.java
dto/response/UnreadCountResponse.java
service/NotificationService.java
service/EmailService.java                    # Spring Mail
service/FcmService.java                      # 스텁 (C6에서 완성)
controller/NotificationController.java
scheduler/NotificationScheduler.java         # 매일 08:00 알림 생성
config/FirebaseConfig.java
```

**API 엔드포인트:**

| Method | URL | 설명 |
|--------|-----|------|
| GET | `/api/v1/notifications` | 내 알림 `?page=&isRead=false` |
| GET | `/api/v1/notifications/unread-count` | 읽지 않은 수 (배지용) |
| PUT | `/api/v1/notifications/{id}/read` | 읽음 처리 |
| PUT | `/api/v1/notifications/read-all` | 전체 읽음 |

**스케줄러:** D-3, D-1 반납 예정 알림 + 연체 알림 (IN_APP + PUSH + EMAIL)

---

## PHASE B: WEB CLIENT — Next.js (10일)

### B1. 프로젝트 초기화 (1일)

**생성 파일:**
```
frontend/
├── src/app/layout.tsx                 # Root Layout (Sidebar + Header)
├── src/app/globals.css
├── src/components/ui/                 # Button, Input, Select, Modal, Badge, Card,
│                                      # DataTable, Pagination, LoadingSpinner, Toast
├── src/components/layout/             # Sidebar, Header, NavItem, UserMenu
├── src/lib/api/client.ts              # JWT fetch wrapper (401→자동 refresh)
├── src/lib/auth/token.ts              # HttpOnly Cookie 관리
├── src/lib/utils/cn.ts                # className merge
├── src/types/                         # api.ts, user.ts, asset.ts, rental.ts, category.ts, notification.ts
├── src/store/authStore.ts             # Zustand
├── src/middleware.ts                   # 라우트 보호
├── next.config.ts | tailwind.config.ts | tsconfig.json
```

### B2. 인증 (1.5일)

| 화면 | 경로 | 설명 |
|------|------|------|
| 로그인 | `/login` | 이메일/비밀번호 폼, 에러 표시 |

**파일:** `app/login/page.tsx`, `components/auth/LoginForm.tsx`, `lib/api/auth.ts`

### B3. 대시보드 (1.5일)

| 화면 | 경로 | 설명 |
|------|------|------|
| 대시보드 | `/dashboard` | 통계 카드 4개 + 연체 테이블 + 반납 임박 목록 + 빠른 액션 |

**컴포넌트:** StatCard, OverdueRentalsTable, DueSoonList, QuickActions

### B4. 장비 관리 화면 (2.5일)

| 화면 | 경로 | 설명 |
|------|------|------|
| 장비 목록 | `/assets` | 검색, 필터(상태/카테고리), 페이지네이션, 정렬 |
| 장비 등록 | `/assets/new` | 전체 폼 + 이미지 업로드 + 카테고리 트리 선택 |
| 장비 상세 | `/assets/[id]` | 전체 정보 + 이미지 + 카테고리 경로 + 액션 |
| 장비 수정 | `/assets/[id]/edit` | 수정 폼 |

**컴포넌트:** AssetListTable, AssetFilterBar, AssetForm, AssetStatusBadge, AssetImageUpload, CategoryTreeSelect, AssetDeleteModal

### B5. 대여 관리 화면 (2일)

| 화면 | 경로 | 설명 |
|------|------|------|
| 대여 목록 | `/rentals` | 탭(전체/활성/연체/반납), 테이블, 반납/연장 버튼 |
| 대여 상세 | `/rentals/[id]` | 대여 정보 + 자산 정보 + 액션 |

**컴포넌트:** RentalListTable, RentalFilterBar, RentalStatusBadge, CreateRentalModal, ReturnRentalModal, ExtendRentalModal, RentalHistoryTable

**CreateRentalModal:** Step 1) 자산 검색/선택 → Step 2) 대여자/사유/기간(1-30일) → Step 3) 확인

### B6. 알림 UI (0.5일)

**컴포넌트:** NotificationBell (Header 내 벨 아이콘 + 배지), NotificationDropdown (최근 5건), NotificationItem
**페이지:** `/notifications` (전체 알림 목록)

### B7. 사용자 관리 (1일)

| 화면 | 경로 | 접근 | 설명 |
|------|------|------|------|
| 사용자 목록 | `/users` | MANAGER | 테이블 + 생성/수정 모달 |
| 내 프로필 | `/profile` | ALL | 정보 수정 + 비밀번호 변경 |

---

## PHASE C: MOBILE CLIENT — Flutter (13일)

### C1. 프로젝트 초기화 (1.5일)

**생성 파일:**
```
mobile/lib/
├── main.dart
├── core/
│   ├── config/app_config.dart | theme.dart
│   ├── constants/api_constants.dart | app_constants.dart | color_constants.dart
│   ├── network/api_client.dart | api_interceptor.dart | api_exceptions.dart
│   ├── storage/secure_storage.dart
│   ├── router/app_router.dart
│   └── utils/date_utils.dart | status_utils.dart
└── shared/
    ├── widgets/   # app_button, app_text_field, loading_overlay, status_badge, empty_state, error_widget
    └── models/    # api_response.dart, page_response.dart
```

**핵심 패키지:** flutter_riverpod, dio, go_router, flutter_secure_storage, image_picker, freezed, json_serializable

### C2. 인증 (1.5일)

**파일:** `features/auth/` (data/domain/presentation)
**화면:** LoginScreen, SplashScreen (자동 로그인 체크)
**상태:** Riverpod AuthNotifier (login, logout, refreshToken)

### C3. 장비 관리 화면 (2일)

**화면:**
- AssetListScreen — Pull-to-refresh, 무한 스크롤, 검색바, 필터 바텀시트
- AssetDetailScreen — 전체 정보 + 이미지 + 액션
- AssetCreateScreen — 전체 폼 + 이미지 촬영/갤러리 + 카테고리 드릴다운

**위젯:** AssetCard, AssetFilterSheet, CategoryPicker, AssetImageSection

### C4. 대여 관리 화면 (2일)

**화면:**
- RentalListScreen — 탭바(전체/활성/연체/반납), RentalCard, 무한 스크롤
- RentalCreateScreen — 3단계(자산 선택 → 정보 입력 → 확인)
- RentalReturnScreen — 반납 상태 입력 + 확인
- RentalDetailScreen — 대여 정보 + 자산 정보

**위젯:** RentalCard, RentalStatusBadge, DueDateIndicator (초록/노랑/빨강)

### C5. AI 장비 등록 (3-4일) ★ 핵심 기능

**파일:**
```
features/ai_register/
├── data/
│   ├── ai_model_service.dart          # Gemma 4 E2B 로드/추론/해제
│   ├── camera_service.dart            # 카메라 제어
│   └── ai_register_repository.dart
├── domain/
│   ├── ai_classification_result.dart  # @freezed: category1/2/3, name, confidence
│   └── ai_register_repository.dart
└── presentation/
    ├── ai_register_screen.dart        # 메인 오케스트레이터
    ├── camera_capture_screen.dart     # 전체 화면 카메라 + 촬영 버튼
    ├── ai_result_screen.dart          # AI 결과 + 수정 + 등록
    └── widgets/
        ├── ai_result_card.dart        # 분류 결과 + 수정 드롭다운
        ├── confidence_indicator.dart   # 신뢰도 퍼센트 바
        ├── category_edit_dropdown.dart # 빠른 카테고리 수정
        └── device_check_dialog.dart   # RAM 부족 시 안내
```

**AI 흐름:**
1. 기기 스펙 체크 (RAM < 2GB → 수동 등록으로 Fallback)
2. 카메라 촬영
3. Gemma 4 E2B 온디바이스 추론 (3초 이내)
4. 결과 표시: 대/중/소분류 + 추천명 + 신뢰도
5. "AI의 분석 결과는 참고용입니다" 안내문 상시 표시
6. 사용자 확인/수정 (드롭다운 1-2탭)
7. 추가 정보 입력 (위치, 구매일 등)
8. 등록 → POST /api/v1/assets (ai_classified=true)

**보안 원칙:**
- 이미지는 **절대 서버로 전송하지 않음** (메모리 내 처리)
- 서버로는 분류 결과 텍스트 + 메타데이터만 전송
- 사용자가 선택한 경우에만 이미지를 서버에 별도 업로드

### C6. 알림 (2일)

**작업:**
1. Firebase Cloud Messaging 설정 (google-services.json)
2. FCM 토큰 등록 → `PUT /api/v1/users/me/fcm-token`
3. 푸시 알림 핸들러 (포그라운드/백그라운드/종료 상태)
4. 알림 목록 화면
5. 딥링크: RENTAL_DUE/OVERDUE → 대여 상세 화면

**백엔드 추가:** users 테이블에 `fcm_token NVARCHAR(500)` 컬럼, FcmService 완성

---

## 상태 전이 규칙

**자산 상태:**
- IN_USE → RENTED (대여 생성), BROKEN, IN_STORAGE, DISPOSED
- RENTED → IN_USE (반납만 가능, PATCH로 직접 변경 불가)
- BROKEN → IN_USE, DISPOSED
- IN_STORAGE → IN_USE, DISPOSED
- DISPOSED → 변경 불가

**대여 상태:**
- RENTED → RETURNED (반납), OVERDUE (스케줄러), CANCELLED (취소)
- OVERDUE → RETURNED (늦은 반납), CANCELLED (예외)

---

## 일정 요약

| Phase | 단계 | 일수 |
|-------|------|------|
| **A. Backend+DB** | A1 초기화 | 2 |
| | A2 DB 스키마 | 1 |
| | A3 공통 인프라 | 2 |
| | A4 인증 | 3 |
| | A5 사용자 | 1.5 |
| | A6 카테고리 | 1 |
| | A7 장비 | 3 |
| | A8 대여 | 3.5 |
| | A9 알림 | 2 |
| | **소계** | **19일** |
| **B. Web** | B1 초기화 | 1 |
| | B2 인증 | 1.5 |
| | B3 대시보드 | 1.5 |
| | B4 장비 화면 | 2.5 |
| | B5 대여 화면 | 2 |
| | B6 알림 UI | 0.5 |
| | B7 사용자 관리 | 1 |
| | **소계** | **10일** |
| **C. Mobile** | C1 초기화 | 1.5 |
| | C2 인증 | 1.5 |
| | C3 장비 화면 | 2 |
| | C4 대여 화면 | 2 |
| | C5 AI 등록 | 4 |
| | C6 알림 | 2 |
| | **소계** | **13일** |
| **합계** | | **42일 (~8.5주)** |

## 주차별 일정

```
Week 1-2:  A1 → A2 → A3 → A4 (프로젝트+DB+인프라+인증)
Week 3:    A5 → A6 → A7 (사용자+카테고리+장비)
Week 4:    A8 → A9 (대여+알림)
Week 5:    B1 → B2 → B3 (웹 초기화+인증+대시보드)
Week 6:    B4 → B5 (웹 장비+대여)
Week 7:    B6 → B7 → C1 → C2 (웹 마무리 + 모바일 초기화+인증)
Week 8:    C3 → C4 (모바일 장비+대여)
Week 9:    C5 → C6 (AI 등록 + 푸시 알림)
```

## 검증 방법
- 각 Phase 완료 시 `code-reviewer` + `security-reviewer` 에이전트 실행
- 백엔드: `./gradlew test` → JaCoCo 80%+
- 웹: `npm test` + Playwright E2E
- 모바일: `flutter test` + `flutter analyze`
- 전체 흐름: 로그인 → 장비 등록 → 대여 → 반납 → 알림 수신
