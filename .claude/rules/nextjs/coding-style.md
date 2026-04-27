# Next.js 코딩 스타일

> 이 프로젝트: Next.js (App Router) + TypeScript + Tailwind CSS

## 프로젝트 구조 (App Router)

```
frontend/
├── src/
│   ├── app/                    # App Router 페이지
│   │   ├── layout.tsx          # Root Layout
│   │   ├── page.tsx            # 홈 (대시보드)
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── assets/
│   │   │   ├── page.tsx        # 장비 목록
│   │   │   ├── [id]/
│   │   │   │   └── page.tsx    # 장비 상세
│   │   │   └── new/
│   │   │       └── page.tsx    # 장비 등록
│   │   └── rentals/
│   │       ├── page.tsx        # 대여 현황
│   │       └── [id]/
│   │           └── page.tsx    # 대여 상세
│   ├── components/             # 재사용 컴포넌트
│   │   ├── ui/                 # 기본 UI (Button, Input, Modal 등)
│   │   ├── assets/             # 장비 관련 컴포넌트
│   │   ├── rentals/            # 대여 관련 컴포넌트
│   │   └── layout/             # 레이아웃 (Header, Sidebar, Nav)
│   ├── lib/                    # 유틸리티, API 클라이언트
│   │   ├── api/                # API 호출 함수
│   │   ├── auth/               # JWT 인증 유틸
│   │   └── utils/              # 헬퍼 함수
│   ├── hooks/                  # 커스텀 훅
│   ├── store/                  # 상태관리 (Zustand)
│   ├── types/                  # TypeScript 타입 정의
│   └── styles/                 # 전역 스타일
├── public/                     # 정적 파일
├── next.config.ts
├── tailwind.config.ts
└── tsconfig.json
```

## 네이밍 컨벤션

| 대상 | 규칙 | 예시 |
|------|------|------|
| 컴포넌트 파일 | PascalCase.tsx | `AssetCard.tsx` |
| 유틸/훅 파일 | camelCase.ts | `useAssets.ts`, `formatDate.ts` |
| 컴포넌트 | PascalCase | `AssetListTable`, `RentalStatusBadge` |
| 함수/변수 | camelCase | `fetchAssets`, `isLoading` |
| 타입/인터페이스 | PascalCase | `Asset`, `RentalResponse` |
| 상수 | UPPER_SNAKE_CASE | `API_BASE_URL`, `MAX_PAGE_SIZE` |
| CSS 클래스 | Tailwind 유틸리티 | `className="flex items-center gap-2"` |

## Server/Client 컴포넌트 분리

```tsx
// 기본값: Server Component (데이터 fetching)
// app/assets/page.tsx
export default async function AssetsPage() {
  const assets = await fetchAssets(); // 서버에서 직접 호출
  return <AssetList assets={assets} />;
}

// 상호작용 필요 시만 Client Component
// components/assets/AssetSearchBar.tsx
'use client';
export function AssetSearchBar() {
  const [query, setQuery] = useState('');
  // ...
}
```

## API 호출 패턴

```typescript
// lib/api/assets.ts
const API_BASE = process.env.NEXT_PUBLIC_API_URL;

export async function fetchAssets(params?: AssetSearchParams): Promise<ApiResponse<Asset[]>> {
  const res = await fetch(`${API_BASE}/api/v1/assets?${new URLSearchParams(params)}`, {
    headers: { Authorization: `Bearer ${getAccessToken()}` },
  });
  if (!res.ok) throw new ApiError(res.status, await res.text());
  return res.json();
}
```

## 금지 사항

- `any` 타입 사용 금지 → `unknown` 또는 구체적 타입 사용
- `useEffect`로 데이터 fetching 금지 → Server Component 또는 SWR/React Query
- 인라인 스타일 금지 → Tailwind 유틸리티 클래스 사용
- API URL 하드코딩 금지 → 환경변수 사용
- `console.log` 프로덕션 코드에 금지 → 개발 중에만 사용
- `document` / `window` Server Component에서 접근 금지
