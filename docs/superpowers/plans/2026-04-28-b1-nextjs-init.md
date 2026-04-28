# Phase B1: Next.js 프로젝트 초기화 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Next.js App Router 프로젝트를 생성하고, B2~B7 화면 구현에 필요한 공통 인프라(axios, 타입, 스토어, 레이아웃, 미들웨어)를 구성한다.

**Architecture:** shadcn/ui + Tailwind CSS 기반 UI, axios + TanStack Query로 서버 상태 관리, Zustand로 클라이언트 상태 관리. App Router의 route group으로 인증/비인증 레이아웃 분리.

**Tech Stack:** Next.js (App Router), TypeScript, Tailwind CSS, shadcn/ui, axios, @tanstack/react-query v5, zustand v5, react-hook-form, zod

---

## Task 1: Next.js 프로젝트 생성

**Files:**
- Create: `frontend/` (Next.js 프로젝트 전체)

- [ ] **Step 1: Next.js 프로젝트 생성**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
npx create-next-app@latest frontend --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --turbopack
```

프롬프트 선택:
- Would you like to use TypeScript? → Yes
- Would you like to use ESLint? → Yes
- Would you like to use Tailwind CSS? → Yes
- Would you like your code inside a `src/` directory? → Yes
- Would you like to use App Router? → Yes
- Would you like to use Turbopack? → Yes
- Would you like to customize the import alias? → Yes, @/*

- [ ] **Step 2: 빌드 확인**

```bash
cd frontend && npm run build
```

Expected: Build 성공, `.next/` 디렉토리 생성

- [ ] **Step 3: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/
git commit -m "feat(frontend): Next.js 프로젝트 초기화"
```

---

## Task 2: 의존성 설치 (axios 보안 검증 포함)

**Files:**
- Modify: `frontend/package.json`

- [ ] **Step 1: 핵심 의존성 설치**

```bash
cd frontend
npm install axios @tanstack/react-query zustand react-hook-form @hookform/resolvers zod
```

- [ ] **Step 2: axios 보안 검증**

```bash
npm audit --audit-level=high
```

Expected: axios 관련 high/critical 취약점 없음. 만약 취약점 발견 시:
```bash
npm audit fix
# 또는 안전한 특정 버전으로 재설치
npm install axios@<safe-version>
```

- [ ] **Step 3: 개발 의존성 설치**

```bash
npm install -D @tanstack/react-query-devtools
```

- [ ] **Step 4: 빌드 확인**

```bash
npm run build
```

Expected: BUILD 성공

- [ ] **Step 5: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/package.json frontend/package-lock.json
git commit -m "feat(frontend): 핵심 의존성 설치 (axios 보안 검증 완료)"
```

---

## Task 3: shadcn/ui 초기화 및 컴포넌트 설치

**Files:**
- Create: `frontend/src/lib/utils.ts`
- Create: `frontend/components.json`
- Create: `frontend/src/components/ui/` (여러 파일)

- [ ] **Step 1: shadcn/ui 초기화**

```bash
cd frontend
npx shadcn@latest init
```

프롬프트 선택:
- Style: New York
- Base color: Neutral
- CSS variables: Yes

- [ ] **Step 2: 컴포넌트 일괄 설치**

```bash
npx shadcn@latest add button input select dialog badge card table dropdown-menu toast separator skeleton sheet label textarea
```

- [ ] **Step 3: 빌드 확인**

```bash
npm run build
```

Expected: BUILD 성공

- [ ] **Step 4: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/
git commit -m "feat(frontend): shadcn/ui 초기화 및 공통 UI 컴포넌트 설치"
```

---

## Task 4: 환경변수 및 TypeScript 타입 정의

**Files:**
- Create: `frontend/.env.local`
- Create: `frontend/.env.example`
- Create: `frontend/src/types/api.ts`
- Create: `frontend/src/types/user.ts`
- Create: `frontend/src/types/asset.ts`
- Create: `frontend/src/types/rental.ts`
- Create: `frontend/src/types/category.ts`
- Create: `frontend/src/types/notification.ts`

- [ ] **Step 1: 환경변수 파일 생성**

`frontend/.env.local`:
```
NEXT_PUBLIC_API_URL=http://localhost:8080
```

`frontend/.env.example`:
```
NEXT_PUBLIC_API_URL=http://localhost:8080
```

`frontend/.gitignore`에 `.env.local` 포함 확인 (create-next-app 기본 포함).

- [ ] **Step 2: 공통 API 타입 생성**

`frontend/src/types/api.ts`:
```typescript
export interface ApiResponse<T> {
  success: boolean;
  data: T | null;
  message: string | null;
  timestamp: string;
}

export interface PageResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  last: boolean;
}

export interface PageParams {
  page?: number;
  size?: number;
  sort?: string;
}
```

- [ ] **Step 3: 사용자 타입 생성**

