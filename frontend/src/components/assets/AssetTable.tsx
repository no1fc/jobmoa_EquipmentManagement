'use client';

import Link from 'next/link';
import type { Asset } from '@/types/asset';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Skeleton } from '@/components/ui/skeleton';
import { AssetStatusBadge } from './AssetStatusBadge';

interface AssetTableProps {
  assets: Asset[];
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
      className="cursor-pointer select-none hover:bg-muted/50"
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

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
}

export function AssetTable({ assets, isLoading, sort, onSortChange }: AssetTableProps) {
  if (isLoading) {
    return (
      <div className="space-y-2">
        {Array.from({ length: 5 }).map((_, i) => (
          <Skeleton key={i} className="h-12 w-full" />
        ))}
      </div>
    );
  }

  if (assets.length === 0) {
    return (
      <div className="flex h-40 items-center justify-center text-muted-foreground">
        등록된 장비가 없습니다.
      </div>
    );
  }

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <SortableHeader label="장비코드" field="assetCode" currentSort={sort} onSortChange={onSortChange} />
            <SortableHeader label="장비명" field="assetName" currentSort={sort} onSortChange={onSortChange} />
            <TableHead>카테고리</TableHead>
            <TableHead>상태</TableHead>
            <TableHead>위치</TableHead>
            <SortableHeader label="등록일" field="createdAt" currentSort={sort} onSortChange={onSortChange} />
          </TableRow>
        </TableHeader>
        <TableBody>
          {assets.map((asset) => (
            <TableRow key={asset.assetId} className="cursor-pointer hover:bg-muted/50">
              <TableCell>
                <Link href={`/assets/${asset.assetId}`} className="font-mono text-sm">
                  {asset.assetCode}
                </Link>
              </TableCell>
              <TableCell>
                <Link href={`/assets/${asset.assetId}`} className="font-medium hover:underline">
                  {asset.assetName}
                </Link>
              </TableCell>
              <TableCell className="text-muted-foreground">{asset.categoryName}</TableCell>
              <TableCell>
                <AssetStatusBadge status={asset.status} />
              </TableCell>
              <TableCell className="text-muted-foreground">{asset.location ?? '-'}</TableCell>
              <TableCell className="text-muted-foreground">{formatDate(asset.createdAt)}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
