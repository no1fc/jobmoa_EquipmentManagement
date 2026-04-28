export type AssetStatus = 'IN_USE' | 'RENTED' | 'BROKEN' | 'IN_STORAGE' | 'DISPOSED';

export interface Asset {
  assetId: number;
  assetCode: string;
  assetName: string;
  status: AssetStatus;
  categoryName: string;
  categoryId: number;
  location: string | null;
  managingDepartment: string | null;
  usingDepartment: string | null;
  manufacturer: string | null;
  modelNumber: string | null;
  purchaseDate: string | null;
  imagePath: string | null;
  aiClassified: boolean;
  createdAt: string;
}

export interface AssetDetail {
  assetId: number;
  assetCode: string;
  assetName: string;
  status: AssetStatus;
  categoryId: number;
  categoryName: string;
  categoryPath: string[];
  serialNumber: string | null;
  manufacturer: string | null;
  modelNumber: string | null;
  purchaseDate: string | null;
  location: string | null;
  managingDepartment: string | null;
  usingDepartment: string | null;
  conditionRating: number | null;
  technicalSpecs: string | null;
  imagePath: string | null;
  aiClassified: boolean;
  notes: string | null;
  registeredByName: string;
  createdAt: string;
  updatedAt: string;
}

export interface AssetCreateRequest {
  categoryId: number;
  assetName: string;
  serialNumber?: string;
  manufacturer?: string;
  modelNumber?: string;
  purchaseDate?: string;
  location?: string;
  managingDepartment?: string;
  usingDepartment?: string;
  conditionRating?: number;
  technicalSpecs?: string;
  aiClassified?: boolean;
  notes?: string;
}

export interface AssetUpdateRequest {
  categoryId: number;
  assetName: string;
  serialNumber?: string;
  manufacturer?: string;
  modelNumber?: string;
  purchaseDate?: string;
  location?: string;
  managingDepartment?: string;
  usingDepartment?: string;
  conditionRating?: number;
  technicalSpecs?: string;
  notes?: string;
}

export interface AssetStatusRequest {
  status: AssetStatus;
}

export interface AssetSummary {
  total: number;
  inUse: number;
  rented: number;
  broken: number;
  inStorage: number;
  disposed: number;
}

export interface AssetSearchParams {
  page?: number;
  size?: number;
  status?: AssetStatus;
  categoryId?: number;
  search?: string;
  location?: string;
  managingDepartment?: string;
  usingDepartment?: string;
  sort?: string;
}
