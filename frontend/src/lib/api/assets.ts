import apiClient from './client';
import type { ApiResponse, PageResponse } from '@/types/api';
import type {
  Asset,
  AssetDetail,
  AssetCreateRequest,
  AssetUpdateRequest,
  AssetStatusRequest,
  AssetSummary,
  AssetSearchParams,
} from '@/types/asset';

export async function fetchAssets(params?: AssetSearchParams): Promise<ApiResponse<PageResponse<Asset>>> {
  const { data } = await apiClient.get<ApiResponse<PageResponse<Asset>>>('/api/v1/assets', { params });
  return data;
}

export async function fetchAsset(id: number): Promise<ApiResponse<AssetDetail>> {
  const { data } = await apiClient.get<ApiResponse<AssetDetail>>(`/api/v1/assets/${id}`);
  return data;
}

export async function createAsset(request: AssetCreateRequest, image?: File): Promise<ApiResponse<AssetDetail>> {
  const formData = new FormData();
  formData.append('data', new Blob([JSON.stringify(request)], { type: 'application/json' }));
  if (image) {
    formData.append('image', image);
  }
  const { data } = await apiClient.post<ApiResponse<AssetDetail>>('/api/v1/assets', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
  return data;
}

export async function updateAsset(id: number, request: AssetUpdateRequest, image?: File): Promise<ApiResponse<AssetDetail>> {
  const formData = new FormData();
  formData.append('data', new Blob([JSON.stringify(request)], { type: 'application/json' }));
  if (image) {
    formData.append('image', image);
  }
  const { data } = await apiClient.put<ApiResponse<AssetDetail>>(`/api/v1/assets/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
  return data;
}

export async function deleteAsset(id: number): Promise<ApiResponse<null>> {
  const { data } = await apiClient.delete<ApiResponse<null>>(`/api/v1/assets/${id}`);
  return data;
}

export async function updateAssetStatus(id: number, request: AssetStatusRequest): Promise<ApiResponse<AssetDetail>> {
  const { data } = await apiClient.patch<ApiResponse<AssetDetail>>(`/api/v1/assets/${id}/status`, request);
  return data;
}

export async function fetchAssetSummary(): Promise<ApiResponse<AssetSummary>> {
  const { data } = await apiClient.get<ApiResponse<AssetSummary>>('/api/v1/assets/summary');
  return data;
}
