'use client';

import { useEffect, type ReactNode } from 'react';
import { useAuthStore } from '@/store/authStore';
import { hasToken } from '@/lib/auth/token';
import { fetchMyProfile } from '@/lib/api/users';

export function AuthProvider({ children }: { children: ReactNode }) {
  const { setUser, logout } = useAuthStore();

  useEffect(() => {
    async function initAuth() {
      if (!hasToken()) return;
      try {
        const response = await fetchMyProfile();
        if (response.success && response.data) {
          setUser({
            userId: response.data.userId,
            email: response.data.email,
            name: response.data.name,
            role: response.data.role,
            branchName: response.data.branchName,
          });
        }
      } catch {
        logout();
      }
    }
    initAuth();
  }, [setUser, logout]);

  return <>{children}</>;
}
