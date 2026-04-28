'use client';

import { useDashboardStats, useOverdueRentals, useAssetSummary } from '@/hooks/useDashboard';
import { StatCards } from '@/components/dashboard/StatCards';
import { OverdueRentalsTable } from '@/components/dashboard/OverdueRentalsTable';
import { QuickActions } from '@/components/dashboard/QuickActions';

export default function DashboardPage() {
  const { data: dashboardData, isLoading: statsLoading } = useDashboardStats();
  const { data: overdueRentals, isLoading: overdueLoading, isError: overdueError } = useOverdueRentals();
  const { data: assetData, isLoading: assetLoading } = useAssetSummary();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">대시보드</h1>
        <p className="text-muted-foreground">장비 및 대여 현황을 한눈에 확인하세요</p>
      </div>

      <StatCards
        dashboardData={dashboardData}
        assetData={assetData}
        isLoading={statsLoading || assetLoading}
      />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <OverdueRentalsTable
            rentals={overdueRentals}
            isLoading={overdueLoading}
            isError={overdueError}
          />
        </div>
        <div>
          <QuickActions />
        </div>
      </div>
    </div>
  );
}
