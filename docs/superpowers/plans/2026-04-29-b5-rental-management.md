# B5 대여 관리 화면 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Next.js 프론트엔드에 대여 관리 화면 (목록/상세/등록/반납/연장/취소)을 구현한다.

**Architecture:** B4 장비 관리 화면과 동일한 패턴 — React Query 훅 + Zod 검증 + components/rentals/ 컴포넌트 + App Router 페이지. 대여 등록은 필드가 적으므로 별도 페이지 대신 Dialog로 구현. 반납/연장/취소도 각각 Dialog.

**Tech Stack:** Next.js 16 (App Router), TypeScript, TanStack React Query v5, Zustand, react-hook-form, zod, shadcn/ui v2, Tailwind CSS 4, sonner toast

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `frontend/src/hooks/useRentals.ts` | React Query 훅 (목록/상세 조회 + CRUD mutations) |
| Create | `frontend/src/lib/validations/rental.ts` | Zod 스키마 (대여 생성, 반납, 연장) |
| Create | `frontend/src/components/rentals/RentalStatusBadge.tsx` | 대여 상태 배지 (4종) |
| Create | `frontend/src/components/rentals/RentalFilters.tsx` | 검색 + 상태 필터 |
| Create | `frontend/src/components/rentals/RentalTable.tsx` | 대여 목록 테이블 |
| Create | `frontend/src/components/rentals/RentalPagination.tsx` | 페이지네이션 |
| Create | `frontend/src/components/rentals/CreateRentalDialog.tsx` | 대여 등록 다이얼로그 |
| Create | `frontend/src/components/rentals/ReturnDialog.tsx` | 반납 다이얼로그 |
| Create | `frontend/src/components/rentals/ExtendDialog.tsx` | 연장 다이얼로그 |
| Create | `frontend/src/components/rentals/CancelConfirmDialog.tsx` | 취소 확인 다이얼로그 |
| Create | `frontend/src/components/rentals/RentalDetailInfo.tsx` | 상세 정보 카드 |
| Modify | `frontend/src/app/(authenticated)/rentals/page.tsx` | 대여 목록 페이지 (스텁 → 구현) |
| Create | `frontend/src/app/(authenticated)/rentals/[id]/page.tsx` | 대여 상세 페이지 |

---

### Task 1: React Query 훅 — `useRentals.ts`

**Files:**
- Create: `frontend/src/hooks/useRentals.ts`

- [ ] **Step 1: Create useRentals.ts with all hooks**

```typescript
// frontend/src/hooks/useRentals.ts
import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  fetchRentals,
  fetchRental,
  createRental,
  returnRental,
  extendRental,
  cancelRental,
} from '@/lib/api/rentals';
import type { RentalSearchParams, RentalCreateRequest, RentalReturnRequest, RentalExtendRequest } from '@/types/rental';

export function useRentals(params?: RentalSearchParams) {
  return useQuery({
    queryKey: ['rentals', params],
    queryFn: () => fetchRentals(params),
    select: (res) => res.data,
    placeholderData: keepPreviousData,
  });
}

export function useRental(id: number) {
  return useQuery({
    queryKey: ['rentals', id],
    queryFn: () => fetchRental(id),
    select: (res) => res.data,
    enabled: !!id,
  });
}

export function useCreateRental() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (request: RentalCreateRequest) => createRental(request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rentals'] });
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      toast.success('대여가 등록되었습니다.');
    },
    onError: () => {
      toast.error('대여 등록에 실패했습니다.');
    },
  });
}

export function useReturnRental() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, request }: { id: number; request: RentalReturnRequest }) =>
      returnRental(id, request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rentals'] });
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      toast.success('반납이 완료되었습니다.');
    },
    onError: () => {
      toast.error('반납 처리에 실패했습니다.');
    },
  });
}

export function useExtendRental() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, request }: { id: number; request: RentalExtendRequest }) =>
      extendRental(id, request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rentals'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      toast.success('대여 기간이 연장되었습니다.');
    },
    onError: () => {
      toast.error('연장에 실패했습니다.');
    },
  });
}

export function useCancelRental() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => cancelRental(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rentals'] });
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      toast.success('대여가 취소되었습니다.');
    },
    onError: () => {
      toast.error('대여 취소에 실패했습니다.');
    },
  });
}
```

