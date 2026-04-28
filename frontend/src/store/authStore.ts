import { create } from 'zustand';
import type { UserSummary } from '@/types/user';
import { clearTokens } from '@/lib/auth/token';

interface AuthState {
  user: UserSummary | null;
  isAuthenticated: boolean;
  setUser: (user: UserSummary) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  setUser: (user) => set({ user, isAuthenticated: true }),
  logout: () => {
    clearTokens();
    set({ user: null, isAuthenticated: false });
  },
}));
