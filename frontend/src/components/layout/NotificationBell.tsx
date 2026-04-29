'use client';

import Link from 'next/link';
import { useUnreadCount } from '@/hooks/useNotifications';

export function NotificationBell() {
  const { data: unreadCount } = useUnreadCount();

  return (
    <Link
      href="/notifications"
      className="relative inline-flex items-center justify-center rounded-md p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
      aria-label={`알림${unreadCount ? ` (${unreadCount}건 미읽음)` : ''}`}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="20"
        height="20"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" />
        <path d="M10.3 21a1.94 1.94 0 0 0 3.4 0" />
      </svg>
      {unreadCount !== undefined && unreadCount > 0 && (
        <span
          className="absolute -right-0.5 -top-0.5 flex h-5 min-w-5 items-center justify-center rounded-full px-1 text-xs font-semibold text-white"
          style={{ backgroundColor: '#0075de' }}
        >
          {unreadCount > 99 ? '99+' : unreadCount}
        </span>
      )}
    </Link>
  );
}
