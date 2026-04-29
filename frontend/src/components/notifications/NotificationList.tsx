'use client';

import { useState, useCallback } from 'react';
import { useNotifications, useUnreadCount, useMarkAllAsRead } from '@/hooks/useNotifications';
import { NotificationItem } from './NotificationItem';
import { Button } from '@/components/ui/button';
import type { PageParams } from '@/types/api';

type FilterType = 'all' | 'unread';

interface NotificationListParams extends PageParams {
  isRead?: boolean;
}

const DEFAULT_PARAMS: NotificationListParams = {
  page: 0,
  size: 20,
};

export function NotificationList() {
  const [filter, setFilter] = useState<FilterType>('all');
  const [params, setParams] = useState<NotificationListParams>(DEFAULT_PARAMS);

  const queryParams = {
    ...params,
    ...(filter === 'unread' ? { isRead: false } : {}),
  };

  const { data: pageData, isLoading } = useNotifications(queryParams);
  const { data: unreadCount } = useUnreadCount();
  const markAllAsRead = useMarkAllAsRead();

  const handleFilterChange = useCallback((newFilter: FilterType) => {
    setFilter(newFilter);
    setParams((prev) => ({ ...prev, page: 0 }));
  }, []);

  const handlePageChange = useCallback((page: number) => {
    setParams((prev) => ({ ...prev, page }));
  }, []);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex gap-2">
          <Button
            variant={filter === 'all' ? 'default' : 'outline'}
            size="sm"
            onClick={() => handleFilterChange('all')}
          >
            전체
          </Button>
          <Button
            variant={filter === 'unread' ? 'default' : 'outline'}
            size="sm"
            onClick={() => handleFilterChange('unread')}
          >
            읽지 않음
            {unreadCount !== undefined && unreadCount > 0 && (
              <span className="ml-1.5 rounded-full px-1.5 py-0.5 text-xs font-semibold text-white" style={{ backgroundColor: '#0075de' }}>
                {unreadCount}
              </span>
            )}
          </Button>
        </div>
        {unreadCount !== undefined && unreadCount > 0 && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => markAllAsRead.mutate()}
            disabled={markAllAsRead.isPending}
          >
            <CheckAllIcon />
            <span className="ml-1.5">모두 읽음</span>
          </Button>
        )}
      </div>

      <div
        className="overflow-hidden rounded-xl bg-background"
        style={{ border: '1px solid rgba(0,0,0,0.1)' }}
      >
        {isLoading ? (
          <NotificationSkeleton />
        ) : !pageData || pageData.content.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 text-center">
            <BellOffIcon />
            <p className="mt-3 text-sm font-medium text-[#615d59]">
              {filter === 'unread' ? '읽지 않은 알림이 없습니다' : '알림이 없습니다'}
            </p>
          </div>
        ) : (
          <>
            {pageData.content.map((notification) => (
              <NotificationItem
                key={notification.notificationId}
                notification={notification}
              />
            ))}
          </>
        )}
      </div>

      {pageData && pageData.totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-sm text-[#615d59]">
            {pageData.page + 1} / {pageData.totalPages} 페이지 (총 {pageData.totalElements}건)
          </p>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              disabled={pageData.page === 0}
              onClick={() => handlePageChange(pageData.page - 1)}
            >
              이전
            </Button>
            <Button
              variant="outline"
              size="sm"
              disabled={pageData.last}
              onClick={() => handlePageChange(pageData.page + 1)}
            >
              다음
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}

function NotificationSkeleton() {
  return (
    <div className="divide-y">
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="flex items-start gap-3 px-4 py-3">
          <div className="mt-1.5 h-2 w-2 flex-shrink-0 animate-pulse rounded-full bg-muted" />
          <div className="mt-0.5 h-[18px] w-[18px] flex-shrink-0 animate-pulse rounded bg-muted" />
          <div className="flex-1 space-y-2">
            <div className="h-4 w-3/4 animate-pulse rounded bg-muted" />
            <div className="h-3.5 w-1/2 animate-pulse rounded bg-muted" />
            <div className="h-3 w-20 animate-pulse rounded bg-muted" />
          </div>
        </div>
      ))}
    </div>
  );
}

function CheckAllIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 6 7 17l-5-5" /><path d="m22 10-9.5 9.5L10 17" />
    </svg>
  );
}

function BellOffIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" className="text-[#a39e98]">
      <path d="M8.7 3A6 6 0 0 1 18 8a21.3 21.3 0 0 0 .6 5" /><path d="M17 17H3s3-2 3-9a4.67 4.67 0 0 1 .3-1.7" /><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0" /><line x1="2" x2="22" y1="2" y2="22" />
    </svg>
  );
}