- [ ] **Step 2: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add frontend/src/hooks/useRentals.ts
git commit -m "feat(frontend): B5 대여 관리 React Query 훅 추가"
```

---

### Task 2: Zod 검증 스키마 — `rental.ts`

**Files:**
- Create: `frontend/src/lib/validations/rental.ts`

- [ ] **Step 1: Create rental validation schemas**

```typescript
// frontend/src/lib/validations/rental.ts
import { z } from 'zod';

export const rentalCreateSchema = z.object({
  assetId: z
    .number({ error: '장비를 선택해주세요.' })
    .positive({ message: '장비를 선택해주세요.' }),
  borrowerName: z.string().max(100).optional().or(z.literal('')),
  rentalReason: z.string().max(500).optional().or(z.literal('')),
  dueDays: z
    .number({ error: '대여 기간을 입력해주세요.' })
    .min(1, { message: '최소 1일입니다.' })
    .max(30, { message: '최대 30일입니다.' }),
});

export type RentalCreateFormValues = z.infer<typeof rentalCreateSchema>;

export const rentalReturnSchema = z.object({
  returnCondition: z.string().max(500).optional().or(z.literal('')),
});

export type RentalReturnFormValues = z.infer<typeof rentalReturnSchema>;

export const rentalExtendSchema = z.object({
  extensionDays: z
    .number({ error: '연장 일수를 입력해주세요.' })
    .min(1, { message: '최소 1일입니다.' })
    .max(14, { message: '최대 14일입니다.' }),
});

export type RentalExtendFormValues = z.infer<typeof rentalExtendSchema>;
```

- [ ] **Step 2: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add frontend/src/lib/validations/rental.ts
git commit -m "feat(frontend): B5 대여 Zod 검증 스키마 추가"
```

---

### Task 3: RentalStatusBadge 컴포넌트

**Files:**
- Create: `frontend/src/components/rentals/RentalStatusBadge.tsx`

- [ ] **Step 1: Create RentalStatusBadge**

```typescript
// frontend/src/components/rentals/RentalStatusBadge.tsx
import type { RentalStatus } from '@/types/rental';

const STATUS_CONFIG: Record<RentalStatus, { label: string; className: string }> = {
  RENTED: { label: '대여중', className: 'bg-[#f2f9ff] text-[#0075de]' },
  OVERDUE: { label: '연체', className: 'bg-[#fef2f2] text-[#dc2626]' },
  RETURNED: { label: '반납완료', className: 'bg-[#f0fdf4] text-[#16a34a]' },
  CANCELLED: { label: '취소', className: 'bg-[#f6f5f4] text-[#615d59]' },
};

interface RentalStatusBadgeProps {
  status: RentalStatus;
}

export function RentalStatusBadge({ status }: RentalStatusBadgeProps) {
  const config = STATUS_CONFIG[status];
  return (
    <span
      className={`inline-flex items-center rounded-[9999px] px-2.5 py-0.5 text-xs font-semibold tracking-[0.125px] ${config.className}`}
    >
      {config.label}
    </span>
  );
}

export function getRentalStatusLabel(status: RentalStatus): string {
  return STATUS_CONFIG[status].label;
}
```

- [ ] **Step 2: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add frontend/src/components/rentals/RentalStatusBadge.tsx
git commit -m "feat(frontend): B5 RentalStatusBadge 컴포넌트 추가"
```

---

### Task 4: RentalFilters 컴포넌트

**Files:**
- Create: `frontend/src/components/rentals/RentalFilters.tsx`

- [ ] **Step 1: Create RentalFilters**

```typescript
// frontend/src/components/rentals/RentalFilters.tsx
'use client';

import { useState, useEffect } from 'react';
import type { RentalStatus, RentalSearchParams } from '@/types/rental';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from '@/components/ui/select';

interface RentalFiltersProps {
  params: RentalSearchParams;
  onParamsChange: (params: Partial<RentalSearchParams>) => void;
}

const STATUS_OPTIONS: { value: string; label: string }[] = [
  { value: '', label: '전체 상태' },
  { value: 'RENTED', label: '대여중' },
  { value: 'OVERDUE', label: '연체' },
  { value: 'RETURNED', label: '반납완료' },
  { value: 'CANCELLED', label: '취소' },
];