`frontend/src/types/user.ts`:
```typescript
export type Role = 'COUNSELOR' | 'MANAGER';

export interface User {
  userId: number;
  email: string;
  name: string;
  role: Role;
  branchName: string | null;
  phone: string | null;
  isActive: boolean;
  createdAt: string;
}

export interface UserSummary {
  userId: number;
  email: string;
  name: string;
  role: Role;
  branchName: string | null;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: UserSummary;
}

export interface TokenRefreshRequest {
  refreshToken: string;
}

export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
}

export interface UserCreateRequest {
  email: string;
  password: string;
  name: string;
  role: Role;
  branchName?: string;
  phone?: string;
}

export interface UserUpdateRequest {
  name: string;
  role?: Role;
  branchName?: string;
  phone?: string;
}

export interface ProfileUpdateRequest {
  name: string;
  phone?: string;
}

export interface PasswordChangeRequest {
  currentPassword: string;
  newPassword: string;
}
```

- [ ] **Step 4: 장비 타입 생성**

`frontend/src/types/asset.ts`:
```typescript
export type AssetStatus = 'IN_USE' | 'RENTED' | 'BROKEN' | 'IN_STORAGE' | 'DISPOSED';

export interface Asset {
  assetId: number;
  assetCode: string;
  assetName: string;
  status: AssetStatus;
  categoryName: string;
  categoryId: number;
  location: string | null;
  manufacturer: string | null;
  modelNumber: string | null;
  purchaseDate: string | null;
  imagePath: string | null;
  aiClassified: boolean;
  createdAt: string;
}

export interface AssetDetail {
  assetId: number;
  assetCode: string;
  assetName: string;
  status: AssetStatus;
  categoryId: number;
  categoryName: string;
  categoryPath: string[];
  serialNumber: string | null;
  manufacturer: string | null;
  modelNumber: string | null;
  purchaseDate: string | null;
  location: string | null;
  conditionRating: number | null;
  technicalSpecs: string | null;
  imagePath: string | null;
  aiClassified: boolean;
  notes: string | null;
  registeredByName: string;
  createdAt: string;
  updatedAt: string;
}

export interface AssetCreateRequest {
  categoryId: number;
  assetName: string;
  serialNumber?: string;
  manufacturer?: string;
  modelNumber?: string;
  purchaseDate?: string;
  location?: string;
  conditionRating?: number;
  technicalSpecs?: string;
  aiClassified?: boolean;
  notes?: string;
}

export interface AssetUpdateRequest {
  categoryId: number;
  assetName: string;
  serialNumber?: string;
  manufacturer?: string;
  modelNumber?: string;
  purchaseDate?: string;
  location?: string;
  conditionRating?: number;
  technicalSpecs?: string;
  notes?: string;
}

export interface AssetStatusRequest {
  status: AssetStatus;
}

export interface AssetSummary {
  total: number;
  inUse: number;
  rented: number;
  broken: number;
  inStorage: number;
  disposed: number;
}

export interface AssetSearchParams {
  page?: number;
  size?: number;
  status?: AssetStatus;
  categoryId?: number;
  search?: string;
  location?: string;
  sort?: string;
}
```

- [ ] **Step 5: 대여 타입 생성**

`frontend/src/types/rental.ts`:
```typescript
export type RentalStatus = 'RENTED' | 'RETURNED' | 'OVERDUE' | 'CANCELLED';

export interface Rental {
  rentalId: number;
  assetId: number;
  assetName: string;
  assetCode: string;
  borrowerId: number;
  borrowerEmail: string;
  borrowerName: string;
  rentalReason: string | null;
  rentalDate: string;
  dueDate: string;
  returnDate: string | null;
  status: RentalStatus;
  extensionCount: number;
  returnCondition: string | null;
}

export interface RentalCreateRequest {
  assetId: number;
  borrowerId?: number;
  rentalReason?: string;
  borrowerName?: string;
  dueDays: number;
}

export interface RentalReturnRequest {
  returnCondition?: string;
}

export interface RentalExtendRequest {
  extensionDays: number;
}

export interface RentalDashboard {
  totalActive: number;
  overdueCount: number;
  dueSoon: number;
  returnedToday: number;
}

export interface RentalSearchParams {
  page?: number;
  size?: number;
  status?: RentalStatus;
  borrowerId?: number;
  assetId?: number;
  sort?: string;
}
```

- [ ] **Step 6: 카테고리 타입 생성**

`frontend/src/types/category.ts`:
```typescript
export interface Category {
  categoryId: number;
  parentId: number | null;
  categoryName: string;
  categoryLevel: number;
  description: string | null;
  createdAt: string;
}

export interface CategoryTree {
  categoryId: number;
  categoryName: string;
  categoryLevel: number;
  description: string | null;
  children: CategoryTree[];
}

export interface CategoryCreateRequest {
  parentId?: number;
  categoryName: string;
  categoryLevel: number;
  description?: string;
}

export interface CategoryUpdateRequest {
  categoryName: string;
  description?: string;
}
```

- [ ] **Step 7: 알림 타입 생성**

`frontend/src/types/notification.ts`:
```typescript
export type NotificationType = 'RENTAL_DUE' | 'RENTAL_OVERDUE' | 'SYSTEM';
export type NotificationChannel = 'IN_APP' | 'EMAIL' | 'PUSH';

export interface Notification {
  notificationId: number;
  type: NotificationType;
  title: string;
  message: string | null;
  isRead: boolean;
  channel: NotificationChannel;
  referenceId: number | null;
  sentAt: string;
  readAt: string | null;
}

export interface UnreadCount {
  unreadCount: number;
}
```

