'use client';

import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/authStore';
import { logout as logoutApi } from '@/lib/api/auth';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

export function UserMenu() {
  const router = useRouter();
  const { user, logout } = useAuthStore();

  async function handleLogout() {
    try {
      await logoutApi();
    } finally {
      logout();
      router.push('/login');
    }
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger className="inline-flex items-center gap-2 rounded-md px-3 py-1.5 text-sm font-medium hover:bg-muted">
        <span className="hidden sm:inline-block">{user?.name ?? '사용자'}</span>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-48">
        <DropdownMenuLabel>
          <div className="text-sm font-medium">{user?.name}</div>
          <div className="text-xs text-muted-foreground">{user?.email}</div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={() => router.push('/profile')}>
          내 프로필
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={handleLogout}>
          로그아웃
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
