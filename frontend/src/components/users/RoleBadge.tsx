'use client';

import type { Role } from '@/types/user';

interface RoleBadgeProps {
  role: Role;
}

const ROLE_CONFIG: Record<Role, { label: string; className: string }> = {
  MANAGER: {
    label: '관리자',
    className: 'bg-purple-50 text-purple-700',
  },
  COUNSELOR: {
    label: '상담사',
    className: 'bg-blue-50 text-blue-700',
  },
};

export function RoleBadge({ role }: RoleBadgeProps) {
  const config = ROLE_CONFIG[role];
  return (
    <span
      className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-semibold ${config.className}`}
    >
      {config.label}
    </span>
  );
}
