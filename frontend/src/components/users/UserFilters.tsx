'use client';

import { useState, useEffect } from 'react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from '@/components/ui/select';

interface UserSearchParams {
  page?: number;
  size?: number;
  sort?: string;
  role?: string;
  search?: string;
}

interface UserFiltersProps {
  params: UserSearchParams;
  onParamsChange: (params: Partial<UserSearchParams>) => void;
}

const ROLE_OPTIONS = [
  { value: '', label: '전체 역할' },
  { value: 'COUNSELOR', label: '상담사' },
  { value: 'MANAGER', label: '관리자' },
];

export function UserFilters({ params, onParamsChange }: UserFiltersProps) {
  const [searchInput, setSearchInput] = useState(params.search ?? '');

  useEffect(() => {
    const timer = setTimeout(() => {
      onParamsChange({ search: searchInput || undefined, page: 0 });
    }, 300);
    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchInput]);

  function handleRoleChange(value: string | null) {
    onParamsChange({ role: value || undefined, page: 0 });
  }

  function handleReset() {
    setSearchInput('');
    onParamsChange({ search: undefined, role: undefined, page: 0 });
  }

  return (
    <div className="flex flex-wrap items-end gap-3">
      <div className="min-w-[200px] flex-1">
        <Input
          placeholder="이름 또는 이메일로 검색..."
          value={searchInput}
          onChange={(e) => setSearchInput(e.target.value)}
        />
      </div>

      <div className="min-w-[140px]">
        <Select
          value={params.role ?? ''}
          onValueChange={handleRoleChange}
          items={ROLE_OPTIONS}
        >
          <SelectTrigger className="w-full">
            <SelectValue placeholder="전체 역할" />
          </SelectTrigger>
          <SelectContent>
            {ROLE_OPTIONS.map((opt) => (
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
