'use client';

import { useState, useEffect } from 'react';
import type { AssetStatus, AssetSearchParams } from '@/types/asset';
import type { CategoryTree } from '@/types/category';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from '@/components/ui/select';
import { CategoryCascadeSelect } from './CategoryCascadeSelect';

interface AssetFiltersProps {
  params: AssetSearchParams;
  onParamsChange: (params: Partial<AssetSearchParams>) => void;
  categoryTree: CategoryTree[];
}

const STATUS_OPTIONS: { value: string; label: string }[] = [
  { value: '', label: '전체 상태' },
  { value: 'IN_USE', label: '사용중' },
  { value: 'RENTED', label: '대여중' },
  { value: 'BROKEN', label: '고장' },
  { value: 'IN_STORAGE', label: '보관중' },
  { value: 'DISPOSED', label: '폐기' },
];

export function AssetFilters({ params, onParamsChange, categoryTree }: AssetFiltersProps) {
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
      status: (value || undefined) as AssetStatus | undefined,
      page: 0,
    });
  }

  function handleCategoryChange(categoryId: number | undefined) {
    onParamsChange({ categoryId, page: 0 });
  }

  function handleReset() {
    setSearchInput('');
    onParamsChange({
      search: undefined,
      status: undefined,
      categoryId: undefined,
      page: 0,
    });
  }

  return (
    <div className="flex flex-wrap items-end gap-3">
      <div className="min-w-[200px] flex-1">
        <Input
          placeholder="장비명 또는 코드로 검색..."
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

      <CategoryCascadeSelect
        value={params.categoryId}
        onChange={handleCategoryChange}
        categoryTree={categoryTree}
        allowAll
      />

      <Button variant="outline" size="sm" onClick={handleReset}>
        초기화
      </Button>
    </div>
  );
}
