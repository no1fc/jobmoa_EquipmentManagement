'use client';

import { NotificationList } from '@/components/notifications/NotificationList';

export default function NotificationsPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-[26px] font-bold tracking-[-0.625px]">알림</h1>
      <NotificationList />
    </div>
  );
}
