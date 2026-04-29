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
          대여 내역을 찾을 수 없습니다.
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
      <ExtendDialog
        open={extendDialogOpen}
        onOpenChange={setExtendDialogOpen}
        rentalId={rentalId}
        assetName={rental.assetName}
        currentDueDate={rental.dueDate}
      />
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
      <rect width="18" height="18" x="3" y="4" rx="2" ry="2" /><line x1="16" x2="16" y1="2" y2="6" /><line x1="8" x2="8" y1="2" y2="6" /><line x1="3" x2="21" y1="10" y2="10" />
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