- [ ] **Step 8: 빌드 확인**

```bash
cd frontend && npm run build
```

Expected: BUILD 성공

- [ ] **Step 9: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/.env.example frontend/src/types/
git commit -m "feat(frontend): 환경변수 및 TypeScript 타입 정의 (백엔드 DTO 대응)"
```

---

## Task 5: axios 인스턴스 및 토큰 관리

**Files:**
- Create: `frontend/src/lib/auth/token.ts`
- Create: `frontend/src/lib/api/client.ts`

- [ ] **Step 1: 토큰 관리 유틸 생성**

`frontend/src/lib/auth/token.ts`:
```typescript
const ACCESS_TOKEN_KEY = 'accessToken';
const REFRESH_TOKEN_KEY = 'refreshToken';

export function getAccessToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(ACCESS_TOKEN_KEY);
}

export function getRefreshToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(REFRESH_TOKEN_KEY);
}

export function setTokens(accessToken: string, refreshToken: string): void {
  localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
  localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);
}

export function clearTokens(): void {
  localStorage.removeItem(ACCESS_TOKEN_KEY);
  localStorage.removeItem(REFRESH_TOKEN_KEY);
}

export function hasToken(): boolean {
  return !!getAccessToken();
}
```

- [ ] **Step 2: axios 인스턴스 생성**

`frontend/src/lib/api/client.ts`:
```typescript
import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios';
import { getAccessToken, getRefreshToken, setTokens, clearTokens } from '@/lib/auth/token';
import type { ApiResponse, TokenResponse } from '@/types/api';

const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 요청 인터셉터: Authorization 헤더 자동 첨부
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = getAccessToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error),
);

// 응답 인터셉터: 401 → refresh 시도
let isRefreshing = false;
let failedQueue: Array<{
  resolve: (value: unknown) => void;
  reject: (reason: unknown) => void;
}> = [];

function processQueue(error: unknown) {
  failedQueue.forEach((promise) => {
    if (error) {
      promise.reject(error);
    } else {
      promise.resolve(undefined);
    }
  });
  failedQueue = [];
}

apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config;
    if (!originalRequest) return Promise.reject(error);

    // 401이고 refresh 요청 자체가 아닌 경우
    if (error.response?.status === 401 && !originalRequest.url?.includes('/auth/refresh')) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        }).then(() => apiClient(originalRequest));
      }

      isRefreshing = true;
      const refreshToken = getRefreshToken();

      if (!refreshToken) {
        clearTokens();
        window.location.href = '/login';
        return Promise.reject(error);
      }

      try {
        const { data } = await axios.post<ApiResponse<TokenResponse>>(
          `${process.env.NEXT_PUBLIC_API_URL}/api/v1/auth/refresh`,
          { refreshToken },
        );

        if (data.success && data.data) {
          setTokens(data.data.accessToken, data.data.refreshToken);
          processQueue(null);
          return apiClient(originalRequest);
        }
      } catch {
        processQueue(error);
        clearTokens();
        window.location.href = '/login';
        return Promise.reject(error);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  },
);

export default apiClient;
```

Note: `TokenResponse` 타입을 `api.ts`에서도 re-export하도록 수정 필요 — 실제로는 `user.ts`에 정의되어 있으므로 import 경로를 `@/types/user`로 변경.

실제 import 수정:
```typescript
import type { ApiResponse } from '@/types/api';
import type { TokenResponse } from '@/types/user';
```

- [ ] **Step 3: 빌드 확인**

```bash
cd frontend && npm run build
```

Expected: BUILD 성공

- [ ] **Step 4: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/src/lib/auth/ frontend/src/lib/api/client.ts
git commit -m "feat(frontend): axios 인스턴스 및 토큰 관리 유틸 구현"
```

---

## Task 6: API 함수 모듈 생성

**Files:**
- Create: `frontend/src/lib/api/auth.ts`
- Create: `frontend/src/lib/api/assets.ts`
- Create: `frontend/src/lib/api/rentals.ts`
- Create: `frontend/src/lib/api/categories.ts`
- Create: `frontend/src/lib/api/users.ts`
- Create: `frontend/src/lib/api/notifications.ts`

- [ ] **Step 1: 인증 API 함수**

`frontend/src/lib/api/auth.ts`:
```typescript
import apiClient from './client';
import type { ApiResponse } from '@/types/api';
import type { LoginRequest, LoginResponse, TokenRefreshRequest, TokenResponse } from '@/types/user';

export async function login(request: LoginRequest): Promise<ApiResponse<LoginResponse>> {
  const { data } = await apiClient.post<ApiResponse<LoginResponse>>('/api/v1/auth/login', request);
  return data;
}

export async function refreshToken(request: TokenRefreshRequest): Promise<ApiResponse<TokenResponse>> {
  const { data } = await apiClient.post<ApiResponse<TokenResponse>>('/api/v1/auth/refresh', request);
  return data;
}

export async function logout(): Promise<ApiResponse<null>> {
  const { data } = await apiClient.post<ApiResponse<null>>('/api/v1/auth/logout');
  return data;
}
```

- [ ] **Step 2: 장비 API 함수**

