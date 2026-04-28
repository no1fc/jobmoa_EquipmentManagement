'use client';

import { useRouter } from 'next/navigation';
import { useCreateAsset } from '@/hooks/useAssets';
import { useCategoryTree } from '@/hooks/useCategories';
import { AssetForm } from '@/components/assets/AssetForm';
import type { AssetFormValues } from '@/lib/validations/asset';
import { Skeleton } from '@/components/ui/skeleton';

export default function NewAssetPage() {
  const router = useRouter();
  const { data: categoryTree, isLoading: categoriesLoading } = useCategoryTree();
  const createAsset = useCreateAsset();

  function handleSubmit(data: AssetFormValues, image?: File) {
    const { aiClassified, ...rest } = data;
    createAsset.mutate(
      {
        request: {
          ...rest,
          aiClassified,
          serialNumber: rest.serialNumber || undefined,
          manufacturer: rest.manufacturer || undefined,
          modelNumber: rest.modelNumber || undefined,
          purchaseDate: rest.purchaseDate || undefined,
          location: rest.location || undefined,
          managingDepartment: rest.managingDepartment || undefined,
          usingDepartment: rest.usingDepartment || undefined,
          technicalSpecs: rest.technicalSpecs || undefined,
          notes: rest.notes || undefined,
        },
        image,
      },
      {
        onSuccess: (res) => {
          if (res.data) {
            router.push(`/assets/${res.data.assetId}`);
          } else {
            router.push('/assets');
          }
        },
      },
    );
  }

  if (categoriesLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-96 w-full" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">장비 등록</h1>
      <AssetForm
        mode="create"
        categoryTree={categoryTree ?? []}
        onSubmit={handleSubmit}
        isSubmitting={createAsset.isPending}
      />
    </div>
  );
}
