import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  fetchRentals,
  fetchRental,
  createRental,
  returnRental,
  extendRental,
  cancelRental,
} from '@/lib/api/rentals';
import type { RentalSearchParams, RentalCreateRequest, RentalReturnRequest, RentalExtendRequest } from '@/types/rental';

export function useRentals(params?: RentalSearchParams) {
  return useQuery({
    queryKey: ['rentals', params],
    queryFn: () => fetchRentals(params),
    select: (res) => res.data,
    placeholderData: keepPreviousData,
  });
}

export function useRental(id: number) {
  return useQuery({
    queryKey: ['rentals', id],
    queryFn: () => fetchRental(id),
    select: (res) => res.data,
    enabled: !!id,
  });
}

export function useCreateRental() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (request: RentalCreateRequest) => createRental(request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rentals'] });
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      toast.success('대여가 등록되었습니다.');
    },
    onError: () => {
      toast.error('대여 등록에 실패했습니다.');
    },
  });
}

export function useReturnRental() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, request }: { id: number; request: RentalReturnRequest }) =>
      returnRental(id, request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rentals'] });
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      toast.success('반납이 완료되었습니다.');
    },
    onError: () => {
      toast.error('반납 처리에 실패했습니다.');
    },
  });
}

export function useExtendRental() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, request }: { id: number; request: RentalExtendRequest }) =>
      extendRental(id, request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rentals'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      toast.success('대여 기간이 연장되었습니다.');
    },
    onError: () => {
      toast.error('연장에 실패했습니다.');
    },
  });
}

export function useCancelRental() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => cancelRental(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rentals'] });
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      toast.success('대여가 취소되었습니다.');
    },
    onError: () => {
      toast.error('대여 취소에 실패했습니다.');
    },
  });
}
