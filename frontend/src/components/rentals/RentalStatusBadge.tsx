import type { RentalStatus } from '@/types/rental';

const STATUS_CONFIG: Record<RentalStatus, { label: string; className: string }> = {
  RENTED: { label: '대여중', className: 'bg-[#f2f9ff] text-[#0075de]' },
  OVERDUE: { label: '연체', className: 'bg-[#fef2f2] text-[#dc2626]' },
  RETURNED: { label: '반납완료', className: 'bg-[#f0fdf4] text-[#16a34a]' },
  CANCELLED: { label: '취소', className: 'bg-[#f6f5f4] text-[#615d59]' },
};

interface RentalStatusBadgeProps {
  status: RentalStatus;
}

export function RentalStatusBadge({ status }: RentalStatusBadgeProps) {
  const config = STATUS_CONFIG[status];
  return (
    <span
      className={`inline-flex items-center rounded-[9999px] px-2.5 py-0.5 text-xs font-semibold tracking-[0.125px] ${config.className}`}
    >
      {config.label}
    </span>
  );
}

export function getRentalStatusLabel(status: RentalStatus): string {
  return STATUS_CONFIG[status].label;
}
