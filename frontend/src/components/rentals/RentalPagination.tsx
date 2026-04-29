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
