import { useQuery } from '@tanstack/react-query';
import { fetchCategoryTree } from '@/lib/api/categories';

export function useCategoryTree() {
  return useQuery({
    queryKey: ['categories', 'tree'],
    queryFn: fetchCategoryTree,
    select: (res) => res.data,
    staleTime: 600_000,
  });
}