`frontend/src/lib/api/assets.ts`:
```typescript
import apiClient from './client';
import type { ApiResponse, PageResponse } from '@/types/api';
import type {
  Asset,
  AssetDetail,
  AssetCreateRequest,
  AssetUpdateRequest,
  AssetStatusRequest,
  AssetSummary,
  AssetSearchParams,
} from '@/types/asset';

export async function fetchAssets(params?: AssetSearchParams): Promise<ApiResponse<PageResponse<Asset>>> {
  const { data } = await apiClient.get<ApiResponse<PageResponse<Asset>>>('/api/v1/assets', { params });
  return data;
}

export async function fetchAsset(id: number): Promise<ApiResponse<AssetDetail>> {
  const { data } = await apiClient.get<ApiResponse<AssetDetail>>(`/api/v1/assets/${id}`);
  return data;
}

export async function createAsset(request: AssetCreateRequest, image?: File): Promise<ApiResponse<AssetDetail>> {
  const formData = new FormData();
  formData.append('request', new Blob([JSON.stringify(request)], { type: 'application/json' }));
  if (image) {
    formData.append('image', image);
  }
  const { data } = await apiClient.post<ApiResponse<AssetDetail>>('/api/v1/assets', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
  return data;
}

export async function updateAsset(id: number, request: AssetUpdateRequest, image?: File): Promise<ApiResponse<AssetDetail>> {
  const formData = new FormData();
  formData.append('request', new Blob([JSON.stringify(request)], { type: 'application/json' }));
  if (image) {
    formData.append('image', image);
  }
  const { data } = await apiClient.put<ApiResponse<AssetDetail>>(`/api/v1/assets/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
  return data;
}

export async function deleteAsset(id: number): Promise<ApiResponse<null>> {
  const { data } = await apiClient.delete<ApiResponse<null>>(`/api/v1/assets/${id}`);
  return data;
}

export async function updateAssetStatus(id: number, request: AssetStatusRequest): Promise<ApiResponse<AssetDetail>> {
  const { data } = await apiClient.patch<ApiResponse<AssetDetail>>(`/api/v1/assets/${id}/status`, request);
  return data;
}

export async function fetchAssetSummary(): Promise<ApiResponse<AssetSummary>> {
  const { data } = await apiClient.get<ApiResponse<AssetSummary>>('/api/v1/assets/summary');
  return data;
}
```

- [ ] **Step 3: 대여 API 함수**

`frontend/src/lib/api/rentals.ts`:
```typescript
import apiClient from './client';
import type { ApiResponse, PageResponse } from '@/types/api';
import type {
  Rental,
  RentalCreateRequest,
  RentalReturnRequest,
  RentalExtendRequest,
  RentalDashboard,
  RentalSearchParams,
} from '@/types/rental';

export async function fetchRentals(params?: RentalSearchParams): Promise<ApiResponse<PageResponse<Rental>>> {
  const { data } = await apiClient.get<ApiResponse<PageResponse<Rental>>>('/api/v1/rentals', { params });
  return data;
}

export async function fetchRental(id: number): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.get<ApiResponse<Rental>>(`/api/v1/rentals/${id}`);
  return data;
}

export async function createRental(request: RentalCreateRequest): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.post<ApiResponse<Rental>>('/api/v1/rentals', request);
  return data;
}

export async function returnRental(id: number, request: RentalReturnRequest): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.put<ApiResponse<Rental>>(`/api/v1/rentals/${id}/return`, request);
  return data;
}

export async function extendRental(id: number, request: RentalExtendRequest): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.put<ApiResponse<Rental>>(`/api/v1/rentals/${id}/extend`, request);
  return data;
}

export async function cancelRental(id: number): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.put<ApiResponse<Rental>>(`/api/v1/rentals/${id}/cancel`);
  return data;
}

export async function fetchRentalDashboard(): Promise<ApiResponse<RentalDashboard>> {
  const { data } = await apiClient.get<ApiResponse<RentalDashboard>>('/api/v1/rentals/dashboard');
  return data;
}

export async function fetchOverdueRentals(): Promise<ApiResponse<Rental[]>> {
  const { data } = await apiClient.get<ApiResponse<Rental[]>>('/api/v1/rentals/overdue');
  return data;
}

export async function fetchAssetRentalHistory(assetId: number): Promise<ApiResponse<Rental[]>> {
  const { data } = await apiClient.get<ApiResponse<Rental[]>>(`/api/v1/rentals/asset/${assetId}/history`);
  return data;
}
```

- [ ] **Step 4: 카테고리 API 함수**

`frontend/src/lib/api/categories.ts`:
```typescript
import apiClient from './client';
import type { ApiResponse } from '@/types/api';
import type { Category, CategoryTree, CategoryCreateRequest, CategoryUpdateRequest } from '@/types/category';

export async function fetchCategories(level?: number): Promise<ApiResponse<Category[]>> {
  const params = level ? { level } : undefined;
  const { data } = await apiClient.get<ApiResponse<Category[]>>('/api/v1/categories', { params });
  return data;
}

export async function fetchCategoryTree(): Promise<ApiResponse<CategoryTree[]>> {
  const { data } = await apiClient.get<ApiResponse<CategoryTree[]>>('/api/v1/categories/tree');
  return data;
}