export function RentalFilters({ params, onParamsChange }: RentalFiltersProps) {
  const [searchInput, setSearchInput] = useState('');

  useEffect(() => {
    const timer = setTimeout(() => {
      onParamsChange({ search: searchInput || undefined, page: 0 });
    }, 300);
    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchInput]);

  function handleStatusChange(value: string | null) {
    onParamsChange({
      status: (value || undefined) as RentalStatus | undefined,
      page: 0,
    });
  }

  function handleReset() {
    setSearchInput('');
    onParamsChange({
      search: undefined,
      status: undefined,
      page: 0,
    });
  }

  return (
    <div className="flex flex-wrap items-end gap-3">
      <div className="min-w-[200px] flex-1">
        <Input
          placeholder="장비명 또는 대여자로 검색..."
          value={searchInput}
          onChange={(e) => setSearchInput(e.target.value)}
        />
      </div>

      <div className="min-w-[140px]">
        <Select
          value={params.status ?? ''}
          onValueChange={handleStatusChange}
          items={STATUS_OPTIONS}
        >
          <SelectTrigger className="w-full">
            <SelectValue placeholder="전체 상태" />
          </SelectTrigger>
          <SelectContent>
            {STATUS_OPTIONS.map((opt) => (
              <SelectItem key={opt.value} value={opt.value}>
                {opt.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <Button variant="outline" size="sm" onClick={handleReset}>
        초기화
      </Button>
    </div>
  );
}
```

> **Note:** `RentalSearchParams`에 `search` 필드가 없을 수 있다. 백엔드 API가 검색 파라미터를 지원하는지 확인 후, 지원하지 않으면 `search` 관련 코드를 제거하고 상태 필터만 남긴다. `RentalSearchParams` 타입에 `search?: string`을 추가해야 할 수 있다.

- [ ] **Step 2: Check if RentalSearchParams needs `search` field**

`frontend/src/types/rental.ts`의 `RentalSearchParams`를 확인하고, `search` 필드가 없으면 추가한다:

```typescript
export interface RentalSearchParams {
  page?: number;
  size?: number;
  status?: RentalStatus;
  borrowerId?: number;
  assetId?: number;
  search?: string;  // 추가
  sort?: string;
}
```

- [ ] **Step 3: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 4: Commit**

```bash
git add frontend/src/components/rentals/RentalFilters.tsx frontend/src/types/rental.ts
git commit -m "feat(frontend): B5 RentalFilters 컴포넌트 추가"
```

---

### Task 5: RentalTable + RentalPagination 컴포넌트

**Files:**
- Create: `frontend/src/components/rentals/RentalTable.tsx`
- Create: `frontend/src/components/rentals/RentalPagination.tsx`

- [ ] **Step 1: Create RentalTable**

```typescript
// frontend/src/components/rentals/RentalTable.tsx
'use client';

import Link from 'next/link';
import type { Rental } from '@/types/rental';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Skeleton } from '@/components/ui/skeleton';
import { RentalStatusBadge } from './RentalStatusBadge';

interface RentalTableProps {
  rentals: Rental[];
  isLoading: boolean;
  sort?: string;
  onSortChange: (sort: string) => void;
}

interface SortableHeaderProps {
  label: string;
  field: string;
  currentSort?: string;
  onSortChange: (sort: string) => void;
}

function SortableHeader({ label, field, currentSort, onSortChange }: SortableHeaderProps) {
  const [currentField, currentDir] = (currentSort ?? '').split(',');
  const isActive = currentField === field;
  const nextDir = isActive && currentDir === 'asc' ? 'desc' : 'asc';

  return (
    <TableHead
      className="cursor-pointer select-none hover:bg-[#f6f5f4]"
      onClick={() => onSortChange(`${field},${nextDir}`)}
    >
      <span className="flex items-center gap-1">
        {label}
        {isActive && (
          <span className="text-xs">{currentDir === 'asc' ? '▲' : '▼'}</span>
        )}
      </span>
    </TableHead>
  );
}

function formatDate(dateStr: string | null): string {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
}

function getOverdueDays(dueDate: string, status: string): number | null {
  if (status !== 'RENTED' && status !== 'OVERDUE') return null;
  const due = new Date(dueDate);
  const now = new Date();
  const diff = Math.floor((now.getTime() - due.getTime()) / (1000 * 60 * 60 * 24));
  return diff > 0 ? diff : null;
}

export function RentalTable({ rentals, isLoading, sort, onSortChange }: RentalTableProps) {
  if (isLoading) {
    return (
      <div className="space-y-2">
        {Array.from({ length: 5 }).map((_, i) => (
          <Skeleton key={i} className="h-12 w-full" />
        ))}
      </div>
    );
  }

  if (rentals.length === 0) {
    return (
      <div className="flex h-40 items-center justify-center text-[#615d59]">
        대여 기록이 없습니다.
      </div>
    );
  }

  return (
    <div className="rounded-[12px] border border-[rgba(0,0,0,0.1)] shadow-[var(--shadow-card)]">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>장비코드</TableHead>
            <TableHead>장비명</TableHead>
            <TableHead>대여자</TableHead>
            <SortableHeader label="대여일" field="rentalDate" currentSort={sort} onSortChange={onSortChange} />
            <SortableHeader label="반납기한" field="dueDate" currentSort={sort} onSortChange={onSortChange} />
            <TableHead>상태</TableHead>
            <TableHead>연체일수</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {rentals.map((rental) => {
            const overdueDays = getOverdueDays(rental.dueDate, rental.status);
            const isOverdue = rental.status === 'OVERDUE' || overdueDays !== null;
            return (
              <TableRow
                key={rental.rentalId}
                className={`cursor-pointer hover:bg-[#f6f5f4] ${isOverdue ? 'bg-[#fef2f2]' : ''}`}
              >
                <TableCell>
                  <Link href={`/rentals/${rental.rentalId}`} className="font-mono text-sm">
                    {rental.assetCode}
                  </Link>
                </TableCell>
                <TableCell>
                  <Link
                    href={`/rentals/${rental.rentalId}`}
                    className="font-medium text-foreground hover:text-[#0075de] hover:underline"
                  >
                    {rental.assetName}
                  </Link>
                </TableCell>
                <TableCell className="text-[#615d59]">{rental.borrowerName ?? rental.borrowerEmail}</TableCell>
                <TableCell className="text-[#615d59]">{formatDate(rental.rentalDate)}</TableCell>
                <TableCell className="text-[#615d59]">{formatDate(rental.dueDate)}</TableCell>
                <TableCell>
                  <RentalStatusBadge status={rental.status} />
                </TableCell>
                <TableCell>
                  {overdueDays !== null ? (
                    <span className="font-semibold text-[#dc2626]">{overdueDays}일</span>
                  ) : (
                    '-'
                  )}
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </div>
  );
}
```

- [ ] **Step 2: Create RentalPagination**

```typescript
// frontend/src/components/rentals/RentalPagination.tsx
'use client';

import { Button } from '@/components/ui/button';

interface RentalPaginationProps {
  page: number;
  totalPages: number;
  totalElements: number;
  isLast: boolean;
  onPageChange: (page: number) => void;
}

export function RentalPagination({
  page,
  totalPages,
  totalElements,
  isLast,
  onPageChange,
}: RentalPaginationProps) {
  if (totalPages <= 1) return null;

  return (
    <div className="flex items-center justify-between">
      <p className="text-sm text-[#615d59]">
        {page + 1} / {totalPages} 페이지 (총 {totalElements}건)
      </p>
      <div className="flex gap-2">
        <Button
          variant="outline"
          size="sm"
          disabled={page === 0}
          onClick={() => onPageChange(page - 1)}
        >
          이전
        </Button>
        <Button
          variant="outline"
          size="sm"
          disabled={isLast}
          onClick={() => onPageChange(page + 1)}
        >
          다음
        </Button>
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 4: Commit**

```bash
git add frontend/src/components/rentals/RentalTable.tsx frontend/src/components/rentals/RentalPagination.tsx
git commit -m "feat(frontend): B5 RentalTable, RentalPagination 컴포넌트 추가"
```

---

### Task 6: CreateRentalDialog 컴포넌트

**Files:**
- Create: `frontend/src/components/rentals/CreateRentalDialog.tsx`

- [ ] **Step 1: Create CreateRentalDialog**

```typescript
// frontend/src/components/rentals/CreateRentalDialog.tsx
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useCreateRental } from '@/hooks/useRentals';
import { rentalCreateSchema, type RentalCreateFormValues } from '@/lib/validations/rental';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface CreateRentalDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function CreateRentalDialog({ open, onOpenChange }: CreateRentalDialogProps) {
  const mutation = useCreateRental();
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<RentalCreateFormValues>({
    resolver: zodResolver(rentalCreateSchema),
    defaultValues: {
      assetId: undefined,
      borrowerName: '',
      rentalReason: '',
      dueDays: 7,
    },
  });

  function onSubmit(values: RentalCreateFormValues) {
    mutation.mutate(
      {
        assetId: values.assetId,
        borrowerName: values.borrowerName || undefined,
        rentalReason: values.rentalReason || undefined,
        dueDays: values.dueDays,
      },
      {
        onSuccess: () => {
          onOpenChange(false);
          reset();
        },
      },
    );
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(v) => {
        onOpenChange(v);
        if (!v) reset();
      }}
    >
      <DialogContent>
        <DialogHeader>
          <DialogTitle>새 대여 등록</DialogTitle>
          <DialogDescription>장비를 대여합니다. 장비 ID와 대여 기간을 입력하세요.</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="assetId">장비 ID *</Label>
            <Input
              id="assetId"
              type="number"
              placeholder="대여할 장비의 ID를 입력하세요"
              {...register('assetId', { valueAsNumber: true })}
            />
            {errors.assetId && (
              <p className="text-sm text-[#dc2626]">{errors.assetId.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="borrowerName">대여자 이름</Label>
            <Input
              id="borrowerName"
              placeholder="대여자 이름 (선택)"
              {...register('borrowerName')}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="rentalReason">대여 사유</Label>
            <Textarea
              id="rentalReason"
              placeholder="대여 사유를 입력하세요 (선택)"
              rows={3}
              {...register('rentalReason')}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="dueDays">대여 기간 (일) *</Label>
            <Input
              id="dueDays"
              type="number"
              min={1}
              max={30}
              {...register('dueDays', { valueAsNumber: true })}
            />
            {errors.dueDays && (
              <p className="text-sm text-[#dc2626]">{errors.dueDays.message}</p>
            )}
            <p className="text-xs text-[#a39e98]">1일 ~ 30일 (기본 7일)</p>
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              취소
            </Button>
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? '등록 중...' : '대여 등록'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
```

- [ ] **Step 2: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add frontend/src/components/rentals/CreateRentalDialog.tsx
git commit -m "feat(frontend): B5 CreateRentalDialog 컴포넌트 추가"
```

---

### Task 7: ReturnDialog + ExtendDialog + CancelConfirmDialog

**Files:**
- Create: `frontend/src/components/rentals/ReturnDialog.tsx`
- Create: `frontend/src/components/rentals/ExtendDialog.tsx`
- Create: `frontend/src/components/rentals/CancelConfirmDialog.tsx`

- [ ] **Step 1: Create ReturnDialog**

```typescript
// frontend/src/components/rentals/ReturnDialog.tsx
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useReturnRental } from '@/hooks/useRentals';
import { rentalReturnSchema, type RentalReturnFormValues } from '@/lib/validations/rental';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface ReturnDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  rentalId: number;
  assetName: string;
}

export function ReturnDialog({ open, onOpenChange, rentalId, assetName }: ReturnDialogProps) {
  const mutation = useReturnRental();
  const {
    register,
    handleSubmit,
    reset,
  } = useForm<RentalReturnFormValues>({
    resolver: zodResolver(rentalReturnSchema),
    defaultValues: { returnCondition: '' },
  });

  function onSubmit(values: RentalReturnFormValues) {
    mutation.mutate(
      { id: rentalId, request: { returnCondition: values.returnCondition || undefined } },
      {
        onSuccess: () => {
          onOpenChange(false);
          reset();
        },
      },
    );
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(v) => {
        onOpenChange(v);
        if (!v) reset();
      }}
    >
      <DialogContent>
        <DialogHeader>
          <DialogTitle>반납 처리</DialogTitle>
          <DialogDescription>
            &apos;{assetName}&apos; 장비를 반납합니다.
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="returnCondition">반납 상태 메모</Label>
            <Textarea
              id="returnCondition"
              placeholder="반납 시 장비 상태를 기록하세요 (선택)"
              rows={3}
              {...register('returnCondition')}
            />
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              취소
            </Button>
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? '처리 중...' : '반납 확인'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
```

- [ ] **Step 2: Create ExtendDialog**

```typescript
// frontend/src/components/rentals/ExtendDialog.tsx
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useExtendRental } from '@/hooks/useRentals';
import { rentalExtendSchema, type RentalExtendFormValues } from '@/lib/validations/rental';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface ExtendDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  rentalId: number;
  assetName: string;
  currentDueDate: string;
}

export function ExtendDialog({
  open,
  onOpenChange,
  rentalId,
  assetName,
  currentDueDate,
}: ExtendDialogProps) {
  const mutation = useExtendRental();
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<RentalExtendFormValues>({
    resolver: zodResolver(rentalExtendSchema),
    defaultValues: { extensionDays: 7 },
  });

  const formattedDueDate = new Date(currentDueDate).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });

  function onSubmit(values: RentalExtendFormValues) {
    mutation.mutate(
      { id: rentalId, request: { extensionDays: values.extensionDays } },
      {
        onSuccess: () => {
          onOpenChange(false);
          reset();
        },
      },
    );
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(v) => {
        onOpenChange(v);
        if (!v) reset();
      }}
    >
      <DialogContent>
        <DialogHeader>
          <DialogTitle>대여 연장</DialogTitle>
          <DialogDescription>
            &apos;{assetName}&apos; 대여 기간을 연장합니다. 현재 반납기한: {formattedDueDate}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="extensionDays">연장 일수 *</Label>
            <Input
              id="extensionDays"
              type="number"
              min={1}
              max={14}
              {...register('extensionDays', { valueAsNumber: true })}
            />
            {errors.extensionDays && (
              <p className="text-sm text-[#dc2626]">{errors.extensionDays.message}</p>
            )}
            <p className="text-xs text-[#a39e98]">1일 ~ 14일 (연장은 최대 1회만 가능)</p>
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              취소
            </Button>
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? '처리 중...' : '연장 확인'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
```

- [ ] **Step 3: Create CancelConfirmDialog**

```typescript
// frontend/src/components/rentals/CancelConfirmDialog.tsx
'use client';

import { useCancelRental } from '@/hooks/useRentals';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface CancelConfirmDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  rentalId: number;
  assetName: string;
}

export function CancelConfirmDialog({
  open,
  onOpenChange,
  rentalId,
  assetName,
}: CancelConfirmDialogProps) {
  const mutation = useCancelRental();

  function handleCancel() {
    mutation.mutate(rentalId, {
      onSuccess: () => {
        onOpenChange(false);
      },
    });
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>대여 취소</DialogTitle>
          <DialogDescription>
            &apos;{assetName}&apos; 대여를 취소하시겠습니까? 이 작업은 되돌릴 수 없습니다.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            닫기
          </Button>
          <Button variant="destructive" onClick={handleCancel} disabled={mutation.isPending}>
            {mutation.isPending ? '취소 중...' : '대여 취소'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
```

- [ ] **Step 4: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 5: Commit**

```bash
git add frontend/src/components/rentals/ReturnDialog.tsx frontend/src/components/rentals/ExtendDialog.tsx frontend/src/components/rentals/CancelConfirmDialog.tsx
git commit -m "feat(frontend): B5 반납/연장/취소 다이얼로그 컴포넌트 추가"
```

---

### Task 8: 대여 목록 페이지

**Files:**
- Modify: `frontend/src/app/(authenticated)/rentals/page.tsx`

- [ ] **Step 1: Implement rentals list page**

```typescript
// frontend/src/app/(authenticated)/rentals/page.tsx
'use client';

import { useState, useCallback } from 'react';
import type { RentalSearchParams } from '@/types/rental';
import { useRentals } from '@/hooks/useRentals';
import { RentalFilters } from '@/components/rentals/RentalFilters';
import { RentalTable } from '@/components/rentals/RentalTable';
import { RentalPagination } from '@/components/rentals/RentalPagination';
import { CreateRentalDialog } from '@/components/rentals/CreateRentalDialog';
import { Button } from '@/components/ui/button';

const DEFAULT_PARAMS: RentalSearchParams = {
  page: 0,
  size: 20,
  sort: 'rentalDate,desc',
};

export default function RentalsPage() {
  const [params, setParams] = useState<RentalSearchParams>(DEFAULT_PARAMS);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const { data: pageData, isLoading } = useRentals(params);

  const handleParamsChange = useCallback((partial: Partial<RentalSearchParams>) => {
    setParams((prev) => ({ ...prev, ...partial }));
  }, []);

  const handleSortChange = useCallback((sort: string) => {
    setParams((prev) => ({ ...prev, sort, page: 0 }));
  }, []);

  const handlePageChange = useCallback((page: number) => {
    setParams((prev) => ({ ...prev, page }));
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-[26px] font-bold tracking-[-0.625px]">대여 관리</h1>
        <Button onClick={() => setCreateDialogOpen(true)}>
          <PlusIcon />
          <span className="ml-1.5">새 대여</span>
        </Button>
      </div>

      <RentalFilters params={params} onParamsChange={handleParamsChange} />

      <RentalTable
        rentals={pageData?.content ?? []}
        isLoading={isLoading}
        sort={params.sort}
        onSortChange={handleSortChange}
      />

      {pageData && (
        <RentalPagination
          page={pageData.page}
          totalPages={pageData.totalPages}
          totalElements={pageData.totalElements}
          isLast={pageData.last}
          onPageChange={handlePageChange}
        />
      )}

      <CreateRentalDialog open={createDialogOpen} onOpenChange={setCreateDialogOpen} />
    </div>
  );
}

function PlusIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12h14" /><path d="M12 5v14" />
    </svg>
  );
}
```

- [ ] **Step 2: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add frontend/src/app/\(authenticated\)/rentals/page.tsx
git commit -m "feat(frontend): B5 대여 목록 페이지 구현"
```

---

### Task 9: RentalDetailInfo 컴포넌트

**Files:**
- Create: `frontend/src/components/rentals/RentalDetailInfo.tsx`

- [ ] **Step 1: Create RentalDetailInfo**

```typescript
// frontend/src/components/rentals/RentalDetailInfo.tsx
import Link from 'next/link';
import type { Rental } from '@/types/rental';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { RentalStatusBadge } from './RentalStatusBadge';

interface RentalDetailInfoProps {
  rental: Rental;
}

function InfoRow({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
      <span className="min-w-[120px] text-sm font-medium text-[#615d59]">{label}</span>
      <span className="text-sm">{value || '-'}</span>
    </div>
  );
}

function formatDate(dateStr: string | null | undefined): string {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
}

function getOverdueDays(dueDate: string, status: string): number | null {
  if (status !== 'RENTED' && status !== 'OVERDUE') return null;
  const due = new Date(dueDate);
  const now = new Date();
  const diff = Math.floor((now.getTime() - due.getTime()) / (1000 * 60 * 60 * 24));
  return diff > 0 ? diff : null;
}

export function RentalDetailInfo({ rental }: RentalDetailInfoProps) {
  const overdueDays = getOverdueDays(rental.dueDate, rental.status);

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
      {/* 대여 정보 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">대여 정보</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
            <span className="min-w-[120px] text-sm font-medium text-[#615d59]">상태</span>
            <RentalStatusBadge status={rental.status} />
          </div>
          <InfoRow label="대여자" value={rental.borrowerName ?? rental.borrowerEmail} />
          <InfoRow label="대여일" value={formatDate(rental.rentalDate)} />
          <InfoRow label="반납기한" value={formatDate(rental.dueDate)} />
          <InfoRow label="반납일" value={formatDate(rental.returnDate)} />
          <InfoRow label="연장횟수" value={`${rental.extensionCount}회 / 최대 1회`} />
          {overdueDays !== null && (
            <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
              <span className="min-w-[120px] text-sm font-medium text-[#615d59]">연체일수</span>
              <span className="text-sm font-semibold text-[#dc2626]">{overdueDays}일</span>
            </div>
          )}
          <InfoRow label="대여사유" value={rental.rentalReason} />
          <InfoRow label="반납상태" value={rental.returnCondition} />
        </CardContent>
      </Card>

      {/* 장비 정보 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">장비 정보</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <InfoRow label="장비코드" value={rental.assetCode} />
          <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
            <span className="min-w-[120px] text-sm font-medium text-[#615d59]">장비명</span>
            <Link
              href={`/assets/${rental.assetId}`}
              className="text-sm text-[#0075de] hover:underline"
            >
              {rental.assetName}
            </Link>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
```

- [ ] **Step 2: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add frontend/src/components/rentals/RentalDetailInfo.tsx
git commit -m "feat(frontend): B5 RentalDetailInfo 컴포넌트 추가"
```

---

### Task 10: 대여 상세 페이지

**Files:**
- Create: `frontend/src/app/(authenticated)/rentals/[id]/page.tsx`

- [ ] **Step 1: Create rental detail page**

```typescript
// frontend/src/app/(authenticated)/rentals/[id]/page.tsx
'use client';

import { use, useState } from 'react';
import Link from 'next/link';
import { useRental } from '@/hooks/useRentals';
import { RentalDetailInfo } from '@/components/rentals/RentalDetailInfo';
import { ReturnDialog } from '@/components/rentals/ReturnDialog';
import { ExtendDialog } from '@/components/rentals/ExtendDialog';
import { CancelConfirmDialog } from '@/components/rentals/CancelConfirmDialog';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';

export default function RentalDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const rentalId = Number(id);
  const { data: rental, isLoading } = useRental(rentalId);

  const [returnDialogOpen, setReturnDialogOpen] = useState(false);
  const [extendDialogOpen, setExtendDialogOpen] = useState(false);
  const [cancelDialogOpen, setCancelDialogOpen] = useState(false);

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-64" />
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <Skeleton className="h-64" />
          <Skeleton className="h-64" />
        </div>
      </div>
    );
  }

  if (!rental) {
    return (
      <div className="space-y-4">
        <Link href="/rentals">
          <Button variant="ghost" size="sm">
            <ArrowLeftIcon />
            <span className="ml-1">목록으로</span>
          </Button>
        </Link>
        <div className="flex h-40 items-center justify-center text-[#615d59]">
          대여 정보를 찾을 수 없습니다.
        </div>
      </div>
    );
  }

  const isActive = rental.status === 'RENTED' || rental.status === 'OVERDUE';
  const canExtend = isActive && rental.extensionCount < 1;

  return (
    <div className="space-y-6">
      {/* 헤더 */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <Link href="/rentals">
            <Button variant="ghost" size="sm">
              <ArrowLeftIcon />
              <span className="ml-1">목록</span>
            </Button>
          </Link>
          <h1 className="text-[26px] font-bold tracking-[-0.625px]">
            {rental.assetName} 대여 상세
          </h1>
        </div>
        {isActive && (
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={() => setReturnDialogOpen(true)}>
              <CheckIcon />
              <span className="ml-1">반납</span>
            </Button>
            {canExtend && (
              <Button variant="outline" size="sm" onClick={() => setExtendDialogOpen(true)}>
                <CalendarIcon />
                <span className="ml-1">연장</span>
              </Button>
            )}
            <Button
              variant="destructive"
              size="sm"
              onClick={() => setCancelDialogOpen(true)}
            >
              <XIcon />
              <span className="ml-1">취소</span>
            </Button>
          </div>
        )}
      </div>

      {/* 상세 정보 */}
      <RentalDetailInfo rental={rental} />

      {/* 다이얼로그 */}
      <ReturnDialog
        open={returnDialogOpen}
        onOpenChange={setReturnDialogOpen}
        rentalId={rentalId}
        assetName={rental.assetName}
      />
      {canExtend && (
        <ExtendDialog
          open={extendDialogOpen}
          onOpenChange={setExtendDialogOpen}
          rentalId={rentalId}
          assetName={rental.assetName}
          currentDueDate={rental.dueDate}
        />
      )}
      <CancelConfirmDialog
        open={cancelDialogOpen}
        onOpenChange={setCancelDialogOpen}
        rentalId={rentalId}
        assetName={rental.assetName}
      />
    </div>
  );
}

function ArrowLeftIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="m12 19-7-7 7-7" /><path d="M19 12H5" />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20 6 9 17l-5-5" />
    </svg>
  );
}

function CalendarIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M8 2v4" /><path d="M16 2v4" /><rect width="18" height="18" x="3" y="4" rx="2" /><path d="M3 10h18" />
    </svg>
  );
}

function XIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 6 6 18" /><path d="m6 6 12 12" />
    </svg>
  );
}
```

- [ ] **Step 2: Verify build**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL

- [ ] **Step 3: Commit**

```bash
git add frontend/src/app/\(authenticated\)/rentals/[id]/page.tsx
git commit -m "feat(frontend): B5 대여 상세 페이지 구현"
```

---

### Task 11: 최종 빌드 검증 + progress.md 업데이트

**Files:**
- Modify: `docs/progress.md`

- [ ] **Step 1: Full build verification**

Run: `cd frontend && npm run build`
Expected: BUILD SUCCESSFUL — 모든 페이지 정적 빌드 성공

Run: `cd frontend && npm run lint`
Expected: PASS — ESLint 에러 없음

- [ ] **Step 2: Update progress.md**

`docs/progress.md`에서:
1. B5 상태를 `✅ 완료`로 변경
2. Phase B 진행률을 `80% (B1~B5 완료)`로 변경
3. 전체 진행률 업데이트: `66% (Phase A 19일 + Phase B 8일 = 27일 of 42일)`
4. B5 섹션 완료일 및 산출물 기록

- [ ] **Step 3: Final commit**

```bash
git add docs/progress.md
git commit -m "docs: B5 대여 관리 화면 완료 — progress.md 업데이트"
```
