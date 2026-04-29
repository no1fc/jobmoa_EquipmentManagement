import type { ReactNode } from 'react';
import Link from 'next/link';
import type { Rental } from '@/types/rental';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { RentalStatusBadge } from './RentalStatusBadge';

interface RentalDetailInfoProps {
  rental: Rental;
}

function InfoRow({ label, value }: { label: string; value: ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
      <span className="min-w-[120px] text-sm font-medium text-[#615d59]">{label}</span>
      <span className="text-sm">{value ?? '-'}</span>
    </div>
  );
}

function formatDate(dateStr: string | null | undefined): string {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
}

function getOverdueDays(dueDate: string): number {
  const due = new Date(dueDate);
  const now = new Date();
  const diffMs = now.getTime() - due.getTime();
  return Math.max(0, Math.floor(diffMs / (1000 * 60 * 60 * 24)));
}

export function RentalDetailInfo({ rental }: RentalDetailInfoProps) {
  const isOverdue = rental.status === 'OVERDUE';
  const overdueDays = isOverdue ? getOverdueDays(rental.dueDate) : 0;

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
      {/* 대여 정보 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">대여 정보</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
            <span className="min-w-[120px] text-sm font-medium text-[#615d59]">상태</span>
            <RentalStatusBadge status={rental.status} />
          </div>
          <InfoRow label="대여자" value={rental.borrowerName} />
          <InfoRow label="대여일" value={formatDate(rental.rentalDate)} />
          <InfoRow label="반납기한" value={formatDate(rental.dueDate)} />
          <InfoRow label="반납일" value={formatDate(rental.returnDate)} />
          <InfoRow
            label="연장횟수"
            value={`${rental.extensionCount}회 / 최대 1회`}
          />
          <InfoRow
            label="연체일수"
            value={
              isOverdue ? (
                <span className="font-semibold text-[#dc2626]">{overdueDays}일</span>
              ) : (
                '-'
              )
            }
          />
          <InfoRow label="대여사유" value={rental.rentalReason} />
          <InfoRow label="반납상태" value={rental.returnCondition} />
        </CardContent>
      </Card>

      {/* 장비 정보 */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">장비 정보</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <InfoRow label="장비코드" value={rental.assetCode} />
          <div className="flex flex-col gap-0.5 sm:flex-row sm:gap-4">
            <span className="min-w-[120px] text-sm font-medium text-[#615d59]">장비명</span>
            <Link
              href={`/assets/${rental.assetId}`}
              className="text-sm text-[#0075de] hover:underline"
            >
              {rental.assetName}
            </Link>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