export async function fetchCategory(id: number): Promise<ApiResponse<Category>> {
  const { data } = await apiClient.get<ApiResponse<Category>>(`/api/v1/categories/${id}`);
  return data;
}

export async function fetchCategoryChildren(id: number): Promise<ApiResponse<Category[]>> {
  const { data } = await apiClient.get<ApiResponse<Category[]>>(`/api/v1/categories/${id}/children`);
  return data;
}

export async function createCategory(request: CategoryCreateRequest): Promise<ApiResponse<Category>> {
  const { data } = await apiClient.post<ApiResponse<Category>>('/api/v1/categories', request);
  return data;
}

export async function updateCategory(id: number, request: CategoryUpdateRequest): Promise<ApiResponse<Category>> {
  const { data } = await apiClient.put<ApiResponse<Category>>(`/api/v1/categories/${id}`, request);
  return data;
}

export async function deleteCategory(id: number): Promise<ApiResponse<null>> {
  const { data } = await apiClient.delete<ApiResponse<null>>(`/api/v1/categories/${id}`);
  return data;
}
```

- [ ] **Step 5: 사용자 API 함수**

`frontend/src/lib/api/users.ts`:
```typescript
import apiClient from './client';
import type { ApiResponse, PageResponse, PageParams } from '@/types/api';
import type {
  User,
  UserCreateRequest,
  UserUpdateRequest,
  ProfileUpdateRequest,
  PasswordChangeRequest,
} from '@/types/user';

export async function fetchUsers(params?: PageParams & { role?: string; search?: string }): Promise<ApiResponse<PageResponse<User>>> {
  const { data } = await apiClient.get<ApiResponse<PageResponse<User>>>('/api/v1/users', { params });
  return data;
}

export async function fetchUser(id: number): Promise<ApiResponse<User>> {
  const { data } = await apiClient.get<ApiResponse<User>>(`/api/v1/users/${id}`);
  return data;
}

export async function createUser(request: UserCreateRequest): Promise<ApiResponse<User>> {
  const { data } = await apiClient.post<ApiResponse<User>>('/api/v1/users', request);
  return data;
}

export async function updateUser(id: number, request: UserUpdateRequest): Promise<ApiResponse<User>> {
  const { data } = await apiClient.put<ApiResponse<User>>(`/api/v1/users/${id}`, request);
  return data;
}

export async function deleteUser(id: number): Promise<ApiResponse<null>> {
  const { data } = await apiClient.delete<ApiResponse<null>>(`/api/v1/users/${id}`);
  return data;
}

export async function fetchMyProfile(): Promise<ApiResponse<User>> {
  const { data } = await apiClient.get<ApiResponse<User>>('/api/v1/users/me');
  return data;
}

export async function updateMyProfile(request: ProfileUpdateRequest): Promise<ApiResponse<User>> {
  const { data } = await apiClient.put<ApiResponse<User>>('/api/v1/users/me', request);
  return data;
}

export async function changePassword(request: PasswordChangeRequest): Promise<ApiResponse<null>> {
  const { data } = await apiClient.put<ApiResponse<null>>('/api/v1/users/me/password', request);
  return data;
}
```

- [ ] **Step 6: 알림 API 함수**

`frontend/src/lib/api/notifications.ts`:
```typescript
import apiClient from './client';
import type { ApiResponse, PageResponse, PageParams } from '@/types/api';
import type { Notification, UnreadCount } from '@/types/notification';

export async function fetchNotifications(params?: PageParams & { isRead?: boolean }): Promise<ApiResponse<PageResponse<Notification>>> {
  const { data } = await apiClient.get<ApiResponse<PageResponse<Notification>>>('/api/v1/notifications', { params });
  return data;
}

export async function fetchUnreadCount(): Promise<ApiResponse<UnreadCount>> {
  const { data } = await apiClient.get<ApiResponse<UnreadCount>>('/api/v1/notifications/unread-count');
  return data;
}

export async function markAsRead(id: number): Promise<ApiResponse<null>> {
  const { data } = await apiClient.put<ApiResponse<null>>(`/api/v1/notifications/${id}/read`);
  return data;
}

export async function markAllAsRead(): Promise<ApiResponse<null>> {
  const { data } = await apiClient.put<ApiResponse<null>>('/api/v1/notifications/read-all');
  return data;
}
```

- [ ] **Step 7: 빌드 확인**

```bash
cd frontend && npm run build
```

Expected: BUILD 성공

- [ ] **Step 8: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/src/lib/api/
git commit -m "feat(frontend): 전체 API 함수 모듈 구현 (38개 엔드포인트 대응)"
```

---

## Task 7: Zustand 스토어 생성

**Files:**
- Create: `frontend/src/store/authStore.ts`
- Create: `frontend/src/store/uiStore.ts`

- [ ] **Step 1: 인증 스토어 생성**

`frontend/src/store/authStore.ts`:
```typescript
import { create } from 'zustand';
import type { UserSummary } from '@/types/user';
import { clearTokens } from '@/lib/auth/token';

interface AuthState {
  user: UserSummary | null;
  isAuthenticated: boolean;
  setUser: (user: UserSummary) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  setUser: (user) => set({ user, isAuthenticated: true }),
  logout: () => {
    clearTokens();
    set({ user: null, isAuthenticated: false });
  },
}));
```

