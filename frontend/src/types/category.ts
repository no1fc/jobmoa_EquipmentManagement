export interface Category {
  categoryId: number;
  parentId: number | null;
  categoryName: string;
  categoryLevel: number;
  description: string | null;
  createdAt: string;
}

export interface CategoryTree {
  categoryId: number;
  categoryName: string;
  categoryLevel: number;
  description: string | null;
  children: CategoryTree[];
}

export interface CategoryCreateRequest {
  parentId?: number;
  categoryName: string;
  categoryLevel: number;
  description?: string;
}

export interface CategoryUpdateRequest {
  categoryName: string;
  description?: string;
}
