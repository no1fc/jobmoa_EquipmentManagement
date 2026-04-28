'use client';

import { useState, useCallback } from 'react';
import Link from 'next/link';
import type { AssetSearchParams } from '@/types/asset';
import { useAssets } from '@/hooks/useAssets';
import { useCategoryTree } from '@/hooks/useCategories';
import { AssetFilters } from '@/components/assets/AssetFilters';
import { AssetTable } from '@/components/assets/AssetTable';
import { AssetPagination } from '@/components/assets/AssetPagination';
import { Button } from '@/components/ui/button';

const DEFAULT_PARAMS: AssetSearchParams = {
  page: 0,
  size: 20,
  sort: 'createdAt,desc',
};

export default function AssetsPage() {
  const [params, setParams] = useState<AssetSearchParams>(DEFAULT_PARAMS);
  const { data: pageData, isLoading } = useAssets(params);
  const { data: categoryTree } = useCategoryTree();

  const handleParamsChange = useCallback((partial: Partial<AssetSearchParams>) => {
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
        <h1 className="text-2xl font-bold">장비 관리</h1>
        <Link href="/assets/new">
          <Button>
            <PlusIcon />
            <span className="ml-1.5">장비 등록</span>
          </Button>
        </Link>
      </div>

      <AssetFilters
        params={params}
        onParamsChange={handleParamsChange}
        categoryTree={categoryTree ?? []}
      />

      <AssetTable
        assets={pageData?.content ?? []}
        isLoading={isLoading}
        sort={params.sort}
        onSortChange={handleSortChange}
      />

      {pageData && (
        <AssetPagination
          page={pageData.page}
          totalPages={pageData.totalPages}
          totalElements={pageData.totalElements}
          isLast={pageData.last}
          onPageChange={handlePageChange}
        />
      )}
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