- [ ] **Step 2: UI 스토어 생성**

`frontend/src/store/uiStore.ts`:
```typescript
import { create } from 'zustand';

interface UiState {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
  setSidebarOpen: (open: boolean) => void;
}

export const useUiStore = create<UiState>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
  setSidebarOpen: (open) => set({ sidebarOpen: open }),
}));
```

- [ ] **Step 3: 빌드 확인**

```bash
cd frontend && npm run build
```

Expected: BUILD 성공

- [ ] **Step 4: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/src/store/
git commit -m "feat(frontend): Zustand 스토어 구현 (auth, ui)"
```

---

## Task 8: Providers 및 Root Layout 구성

**Files:**
- Create: `frontend/src/components/providers/QueryProvider.tsx`
- Create: `frontend/src/components/providers/AuthProvider.tsx`
- Modify: `frontend/src/app/layout.tsx`

- [ ] **Step 1: QueryProvider 생성**

`frontend/src/components/providers/QueryProvider.tsx`:
```tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { useState, type ReactNode } from 'react';

export function QueryProvider({ children }: { children: ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
            retry: 1,
            refetchOnWindowFocus: false,
          },
        },
      }),
  );

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
```

- [ ] **Step 2: AuthProvider 생성**

`frontend/src/components/providers/AuthProvider.tsx`:
```tsx
'use client';

import { useEffect, type ReactNode } from 'react';
import { useAuthStore } from '@/store/authStore';
import { hasToken } from '@/lib/auth/token';
import { fetchMyProfile } from '@/lib/api/users';

export function AuthProvider({ children }: { children: ReactNode }) {
  const { setUser, logout } = useAuthStore();

  useEffect(() => {
    async function initAuth() {
      if (!hasToken()) return;
      try {
        const response = await fetchMyProfile();
        if (response.success && response.data) {
          setUser({
            userId: response.data.userId,
            email: response.data.email,
            name: response.data.name,
            role: response.data.role,
            branchName: response.data.branchName,
          });
        }
      } catch {
        logout();
      }
    }
    initAuth();
  }, [setUser, logout]);

  return <>{children}</>;
}
```

- [ ] **Step 3: Root Layout 수정**

`frontend/src/app/layout.tsx` (기존 파일 수정):
```tsx
import type { Metadata } from 'next';
import { Geist, Geist_Mono } from 'next/font/google';
import './globals.css';
import { QueryProvider } from '@/components/providers/QueryProvider';
import { AuthProvider } from '@/components/providers/AuthProvider';
import { Toaster } from '@/components/ui/toaster';

const geistSans = Geist({
  variable: '--font-geist-sans',
  subsets: ['latin'],
});

const geistMono = Geist_Mono({
  variable: '--font-geist-mono',
  subsets: ['latin'],
});

export const metadata: Metadata = {
  title: '장비 관리 시스템 - 국민취업지원제도',
  description: 'AI 기반 장비/자산 관리 시스템',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <body className={`${geistSans.variable} ${geistMono.variable} antialiased`}>
        <QueryProvider>
          <AuthProvider>
            {children}
            <Toaster />
          </AuthProvider>
        </QueryProvider>
      </body>
    </html>
  );
}
```

- [ ] **Step 4: 빌드 확인**

```bash
cd frontend && npm run build
```

Expected: BUILD 성공

- [ ] **Step 5: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/src/components/providers/ frontend/src/app/layout.tsx
git commit -m "feat(frontend): Providers 및 Root Layout 구성 (TanStack Query, Auth)"
```

---

## Task 9: 레이아웃 컴포넌트 (Sidebar, Header)

**Files:**
- Create: `frontend/src/components/layout/Sidebar.tsx`
- Create: `frontend/src/components/layout/Header.tsx`
- Create: `frontend/src/components/layout/NavItem.tsx`
- Create: `frontend/src/components/layout/UserMenu.tsx`
- Create: `frontend/src/app/(authenticated)/layout.tsx`

- [ ] **Step 1: NavItem 컴포넌트**

`frontend/src/components/layout/NavItem.tsx`:
```tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import type { ReactNode } from 'react';

interface NavItemProps {
  href: string;
  icon: ReactNode;
  label: string;
}

export function NavItem({ href, icon, label }: NavItemProps) {
  const pathname = usePathname();
  const isActive = pathname === href || pathname.startsWith(`${href}/`);

  return (
    <Link
      href={href}
      className={cn(
        'flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors',
        isActive
          ? 'bg-primary text-primary-foreground'
          : 'text-muted-foreground hover:bg-muted hover:text-foreground',
      )}
    >
      {icon}
      <span>{label}</span>
    </Link>
  );
}
```

- [ ] **Step 2: UserMenu 컴포넌트**

