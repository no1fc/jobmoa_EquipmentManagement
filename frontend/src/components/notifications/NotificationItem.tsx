'use client';

import { useRouter } from 'next/navigation';
import { useMarkAsRead } from '@/hooks/useNotifications';
import type { Notification, NotificationType } from '@/types/notification';

interface NotificationItemProps {
  notification: Notification;
}

function getTypeIcon(type: NotificationType) {
  switch (type) {
    case 'RENTAL_DUE':
      return (
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
        </svg>
      );
    case 'RENTAL_OVERDUE':
      return (
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3" /><path d="M12 9v4" /><path d="M12 17h.01" />
        </svg>
      );
    case 'SYSTEM':
      return (
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <circle cx="12" cy="12" r="10" /><path d="M12 16v-4" /><path d="M12 8h.01" />
        </svg>
      );
  }
}

function getTypeColor(type: NotificationType): string {
  switch (type) {
    case 'RENTAL_DUE':
      return 'text-amber-600';
    case 'RENTAL_OVERDUE':
      return 'text-red-600';
    case 'SYSTEM':
      return 'text-blue-600';
  }
}

function formatRelativeTime(dateStr: string): string {
  const date = new Date(dateStr);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffSec = Math.floor(diffMs / 1000);
  const diffMin = Math.floor(diffSec / 60);
  const diffHour = Math.floor(diffMin / 60);
  const diffDay = Math.floor(diffHour / 24);

  if (diffSec < 60) return '방금 전';
  if (diffMin < 60) return `${diffMin}분 전`;
  if (diffHour < 24) return `${diffHour}시간 전`;
  if (diffDay < 7) return `${diffDay}일 전`;
  return date.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric' });
}

export function NotificationItem({ notification }: NotificationItemProps) {
  const router = useRouter();
  const markAsRead = useMarkAsRead();

  const handleClick = () => {
    if (!notification.isRead) {
      markAsRead.mutate(notification.notificationId);
    }

    if (notification.referenceId) {
      if (notification.type === 'RENTAL_DUE' || notification.type === 'RENTAL_OVERDUE') {
        router.push(`/rentals/${notification.referenceId}`);
      }
    }
  };

  return (
    <button
      type="button"
      onClick={handleClick}
      className={`flex w-full items-start gap-3 px-4 py-3 text-left transition-colors hover:bg-accent ${
        notification.isRead ? 'opacity-70' : ''
      }`}
      style={{ borderBottom: '1px solid rgba(0,0,0,0.1)' }}
    >
      {!notification.isRead && (
        <span
          className="mt-1.5 h-2 w-2 flex-shrink-0 rounded-full"
          style={{ backgroundColor: '#0075de' }}
        />
      )}
      {notification.isRead && <span className="mt-1.5 h-2 w-2 flex-shrink-0" />}

      <span className={`mt-0.5 flex-shrink-0 ${getTypeColor(notification.type)}`}>
        {getTypeIcon(notification.type)}
      </span>

      <div className="flex-1 min-w-0">
        <p className={`text-sm ${notification.isRead ? 'font-normal' : 'font-semibold'}`}>
          {notification.title}
        </p>
        {notification.message && (
          <p className="mt-0.5 text-sm text-muted-foreground line-clamp-2">
            {notification.message}
          </p>
        )}
        <p className="mt-1 text-xs text-muted-foreground">
          {formatRelativeTime(notification.sentAt)}
        </p>
      </div>
    </button>
  );
}
