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

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
}

function calcOverdueDays(dueDate: string): number {
  const due = new Date(dueDate);
  const now = new Date();
  const diffMs = now.getTime() - due.getTime();
  return Math.max(0, Math.floor(diffMs / (1000 * 60 * 60 * 24)));
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
        대여 내역이 없습니다.
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
            const isOverdue = rental.status === 'OVERDUE';
            const overdueDays = isOverdue ? calcOverdueDays(rental.dueDate) : 0;
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
                <TableCell className="text-[#615d59]">{rental.borrowerName}</TableCell>
                <TableCell className="text-[#615d59]">{formatDate(rental.rentalDate)}</TableCell>
                <TableCell className="text-[#615d59]">{formatDate(rental.dueDate)}</TableCell>
                <TableCell>
                  <RentalStatusBadge status={rental.status} />
                </TableCell>
                <TableCell className="text-[#615d59]">
                  {isOverdue ? <span className="font-semibold text-[#dc2626]">{overdueDays}일</span> : '-'}
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </div>
  );
}
