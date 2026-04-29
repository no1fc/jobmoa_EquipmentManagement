'use client';

import { useUiStore } from '@/store/uiStore';
import { UserMenu } from './UserMenu';
import { NotificationBell } from './NotificationBell';
import { Button } from '@/components/ui/button';

export function Header() {
  const { toggleSidebar } = useUiStore();

  return (
    <header className="sticky top-0 z-30 flex h-14 items-center justify-between border-b bg-background px-4">
      <Button
        variant="ghost"
        size="sm"
        className="lg:hidden"
        onClick={toggleSidebar}
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <line x1="4" x2="20" y1="12" y2="12" /><line x1="4" x2="20" y1="6" y2="6" /><line x1="4" x2="20" y1="18" y2="18" />
        </svg>
      </Button>
      <div className="flex-1" />
      <div className="flex items-center gap-2">
        <NotificationBell />
        <UserMenu />
      </div>
    </header>
  );
}
