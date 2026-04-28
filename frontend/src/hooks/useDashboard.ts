import { useQuery } from '@tanstack/react-query';
import { fetchRentalDashboard, fetchOverdueRentals } from '@/lib/api/rentals';
import { fetchAssetSummary } from '@/lib/api/assets';

export function useDashboardStats() {
  return useQuery({
    queryKey: ['dashboard', 'stats'],
    queryFn: fetchRentalDashboard,
    select: (res) => res.data,
    refetchInterval: 300_000,
  });
}

export function useOverdueRentals() {
  return useQuery({
    queryKey: ['dashboard', 'overdue'],
    queryFn: fetchOverdueRentals,
    select: (res) => res.data,
    refetchInterval: 300_000,
  });
}

export function useAssetSummary() {
  return useQuery({
    queryKey: ['dashboard', 'assetSummary'],
    queryFn: fetchAssetSummary,
    select: (res) => res.data,
  });
}
