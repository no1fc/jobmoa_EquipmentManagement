import apiClient from './client';
import type { ApiResponse } from '@/types/api';
import type { Category, CategoryTree, CategoryCreateRequest, CategoryUpdateRequest } from '@/types/category';

export async function fetchCategories(level?: number): Promise<ApiResponse<Category[]>> {
  const params = level ? { level } : undefined;
  const { data } = await apiClient.get<ApiResponse<Category[]>>('/api/v1/categories', { params });
  return data;
}

export async function fetchCategoryTree(): Promise<ApiResponse<CategoryTree[]>> {
  const { data } = await apiClient.get<ApiResponse<CategoryTree[]>>('/api/v1/categories/tree');
  return data;
}

export async function fetchCategory(id: number): Promise<ApiResponse<Category>> {
  const { data } = await apiClient.get<ApiResponse<Category>>(`/api/v1/categories/${id}`);
  return data;
}

export async function fetchCategoryChildren(id: number): Promise<ApiResponse<Category[]>> {
  const { data } = await apiClient.get<ApiResponse<Category[]>>(`/api/v1/categories/${id}/children`);
  return data;
}

export async function createCategory(request: CategoryCreateRequest): Promise<ApiResponse<Category>> {
  const { data } = await apiClient.post<ApiResponse<Category>>('/api/v1/categories', request);
  return data;
}

export async function updateCategory(id: number, request: CategoryUpdateRequest): Promise<ApiResponse<Category>> {
  const { data } = await apiClient.put<ApiResponse<Category>>(`/api/v1/categories/${id}`, request);
  return data;
}

export async function deleteCategory(id: number): Promise<ApiResponse<null>> {
  const { data } = await apiClient.delete<ApiResponse<null>>(`/api/v1/categories/${id}`);
  return data;
}
