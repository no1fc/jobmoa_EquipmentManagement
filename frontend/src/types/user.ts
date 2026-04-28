export type Role = 'COUNSELOR' | 'MANAGER';

export interface User {
  userId: number;
  email: string;
  name: string;
  role: Role;
  branchName: string | null;
  phone: string | null;
  isActive: boolean;
  createdAt: string;
}

export interface UserSummary {
  userId: number;
  email: string;
  name: string;
  role: Role;
  branchName: string | null;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: UserSummary;
}

export interface TokenRefreshRequest {
  refreshToken: string;
}

export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
}

export interface UserCreateRequest {
  email: string;
  password: string;
  name: string;
  role: Role;
  branchName?: string;
  phone?: string;
}

export interface UserUpdateRequest {
  name: string;
  role?: Role;
  branchName?: string;
  phone?: string;
}

export interface ProfileUpdateRequest {
  name: string;
  phone?: string;
}

export interface PasswordChangeRequest {
  currentPassword: string;
  newPassword: string;
}
