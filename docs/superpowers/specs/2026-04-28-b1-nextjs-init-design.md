# Phase B1: Next.js 프로젝트 초기화 설계

> 작성일: 2026-04-28

## Context

Phase A (Backend + DB) 완료 후, 웹 클라이언트 구축의 첫 단계.
38개 API 엔드포인트가 준비된 상태에서 Next.js 프로젝트 기반을 세팅한다.
이후 B2~B7 단계에서 각 화면을 구현할 수 있도록 공통 인프라를 구성하는 것이 목표.

## 기술 스택

| 영역 | 라이브러리 | 버전 |
|------|-----------|------|
| 프레임워크 | Next.js (App Router) + TypeScript | latest stable |
| 스타일링 | Tailwind CSS | v4 |
| UI 컴포넌트 | shadcn/ui (Radix UI 기반) | latest |
| 서버 상태 | @tanstack/react-query | v5 |
| HTTP 클라이언트 | axios (보안 검증 후 설치) | latest (audit 통과 확인) |
| 클라이언트 상태 | zustand | v5 |
| 폼 처리 | react-hook-form + zod | latest |
| 라우트 보호 | Next.js middleware | - |

## 프로젝트 구조

```
frontend/src/
├── app/                          # App Router 페이지
│   ├── layout.tsx                # Root Layout (Providers 래핑)
│   ├── page.tsx                  # / → /dashboard 리다이렉트
│   ├── login/
│   │   └── page.tsx
│   ├── (authenticated)/          # 인증 필요 라우트 그룹
│   │   ├── layout.tsx            # Sidebar + Header 레이아웃
│   │   ├── dashboard/page.tsx
│   │   ├── assets/
│   │   │   ├── page.tsx          # 목록
│   │   │   ├── new/page.tsx      # 등록
│   │   │   └── [id]/
│   │   │       ├── page.tsx      # 상세
│   │   │       └── edit/page.tsx # 수정
│   │   ├── rentals/
│   │   │   ├── page.tsx
│   │   │   └── [id]/page.tsx
│   │   ├── notifications/page.tsx
│   │   ├── users/page.tsx        # MANAGER 전용
│   │   └── profile/page.tsx
│   └── globals.css
├── components/
│   ├── ui/                       # shadcn/ui 컴포넌트 (자동 생성)
│   ├── layout/
│   │   ├── Sidebar.tsx           # 좌측 고정 네비게이션
│   │   ├── Header.tsx            # 상단 바 (사용자 메뉴 + 알림)
│   │   ├── NavItem.tsx           # 네비게이션 항목
│   │   └── UserMenu.tsx          # 사용자 드롭다운
│   └── providers/
│       ├── QueryProvider.tsx     # TanStack Query 설정
│       └── AuthProvider.tsx      # 인증 상태 초기화
├── lib/
│   ├── api/
│   │   ├── client.ts             # axios 인스턴스 (인터셉터)
│   │   ├── auth.ts               # 로그인/로그아웃/갱신 API
│   │   ├── assets.ts             # 장비 CRUD API
│   │   ├── rentals.ts            # 대여 API
│   │   ├── categories.ts         # 카테고리 API
│   │   ├── users.ts              # 사용자 API
│   │   └── notifications.ts      # 알림 API
│   ├── auth/
│   │   └── token.ts              # 토큰 저장/조회/삭제 (localStorage)
│   └── utils/
│       └── cn.ts                 # clsx + tailwind-merge
├── hooks/                        # TanStack Query 커스텀 훅 (B2~B7에서 추가)
├── store/
│   ├── authStore.ts              # Zustand: 인증 상태 (user, isAuthenticated)
│   └── uiStore.ts                # Zustand: UI 상태 (sidebar open/close)
├── types/
│   ├── api.ts                    # ApiResponse<T>, PageResponse<T>
│   ├── user.ts                   # User, Role, LoginRequest, LoginResponse
│   ├── asset.ts                  # Asset, AssetStatus, AssetCreateRequest 등
│   ├── rental.ts                 # Rental, RentalStatus 등
│   ├── category.ts               # AssetCategory, CategoryTree
│   └── notification.ts           # Notification, NotificationType
└── middleware.ts                  # 비인증 사용자 → /login 리다이렉트
```

## 핵심 구현 상세

### 1. axios 인스턴스 (lib/api/client.ts)

```typescript
// 설정
// - baseURL: process.env.NEXT_PUBLIC_API_URL
// - timeout: 10000 (10초)
// - headers: { 'Content-Type': 'application/json' }

// 요청 인터셉터
// - localStorage에서 accessToken 조회
// - Authorization: Bearer {accessToken} 헤더 자동 첨부

// 응답 인터셉터
// - 401 응답 시:
//   1. refreshToken으로 POST /api/v1/auth/refresh 시도
//   2. 성공 → 새 토큰 저장 + 원래 요청 재시도
//   3. 실패 → 토큰 삭제 + /login 리다이렉트
// - 기타 에러 → 표준화된 에러 객체로 변환
```

### 2. 라우트 보호 (middleware.ts)

```
공개 경로: /login
보호 경로: 그 외 전부
판단 기준: localStorage에 accessToken 존재 여부
미인증 → /login 리다이렉트
이미 인증된 상태로 /login 접근 → /dashboard 리다이렉트
```

### 3. 레이아웃

```
┌─────────────────────────────────────────────┐
│  Header (UserMenu + NotificationBell)       │
├──────────┬──────────────────────────────────┤
│ Sidebar  │                                  │
│          │       Main Content               │
│ - 대시보드│                                  │
│ - 장비관리│                                  │
│ - 대여관리│                                  │
│ - 알림   │                                  │
│ - 사용자* │                                  │
│          │                                  │
│ * MANAGER│                                  │
└──────────┴──────────────────────────────────┘
```

### 4. shadcn/ui 초기 컴포넌트

B1에서 설치: button, input, select, dialog, badge, card, table, dropdown-menu, toast, separator, skeleton, sheet (모바일 사이드바용)

### 5. TypeScript 타입 (백엔드 DTO 대응)

- `ApiResponse<T>`: `{ success, data, message, timestamp }` — 백엔드 envelope 대응
- `PageResponse<T>`: `{ content, page, size, totalElements, totalPages, last }`
- 각 도메인 타입: 백엔드 Response DTO와 1:1 대응

### 6. 환경변수

```
NEXT_PUBLIC_API_URL=http://localhost:8080
```

## axios 보안 검증

설치 전 반드시 확인:
1. `npm audit` 실행하여 axios 관련 취약점 확인
2. 취약점 발견 시 패치 버전 확인 후 안전한 버전 설치
3. `npm audit --audit-level=high` 통과 필수

## B1 범위 (이 단계에서 하는 것 / 안 하는 것)

### 하는 것
- 프로젝트 생성 및 의존성 설치
- 공통 인프라 (axios, types, store, providers, middleware)
- 레이아웃 컴포넌트 (Sidebar, Header)
- shadcn/ui 컴포넌트 설치
- API 함수 껍데기 (타입만 정의, 실제 연동은 B2~)

### 안 하는 것
- 실제 페이지 구현 (B2~B7)
- TanStack Query 훅 구현 (B2~B7에서 필요 시)
- 테스트 작성 (각 화면 구현 시 함께)
