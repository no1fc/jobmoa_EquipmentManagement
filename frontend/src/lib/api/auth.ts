import apiClient from './client';
import type { ApiResponse } from '@/types/api';
import type { LoginRequest, LoginResponse, TokenRefreshRequest, TokenResponse } from '@/types/user';

export async function login(request: LoginRequest): Promise<ApiResponse<LoginResponse>> {
  const { data } = await apiClient.post<ApiResponse<LoginResponse>>('/api/v1/auth/login', request);
  return data;
}

export async function refreshToken(request: TokenRefreshRequest): Promise<ApiResponse<TokenResponse>> {
  const { data } = await apiClient.post<ApiResponse<TokenResponse>>('/api/v1/auth/refresh', request);
  return data;
}

export async function logout(): Promise<ApiResponse<null>> {
  const { data } = await apiClient.post<ApiResponse<null>>('/api/v1/auth/logout');
  return data;
}
