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
  const [searchInput, setSearchInput] = useState(params.search ?? '');

  // Debounce search input
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
          placeholder="장비명, 코드 또는 대여자로 검색..."
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
