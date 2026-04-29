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
  const { data: pageData, isLoading } = useRentals(params);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);

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

      <RentalFilters
        params={params}
        onParamsChange={handleParamsChange}
      />

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

      <CreateRentalDialog
        open={createDialogOpen}
        onOpenChange={setCreateDialogOpen}
      />
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
