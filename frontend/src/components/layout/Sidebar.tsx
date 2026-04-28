'use client';

import { NavItem } from './NavItem';
import { useAuthStore } from '@/store/authStore';
import { useUiStore } from '@/store/uiStore';
import { cn } from '@/lib/utils';

export function Sidebar() {
  const { user } = useAuthStore();
  const { sidebarOpen } = useUiStore();
  const isManager = user?.role === 'MANAGER';

  return (
    <aside
      className={cn(
        'fixed left-0 top-0 z-40 h-screen w-64 border-r bg-background transition-transform',
        sidebarOpen ? 'translate-x-0' : '-translate-x-full',
        'lg:translate-x-0',
      )}
    >
      <div className="flex h-14 items-center border-b px-4">
        <span className="text-lg font-semibold">장비 관리</span>
      </div>
      <nav className="flex flex-col gap-1 p-4">
        <NavItem
          href="/dashboard"
          icon={<LayoutDashboardIcon />}
          label="대시보드"
        />
        <NavItem
          href="/assets"
          icon={<PackageIcon />}
          label="장비 관리"
        />
        <NavItem
          href="/rentals"
          icon={<ArrowLeftRightIcon />}
          label="대여 관리"
        />
        <NavItem
          href="/notifications"
          icon={<BellIcon />}
          label="알림"
        />
        {isManager && (
          <NavItem
            href="/users"
            icon={<UsersIcon />}
            label="사용자 관리"
          />
        )}
      </nav>
    </aside>
  );
}

function LayoutDashboardIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect width="7" height="9" x="3" y="3" rx="1" /><rect width="7" height="5" x="14" y="3" rx="1" /><rect width="7" height="9" x="14" y="12" rx="1" /><rect width="7" height="5" x="3" y="16" rx="1" />
    </svg>
  );
}

function PackageIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M16.5 9.4 7.55 4.24" /><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" /><polyline points="3.29 7 12 12 20.71 7" /><line x1="12" x2="12" y1="22" y2="12" />
    </svg>
  );
}

function ArrowLeftRightIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M8 3 4 7l4 4" /><path d="M4 7h16" /><path d="m16 21 4-4-4-4" /><path d="M20 17H4" />
    </svg>
  );
}

function BellIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" /><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0" />
    </svg>
  );
}

function UsersIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.87" /><path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  );
}