`frontend/src/components/layout/UserMenu.tsx`:
```tsx
'use client';

import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/authStore';
import { logout as logoutApi } from '@/lib/api/auth';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Button } from '@/components/ui/button';

export function UserMenu() {
  const router = useRouter();
  const { user, logout } = useAuthStore();

  async function handleLogout() {
    try {
      await logoutApi();
    } finally {
      logout();
      router.push('/login');
    }
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm" className="gap-2">
          <span className="hidden sm:inline-block">{user?.name ?? '사용자'}</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-48">
        <DropdownMenuLabel>
          <div className="text-sm font-medium">{user?.name}</div>
          <div className="text-xs text-muted-foreground">{user?.email}</div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={() => router.push('/profile')}>
          내 프로필
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={handleLogout}>
          로그아웃
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
```

- [ ] **Step 3: Sidebar 컴포넌트**

`frontend/src/components/layout/Sidebar.tsx`:
```tsx
'use client';

import { NavItem } from './NavItem';
import { useAuthStore } from '@/store/authStore';
import { useUiStore } from '@/store/uiStore';
import { cn } from '@/lib/utils';

export function Sidebar() {
  const { user } = useAuthStore();
  const { sidebarOpen } = useUiStore();
  const isManager = user?.role === 'MANAGER';

  return (
    <aside
      className={cn(
        'fixed left-0 top-0 z-40 h-screen w-64 border-r bg-background transition-transform',
        sidebarOpen ? 'translate-x-0' : '-translate-x-full',
        'lg:translate-x-0',
      )}
    >
      <div className="flex h-14 items-center border-b px-4">
        <span className="text-lg font-semibold">장비 관리</span>
      </div>
      <nav className="flex flex-col gap-1 p-4">
        <NavItem
          href="/dashboard"
          icon={<LayoutDashboardIcon />}
          label="대시보드"
        />
        <NavItem
          href="/assets"
          icon={<PackageIcon />}
          label="장비 관리"
        />
        <NavItem
          href="/rentals"
          icon={<ArrowLeftRightIcon />}
          label="대여 관리"
        />
        <NavItem
          href="/notifications"
          icon={<BellIcon />}
          label="알림"
        />
        {isManager && (
          <NavItem
            href="/users"
            icon={<UsersIcon />}
            label="사용자 관리"
          />
        )}
      </nav>
    </aside>
  );
}

// 간단한 SVG 아이콘 (lucide-react 설치 후 교체 가능)
function LayoutDashboardIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect width="7" height="9" x="3" y="3" rx="1" /><rect width="7" height="5" x="14" y="3" rx="1" /><rect width="7" height="9" x="14" y="12" rx="1" /><rect width="7" height="5" x="3" y="16" rx="1" />
    </svg>
  );
}

function PackageIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M16.5 9.4 7.55 4.24" /><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" /><polyline points="3.29 7 12 12 20.71 7" /><line x1="12" x2="12" y1="22" y2="12" />
    </svg>
  );
}

function ArrowLeftRightIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M8 3 4 7l4 4" /><path d="M4 7h16" /><path d="m16 21 4-4-4-4" /><path d="M20 17H4" />
    </svg>
  );
}

function BellIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" /><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0" />
    </svg>
  );
}

function UsersIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.87" /><path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  );
}
```

- [ ] **Step 4: Header 컴포넌트**

`frontend/src/components/layout/Header.tsx`:
```tsx
'use client';

import { useUiStore } from '@/store/uiStore';
import { UserMenu } from './UserMenu';
import { Button } from '@/components/ui/button';

export function Header() {
  const { toggleSidebar } = useUiStore();

  return (
    <header className="sticky top-0 z-30 flex h-14 items-center justify-between border-b bg-background px-4">
      <Button
        variant="ghost"
        size="sm"
        className="lg:hidden"
        onClick={toggleSidebar}
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <line x1="4" x2="20" y1="12" y2="12" /><line x1="4" x2="20" y1="6" y2="6" /><line x1="4" x2="20" y1="18" y2="18" />
        </svg>
      </Button>
      <div className="flex-1" />
      <UserMenu />
    </header>
  );
}
```

- [ ] **Step 5: 인증 라우트 그룹 레이아웃**

`frontend/src/app/(authenticated)/layout.tsx`:
```tsx
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import type { ReactNode } from 'react';

export default function AuthenticatedLayout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen">
      <Sidebar />
      <div className="lg:pl-64">
        <Header />
        <main className="p-6">{children}</main>
      </div>
    </div>
  );
}
```

- [ ] **Step 6: 빌드 확인**

```bash
cd frontend && npm run build
```

Expected: BUILD 성공

- [ ] **Step 7: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/src/components/layout/ frontend/src/app/\(authenticated\)/layout.tsx
git commit -m "feat(frontend): 레이아웃 컴포넌트 구현 (Sidebar, Header, NavItem, UserMenu)"
```

---

## Task 10: 미들웨어 및 페이지 스텁

**Files:**
- Create: `frontend/src/middleware.ts`
- Modify: `frontend/src/app/page.tsx`
- Create: `frontend/src/app/login/page.tsx`
- Create: `frontend/src/app/(authenticated)/dashboard/page.tsx`
- Create: `frontend/src/app/(authenticated)/assets/page.tsx`
- Create: `frontend/src/app/(authenticated)/rentals/page.tsx`
- Create: `frontend/src/app/(authenticated)/notifications/page.tsx`
- Create: `frontend/src/app/(authenticated)/users/page.tsx`
- Create: `frontend/src/app/(authenticated)/profile/page.tsx`

- [ ] **Step 1: 미들웨어 생성**

`frontend/src/middleware.ts`:
```typescript
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const PUBLIC_PATHS = ['/login'];

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // 정적 파일, API 경로 제외
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/api') ||
    pathname.includes('.')
  ) {
    return NextResponse.next();
  }

  // Note: middleware에서는 localStorage 접근 불가.
  // 쿠키 기반 또는 클라이언트 사이드에서 처리.
  // 여기서는 공개 경로만 체크하고, 실제 인증 리다이렉트는
  // AuthProvider에서 클라이언트 사이드로 처리.
  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
