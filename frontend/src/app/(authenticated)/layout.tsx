import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import type { ReactNode } from 'react';

export default function AuthenticatedLayout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen">
      <Sidebar />
      <div className="lg:pl-64">
        <Header />
        <main className="p-6">{children}</main>
      </div>
    </div>
  );
}
