import type { AssetStatus } from '@/types/asset';

const STATUS_CONFIG: Record<AssetStatus, { label: string; className: string }> = {
  IN_USE: { label: '사용중', className: 'bg-blue-100 text-blue-800' },
  RENTED: { label: '대여중', className: 'bg-purple-100 text-purple-800' },
  BROKEN: { label: '고장', className: 'bg-red-100 text-red-800' },
  IN_STORAGE: { label: '보관중', className: 'bg-gray-100 text-gray-800' },
  DISPOSED: { label: '폐기', className: 'bg-amber-100 text-amber-800' },
};

interface AssetStatusBadgeProps {
  status: AssetStatus;
}

export function AssetStatusBadge({ status }: AssetStatusBadgeProps) {
  const config = STATUS_CONFIG[status];
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${config.className}`}
    >
      {config.label}
    </span>
  );
}

export function getStatusLabel(status: AssetStatus): string {
  return STATUS_CONFIG[status].label;
}