```

Note: JWT를 localStorage에 저장하므로 서버 사이드 미들웨어에서 토큰 접근이 불가. 실제 라우트 보호는 AuthProvider + 클라이언트 리다이렉트로 처리. B2(인증 화면 구현)에서 `AuthGuard` 컴포넌트로 보강.

- [ ] **Step 2: 루트 페이지 리다이렉트**

`frontend/src/app/page.tsx` (기존 파일 교체):
```tsx
import { redirect } from 'next/navigation';

export default function Home() {
  redirect('/dashboard');
}
```

- [ ] **Step 3: 로그인 페이지 스텁**

`frontend/src/app/login/page.tsx`:
```tsx
export default function LoginPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="w-full max-w-sm space-y-4 p-6">
        <h1 className="text-2xl font-bold text-center">장비 관리 시스템</h1>
        <p className="text-center text-muted-foreground">로그인 화면 (B2에서 구현)</p>
      </div>
    </div>
  );
}
```

- [ ] **Step 4: 인증 라우트 페이지 스텁들**

`frontend/src/app/(authenticated)/dashboard/page.tsx`:
```tsx
export default function DashboardPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">대시보드</h1>
      <p className="text-muted-foreground">B3에서 구현</p>
    </div>
  );
}
```

`frontend/src/app/(authenticated)/assets/page.tsx`:
```tsx
export default function AssetsPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">장비 관리</h1>
      <p className="text-muted-foreground">B4에서 구현</p>
    </div>
  );
}
```

`frontend/src/app/(authenticated)/rentals/page.tsx`:
```tsx
export default function RentalsPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">대여 관리</h1>
      <p className="text-muted-foreground">B5에서 구현</p>
    </div>
  );
}
```

`frontend/src/app/(authenticated)/notifications/page.tsx`:
```tsx
export default function NotificationsPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">알림</h1>
      <p className="text-muted-foreground">B6에서 구현</p>
    </div>
  );
}
```

`frontend/src/app/(authenticated)/users/page.tsx`:
```tsx
export default function UsersPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">사용자 관리</h1>
      <p className="text-muted-foreground">B7에서 구현</p>
    </div>
  );
}
```

`frontend/src/app/(authenticated)/profile/page.tsx`:
```tsx
export default function ProfilePage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">내 프로필</h1>
      <p className="text-muted-foreground">B7에서 구현</p>
    </div>
  );
}
```

- [ ] **Step 5: 빌드 확인**

```bash
cd frontend && npm run build
```

Expected: BUILD 성공, 모든 페이지 라우트 정상 생성

- [ ] **Step 6: 개발 서버 실행 및 브라우저 확인**

```bash
cd frontend && npm run dev
```

브라우저에서 확인:
- `http://localhost:3000` → `/dashboard` 리다이렉트
- `/dashboard` → Sidebar + Header + "대시보드" 텍스트
- `/assets` → Sidebar + Header + "장비 관리" 텍스트
- `/login` → 로그인 스텁 화면 (레이아웃 없음)
- Sidebar에서 각 네비게이션 항목 클릭 시 라우트 이동

- [ ] **Step 7: 커밋**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/src/middleware.ts frontend/src/app/
git commit -m "feat(frontend): 미들웨어 및 전체 페이지 스텁 생성"
```

---

## Task 11: 최종 빌드 검증 및 정리

**Files:**
- Modify: `frontend/.gitignore` (확인)

- [ ] **Step 1: .gitignore 확인**

`.env.local`이 gitignore에 포함되어 있는지 확인. 포함되어 있지 않으면 추가:
```
.env.local
```

- [ ] **Step 2: 전체 lint 확인**

```bash
cd frontend && npm run lint
```

Expected: lint 경고/에러 없음 (있으면 수정)

- [ ] **Step 3: 전체 빌드 확인**

```bash
cd frontend && npm run build
```

Expected: BUILD 성공

- [ ] **Step 4: 최종 커밋 (lint 수정 있을 경우)**

```bash
cd C:/JobmoaIntelliJFolder/jobmoa_EquipmentManagement
git add frontend/
git commit -m "chore(frontend): Phase B1 완료 - lint 정리 및 최종 빌드 검증"
```

---

## 검증 체크리스트

- [ ] `npm run build` 성공
- [ ] `npm run lint` 통과
- [ ] `npm run dev` → 브라우저에서 레이아웃 정상 렌더링
- [ ] Sidebar 네비게이션 동작
- [ ] 각 페이지 라우트 접근 가능
- [ ] axios 보안 감사 통과 (`npm audit --audit-level=high`)
