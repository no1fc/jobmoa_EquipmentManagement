export type NotificationType = 'RENTAL_DUE' | 'RENTAL_OVERDUE' | 'SYSTEM';
export type NotificationChannel = 'IN_APP' | 'EMAIL' | 'PUSH';

export interface Notification {
  notificationId: number;
  type: NotificationType;
  title: string;
  message: string | null;
  isRead: boolean;
  channel: NotificationChannel;
  referenceId: number | null;
  sentAt: string;
  readAt: string | null;
}

export interface UnreadCount {
  unreadCount: number;
}
