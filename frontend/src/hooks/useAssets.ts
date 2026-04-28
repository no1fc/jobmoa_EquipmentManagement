import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  fetchAssets,
  fetchAsset,
  createAsset,
  updateAsset,
  deleteAsset,
  updateAssetStatus,
} from '@/lib/api/assets';
import type { AssetSearchParams, AssetCreateRequest, AssetUpdateRequest, AssetStatusRequest } from '@/types/asset';

export function useAssets(params?: AssetSearchParams) {
  return useQuery({
    queryKey: ['assets', params],
    queryFn: () => fetchAssets(params),
    select: (res) => res.data,
    placeholderData: keepPreviousData,
  });
}

export function useAsset(id: number) {
  return useQuery({
    queryKey: ['assets', id],
    queryFn: () => fetchAsset(id),
    select: (res) => res.data,
    enabled: !!id,
  });
}

export function useCreateAsset() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ request, image }: { request: AssetCreateRequest; image?: File }) =>
      createAsset(request, image),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      toast.success('장비가 등록되었습니다.');
    },
    onError: () => {
      toast.error('장비 등록에 실패했습니다.');
    },
  });
}

export function useUpdateAsset(id: number) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ request, image }: { request: AssetUpdateRequest; image?: File }) =>
      updateAsset(id, request, image),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      queryClient.invalidateQueries({ queryKey: ['assets', id] });
      toast.success('장비 정보가 수정되었습니다.');
    },
    onError: () => {
      toast.error('장비 수정에 실패했습니다.');
    },
  });
}

export function useDeleteAsset() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => deleteAsset(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      toast.success('장비가 삭제되었습니다.');
    },
    onError: () => {
      toast.error('장비 삭제에 실패했습니다.');
    },
  });
}

export function useUpdateAssetStatus(id: number) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (request: AssetStatusRequest) => updateAssetStatus(id, request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['assets', id] });
      queryClient.invalidateQueries({ queryKey: ['assets'] });
      toast.success('장비 상태가 변경되었습니다.');
    },
    onError: () => {
      toast.error('상태 변경에 실패했습니다.');
    },
  });
}
