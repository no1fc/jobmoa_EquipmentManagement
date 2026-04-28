import apiClient from './client';
import type { ApiResponse, PageResponse, PageParams } from '@/types/api';
import type {
  User,
  UserCreateRequest,
  UserUpdateRequest,
  ProfileUpdateRequest,
  PasswordChangeRequest,
} from '@/types/user';

export async function fetchUsers(params?: PageParams & { role?: string; search?: string }): Promise<ApiResponse<PageResponse<User>>> {
  const { data } = await apiClient.get<ApiResponse<PageResponse<User>>>('/api/v1/users', { params });
  return data;
}

export async function fetchUser(id: number): Promise<ApiResponse<User>> {
  const { data } = await apiClient.get<ApiResponse<User>>(`/api/v1/users/${id}`);
  return data;
}

export async function createUser(request: UserCreateRequest): Promise<ApiResponse<User>> {
  const { data } = await apiClient.post<ApiResponse<User>>('/api/v1/users', request);
  return data;
}

export async function updateUser(id: number, request: UserUpdateRequest): Promise<ApiResponse<User>> {
  const { data } = await apiClient.put<ApiResponse<User>>(`/api/v1/users/${id}`, request);
  return data;
}

export async function deleteUser(id: number): Promise<ApiResponse<null>> {
  const { data } = await apiClient.delete<ApiResponse<null>>(`/api/v1/users/${id}`);
  return data;
}

export async function fetchMyProfile(): Promise<ApiResponse<User>> {
  const { data } = await apiClient.get<ApiResponse<User>>('/api/v1/users/me');
  return data;
}

export async function updateMyProfile(request: ProfileUpdateRequest): Promise<ApiResponse<User>> {
  const { data } = await apiClient.put<ApiResponse<User>>('/api/v1/users/me', request);
  return data;
}

export async function changePassword(request: PasswordChangeRequest): Promise<ApiResponse<null>> {
  const { data } = await apiClient.put<ApiResponse<null>>('/api/v1/users/me/password', request);
  return data;
}
