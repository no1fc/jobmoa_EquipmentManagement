import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  fetchNotifications,
  fetchUnreadCount,
  markAsRead,
  markAllAsRead,
} from '@/lib/api/notifications';
import type { PageParams } from '@/types/api';

interface NotificationParams extends PageParams {
  isRead?: boolean;
}

export function useNotifications(params?: NotificationParams) {
  return useQuery({
    queryKey: ['notifications', params],
    queryFn: () => fetchNotifications(params),
    select: (res) => res.data,
    placeholderData: keepPreviousData,
  });
}

export function useUnreadCount() {
  return useQuery({
    queryKey: ['notifications', 'unread-count'],
    queryFn: () => fetchUnreadCount(),
    select: (res) => res.data?.unreadCount ?? 0,
    refetchInterval: 30000,
  });
}

export function useMarkAsRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => markAsRead(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
    onError: () => {
      toast.error('알림 읽음 처리에 실패했습니다.');
    },
  });
}

export function useMarkAllAsRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => markAllAsRead(),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
      toast.success('모든 알림을 읽음 처리했습니다.');
    },
    onError: () => {
      toast.error('전체 읽음 처리에 실패했습니다.');
    },
  });
}
