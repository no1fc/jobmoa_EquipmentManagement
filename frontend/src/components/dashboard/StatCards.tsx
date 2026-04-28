'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import type { RentalDashboard } from '@/types/rental';
import type { AssetSummary } from '@/types/asset';

interface StatCardsProps {
  dashboardData: RentalDashboard | null | undefined;
  assetData: AssetSummary | null | undefined;
  isLoading: boolean;
}

interface StatCardItem {
  title: string;
  value: number;
  description: string;
  icon: React.ReactNode;
  colorClass: string;
}

export function StatCards({ dashboardData, assetData, isLoading }: StatCardsProps) {
  if (isLoading) {
    return (
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Card key={i}>
            <CardHeader className="pb-2">
              <Skeleton className="h-4 w-24" />
            </CardHeader>
            <CardContent>
              <Skeleton className="h-8 w-16 mb-1" />
              <Skeleton className="h-3 w-32" />
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  const cards: StatCardItem[] = [
    {
      title: '대여 중',
      value: dashboardData?.totalActive ?? 0,
      description: `전체 장비 ${assetData?.total?.toLocaleString('ko-KR') ?? '-'}개`,
      icon: <ArrowLeftRightIcon />,
      colorClass: 'text-blue-600',
    },
    {
      title: '연체',
      value: dashboardData?.overdueCount ?? 0,
      description: '반납기한 초과',
      icon: <AlertTriangleIcon />,
      colorClass: dashboardData?.overdueCount ? 'text-red-600' : 'text-muted-foreground',
    },
    {
      title: '반납 임박',
      value: dashboardData?.dueSoon ?? 0,
      description: '3일 이내 반납 예정',
      icon: <ClockIcon />,
      colorClass: dashboardData?.dueSoon ? 'text-amber-600' : 'text-muted-foreground',
    },
    {
      title: '오늘 반납',
      value: dashboardData?.returnedToday ?? 0,
      description: '오늘 반납 완료',
      icon: <CheckCircleIcon />,
      colorClass: 'text-green-600',
    },
  ];

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {cards.map((card) => (
        <Card key={card.title}>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {card.title}
            </CardTitle>
            <span className={card.colorClass}>{card.icon}</span>
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${card.colorClass}`}>
              {card.value.toLocaleString('ko-KR')}
            </div>
            <p className="text-xs text-muted-foreground mt-1">{card.description}</p>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}

function ArrowLeftRightIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M8 3 4 7l4 4" /><path d="M4 7h16" /><path d="m16 21 4-4-4-4" /><path d="M20 17H4" />
    </svg>
  );
}

function AlertTriangleIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3" /><path d="M12 9v4" /><path d="M12 17h.01" />
    </svg>
  );
}

function ClockIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
    </svg>
  );
}

function CheckCircleIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" /><path d="m9 11 3 3L22 4" />
    </svg>
  );
}
