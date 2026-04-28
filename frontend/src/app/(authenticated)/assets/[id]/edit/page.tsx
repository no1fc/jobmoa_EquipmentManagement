'use client';

import { use } from 'react';
import { useRouter } from 'next/navigation';
import { useAsset, useUpdateAsset } from '@/hooks/useAssets';
import { useCategoryTree } from '@/hooks/useCategories';
import { AssetForm } from '@/components/assets/AssetForm';
import type { AssetFormValues } from '@/lib/validations/asset';
import { Skeleton } from '@/components/ui/skeleton';

export default function EditAssetPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const assetId = Number(id);
  const router = useRouter();
  const { data: asset, isLoading: assetLoading } = useAsset(assetId);
  const { data: categoryTree, isLoading: categoriesLoading } = useCategoryTree();
  const updateAsset = useUpdateAsset(assetId);

  function handleSubmit(data: AssetFormValues, image?: File) {
    const { aiClassified: _, ...rest } = data;
    void _;
    updateAsset.mutate(
      {
        request: {
          ...rest,
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
        onSuccess: () => {
          router.push(`/assets/${assetId}`);
        },
      },
    );
  }

  if (assetLoading || categoriesLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-96 w-full" />
      </div>
    );
  }

  if (!asset) {
    return (
      <div className="flex h-40 items-center justify-center text-muted-foreground">
        장비를 찾을 수 없습니다.
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">장비 수정</h1>
      <AssetForm
        mode="edit"
        defaultValues={asset}
        categoryTree={categoryTree ?? []}
        onSubmit={handleSubmit}
        isSubmitting={updateAsset.isPending}
      />
    </div>
  );
}
