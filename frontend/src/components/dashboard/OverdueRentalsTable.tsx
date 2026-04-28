'use client';

import Link from 'next/link';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import type { Rental } from '@/types/rental';

interface OverdueRentalsTableProps {
  rentals: Rental[] | null | undefined;
  isLoading: boolean;
  isError: boolean;
}

const MAX_DISPLAY_ROWS = 10;

function calculateDaysOverdue(dueDate: string): number {
  const due = new Date(dueDate);
  const now = new Date();
  const diffMs = now.getTime() - due.getTime();
  return Math.ceil(diffMs / (1000 * 60 * 60 * 24));
}

function formatDate(dateStr: string): string {
  return dateStr.slice(0, 10);
}

export function OverdueRentalsTable({ rentals, isLoading, isError }: OverdueRentalsTableProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>연체 대여 목록</CardTitle>
      </CardHeader>
      <CardContent>
        {isLoading && <LoadingSkeleton />}
        {isError && (
          <p className="text-sm text-destructive text-center py-8">
            연체 목록을 불러올 수 없습니다.
          </p>
        )}
        {!isLoading && !isError && (!rentals || rentals.length === 0) && (
          <div className="flex flex-col items-center justify-center py-8 text-muted-foreground">
            <CheckIcon />
            <p className="mt-2 text-sm">연체된 대여가 없습니다</p>
          </div>
        )}
        {!isLoading && !isError && rentals && rentals.length > 0 && (
          <>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>장비명</TableHead>
                  <TableHead>장비코드</TableHead>
                  <TableHead>대여자</TableHead>
                  <TableHead>반납기한</TableHead>
                  <TableHead className="text-right">연체일수</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rentals.slice(0, MAX_DISPLAY_ROWS).map((rental) => {
                  const daysOverdue = calculateDaysOverdue(rental.dueDate);
                  return (
                    <TableRow key={rental.rentalId}>
                      <TableCell className="font-medium">{rental.assetName}</TableCell>
                      <TableCell>
                        <Badge variant="outline">{rental.assetCode}</Badge>
                      </TableCell>
                      <TableCell>{rental.borrowerName}</TableCell>
                      <TableCell>{formatDate(rental.dueDate)}</TableCell>
                      <TableCell className="text-right">
                        <Badge variant="destructive">{daysOverdue}일</Badge>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
            {rentals.length > MAX_DISPLAY_ROWS && (
              <div className="mt-4 text-center">
                <Link
                  href="/rentals?status=OVERDUE"
                  className="text-sm text-primary hover:underline"
                >
                  전체 {rentals.length}건 보기
                </Link>
              </div>
            )}
          </>
        )}
      </CardContent>
    </Card>
  );
}

function LoadingSkeleton() {
  return (
    <div className="space-y-3">
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="flex items-center gap-4">
          <Skeleton className="h-4 w-24" />
          <Skeleton className="h-4 w-20" />
          <Skeleton className="h-4 w-16" />
          <Skeleton className="h-4 w-20" />
          <Skeleton className="h-4 w-12 ml-auto" />
        </div>
      ))}
    </div>
  );
}

function CheckIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" className="text-green-500">
      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" /><path d="m9 11 3 3L22 4" />
    </svg>
  );
}
