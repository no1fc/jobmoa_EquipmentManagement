import apiClient from './client';
import type { ApiResponse, PageResponse, PageParams } from '@/types/api';
import type { Notification, UnreadCount } from '@/types/notification';

export async function fetchNotifications(params?: PageParams & { isRead?: boolean }): Promise<ApiResponse<PageResponse<Notification>>> {
  const { data } = await apiClient.get<ApiResponse<PageResponse<Notification>>>('/api/v1/notifications', { params });
  return data;
}

export async function fetchUnreadCount(): Promise<ApiResponse<UnreadCount>> {
  const { data } = await apiClient.get<ApiResponse<UnreadCount>>('/api/v1/notifications/unread-count');
  return data;
}

export async function markAsRead(id: number): Promise<ApiResponse<null>> {
  const { data } = await apiClient.put<ApiResponse<null>>(`/api/v1/notifications/${id}/read`);
  return data;
}

export async function markAllAsRead(): Promise<ApiResponse<null>> {
  const { data } = await apiClient.put<ApiResponse<null>>('/api/v1/notifications/read-all');
  return data;
}
