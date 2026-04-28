import apiClient from './client';
import type { ApiResponse, PageResponse } from '@/types/api';
import type {
  Rental,
  RentalCreateRequest,
  RentalReturnRequest,
  RentalExtendRequest,
  RentalDashboard,
  RentalSearchParams,
} from '@/types/rental';

export async function fetchRentals(params?: RentalSearchParams): Promise<ApiResponse<PageResponse<Rental>>> {
  const { data } = await apiClient.get<ApiResponse<PageResponse<Rental>>>('/api/v1/rentals', { params });
  return data;
}

export async function fetchRental(id: number): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.get<ApiResponse<Rental>>(`/api/v1/rentals/${id}`);
  return data;
}

export async function createRental(request: RentalCreateRequest): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.post<ApiResponse<Rental>>('/api/v1/rentals', request);
  return data;
}

export async function returnRental(id: number, request: RentalReturnRequest): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.put<ApiResponse<Rental>>(`/api/v1/rentals/${id}/return`, request);
  return data;
}

export async function extendRental(id: number, request: RentalExtendRequest): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.put<ApiResponse<Rental>>(`/api/v1/rentals/${id}/extend`, request);
  return data;
}

export async function cancelRental(id: number): Promise<ApiResponse<Rental>> {
  const { data } = await apiClient.put<ApiResponse<Rental>>(`/api/v1/rentals/${id}/cancel`);
  return data;
}

export async function fetchRentalDashboard(): Promise<ApiResponse<RentalDashboard>> {
  const { data } = await apiClient.get<ApiResponse<RentalDashboard>>('/api/v1/rentals/dashboard');
  return data;
}

export async function fetchOverdueRentals(): Promise<ApiResponse<Rental[]>> {
  const { data } = await apiClient.get<ApiResponse<Rental[]>>('/api/v1/rentals/overdue');
  return data;
}

export async function fetchAssetRentalHistory(assetId: number): Promise<ApiResponse<Rental[]>> {
  const { data } = await apiClient.get<ApiResponse<Rental[]>>(`/api/v1/rentals/asset/${assetId}/history`);
  return data;
}
