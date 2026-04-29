import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  fetchUsers,
  fetchUser,
  createUser,
  updateUser,
  deleteUser,
  fetchMyProfile,
  updateMyProfile,
  changePassword,
} from '@/lib/api/users';
import type { PageParams } from '@/types/api';
import type {
  UserCreateRequest,
  UserUpdateRequest,
  ProfileUpdateRequest,
  PasswordChangeRequest,
} from '@/types/user';

interface UserSearchParams extends PageParams {
  role?: string;
  search?: string;
}

export function useUsers(params?: UserSearchParams) {
  return useQuery({
    queryKey: ['users', params],
    queryFn: () => fetchUsers(params),
    select: (res) => res.data,
    placeholderData: keepPreviousData,
  });
}

export function useUser(id: number) {
  return useQuery({
    queryKey: ['users', id],
    queryFn: () => fetchUser(id),
    select: (res) => res.data,
    enabled: !!id,
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (request: UserCreateRequest) => createUser(request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      toast.success('사용자가 등록되었습니다.');
    },
    onError: () => {
      toast.error('사용자 등록에 실패했습니다.');
    },
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, request }: { id: number; request: UserUpdateRequest }) =>
      updateUser(id, request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      toast.success('사용자 정보가 수정되었습니다.');
    },
    onError: () => {
      toast.error('사용자 수정에 실패했습니다.');
    },
  });
}

export function useDeleteUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => deleteUser(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      toast.success('사용자가 비활성화되었습니다.');
    },
    onError: () => {
      toast.error('사용자 비활성화에 실패했습니다.');
    },
  });
}

export function useMyProfile() {
  return useQuery({
    queryKey: ['users', 'me'],
    queryFn: () => fetchMyProfile(),
    select: (res) => res.data,
  });
}

export function useUpdateProfile() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (request: ProfileUpdateRequest) => updateMyProfile(request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users', 'me'] });
      toast.success('프로필이 수정되었습니다.');
    },
    onError: () => {
      toast.error('프로필 수정에 실패했습니다.');
    },
  });
}

export function useChangePassword() {
  return useMutation({
    mutationFn: (request: PasswordChangeRequest) => changePassword(request),
    onSuccess: () => {
      toast.success('비밀번호가 변경되었습니다.');
    },
    onError: () => {
      toast.error('비밀번호 변경에 실패했습니다. 현재 비밀번호를 확인해주세요.');
    },
  });
}
