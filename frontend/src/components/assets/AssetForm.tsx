'use client';

import { useState } from 'react';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { assetFormSchema, type AssetFormValues } from '@/lib/validations/asset';
import type { AssetDetail } from '@/types/asset';
import type { CategoryTree } from '@/types/category';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from '@/components/ui/select';
import { CategoryCascadeSelect } from './CategoryCascadeSelect';
import { AssetImageUpload } from './AssetImageUpload';

interface AssetFormProps {
  mode: 'create' | 'edit';
  defaultValues?: AssetDetail;
  categoryTree: CategoryTree[];
  onSubmit: (data: AssetFormValues, image?: File) => void;
  isSubmitting: boolean;
}

const RATING_ITEMS = [
  { value: '1', label: '1 - 매우 나쁨' },
  { value: '2', label: '2 - 나쁨' },
  { value: '3', label: '3 - 보통' },
  { value: '4', label: '4 - 좋음' },
  { value: '5', label: '5 - 매우 좋음' },
];

function toFormValues(asset: AssetDetail): AssetFormValues {
  return {
    categoryId: asset.categoryId,
    assetName: asset.assetName,
    serialNumber: asset.serialNumber ?? '',
    manufacturer: asset.manufacturer ?? '',
    modelNumber: asset.modelNumber ?? '',
    purchaseDate: asset.purchaseDate ?? '',
    location: asset.location ?? '',
    managingDepartment: asset.managingDepartment ?? '',
    usingDepartment: asset.usingDepartment ?? '',
    conditionRating: asset.conditionRating ?? 5,
    technicalSpecs: asset.technicalSpecs ?? '',
    aiClassified: asset.aiClassified,
    notes: asset.notes ?? '',
  };
}

export function AssetForm({
  mode,
  defaultValues,
  categoryTree,
  onSubmit,
  isSubmitting,
}: AssetFormProps) {
  const [imageFile, setImageFile] = useState<File | null>(null);

  const {
    register,
    handleSubmit,
    control,
    formState: { errors },
  } = useForm<AssetFormValues>({
    resolver: zodResolver(assetFormSchema),
    defaultValues: defaultValues
      ? toFormValues(defaultValues)
      : { conditionRating: 5, aiClassified: false },
  });

  function handleFormSubmit(data: AssetFormValues) {
    onSubmit(data, imageFile ?? undefined);
  }

  return (
    <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-6">
      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        {/* 장비명 */}
        <div className="space-y-2">
          <Label htmlFor="assetName">장비명 *</Label>
          <Input id="assetName" placeholder="장비명을 입력하세요" {...register('assetName')} />
          {errors.assetName && (
            <p className="text-sm text-destructive">{errors.assetName.message}</p>
          )}
        </div>

        {/* 카테고리 */}
        <div className="space-y-2 md:col-span-2">
          <Label>카테고리 *</Label>
          <Controller
            name="categoryId"
            control={control}
            render={({ field }) => (
              <CategoryCascadeSelect
                value={field.value}
                onChange={(id) => field.onChange(id ?? 0)}
                categoryTree={categoryTree}
              />
            )}
          />
          {errors.categoryId && (
            <p className="text-sm text-destructive">{errors.categoryId.message}</p>
          )}
        </div>

        {/* 시리얼번호 */}
        <div className="space-y-2">
          <Label htmlFor="serialNumber">시리얼번호</Label>
          <Input id="serialNumber" placeholder="시리얼번호" {...register('serialNumber')} />
        </div>

        {/* 제조사 */}
        <div className="space-y-2">
          <Label htmlFor="manufacturer">제조사</Label>
          <Input id="manufacturer" placeholder="제조사" {...register('manufacturer')} />
        </div>

        {/* 모델번호 */}
        <div className="space-y-2">
          <Label htmlFor="modelNumber">모델번호</Label>
          <Input id="modelNumber" placeholder="모델번호" {...register('modelNumber')} />
        </div>

        {/* 구매일 */}
        <div className="space-y-2">
          <Label htmlFor="purchaseDate">구매일</Label>
          <Input id="purchaseDate" type="date" {...register('purchaseDate')} />
        </div>

        {/* 위치 */}
        <div className="space-y-2">
          <Label htmlFor="location">위치</Label>
          <Input id="location" placeholder="보관 위치" {...register('location')} />
        </div>

        {/* 관리부서 */}
        <div className="space-y-2">
          <Label htmlFor="managingDepartment">관리부서</Label>
          <Input id="managingDepartment" placeholder="관리부서" {...register('managingDepartment')} />
        </div>

        {/* 사용부서 */}
        <div className="space-y-2">
          <Label htmlFor="usingDepartment">사용부서</Label>
          <Input id="usingDepartment" placeholder="사용부서" {...register('usingDepartment')} />
        </div>

        {/* 상태등급 */}
        <div className="space-y-2">
          <Label>상태등급</Label>
          <Controller
            name="conditionRating"
            control={control}
            render={({ field }) => (
              <Select
                value={String(field.value)}
                onValueChange={(val) => field.onChange(Number(val ?? '5'))}
                items={RATING_ITEMS}
              >
                <SelectTrigger className="w-full">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {RATING_ITEMS.map((item) => (
                    <SelectItem key={item.value} value={item.value}>
                      {item.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            )}
          />
        </div>

        {/* 기술사양 */}
        <div className="space-y-2 md:col-span-2">
          <Label htmlFor="technicalSpecs">기술사양</Label>
          <Textarea
            id="technicalSpecs"
            placeholder="CPU, RAM, 저장장치 등 기술 사양을 입력하세요"
            rows={3}
            {...register('technicalSpecs')}
          />
        </div>

        {/* 비고 */}
        <div className="space-y-2 md:col-span-2">
          <Label htmlFor="notes">비고</Label>
          <Textarea id="notes" placeholder="추가 메모" rows={2} {...register('notes')} />
        </div>

        {/* 이미지 */}
        <div className="space-y-2 md:col-span-2">
          <Label>이미지</Label>
          <AssetImageUpload
            value={imageFile}
            onChange={setImageFile}
            existingImagePath={defaultValues?.imagePath}
          />
        </div>
      </div>

      <div className="flex gap-3">
        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting
            ? mode === 'create'
              ? '등록 중...'
              : '수정 중...'
            : mode === 'create'
              ? '장비 등록'
              : '수정 완료'}
        </Button>
        <Button type="button" variant="outline" onClick={() => window.history.back()}>
          취소
        </Button>
      </div>
    </form>
  );
}
