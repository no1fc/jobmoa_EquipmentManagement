'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { rentalCreateSchema, type RentalCreateFormValues } from '@/lib/validations/rental';
import { useCreateRental } from '@/hooks/useRentals';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface CreateRentalDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function CreateRentalDialog({ open, onOpenChange }: CreateRentalDialogProps) {
  const mutation = useCreateRental();

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<RentalCreateFormValues>({
    resolver: zodResolver(rentalCreateSchema),
    defaultValues: {
      dueDays: 7,
    },
  });

  function handleFormSubmit(data: RentalCreateFormValues) {
    mutation.mutate(
      {
        assetId: data.assetId,
        borrowerName: data.borrowerName || undefined,
        rentalReason: data.rentalReason || undefined,
        dueDays: data.dueDays,
      },
      {
        onSuccess: () => {
          onOpenChange(false);
          reset();
        },
      },
    );
  }

  function handleClose() {
    onOpenChange(false);
    reset();
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>대여 등록</DialogTitle>
          <DialogDescription>새로운 장비 대여를 등록합니다.</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4 py-2">
          <div className="space-y-1.5">
            <Label htmlFor="assetId">장비 ID *</Label>
            <Input
              id="assetId"
              type="number"
              placeholder="장비 ID를 입력하세요"
              {...register('assetId', { valueAsNumber: true })}
            />
            {errors.assetId && (
              <p className="text-xs text-[#dc2626]">{errors.assetId.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="borrowerName">대여자 이름</Label>
            <Input
              id="borrowerName"
              type="text"
              placeholder="대여자 이름 (선택)"
              {...register('borrowerName')}
            />
            {errors.borrowerName && (
              <p className="text-xs text-[#dc2626]">{errors.borrowerName.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="rentalReason">대여 사유</Label>
            <Textarea
              id="rentalReason"
              placeholder="대여 사유를 입력하세요 (선택)"
              rows={3}
              {...register('rentalReason')}
            />
            {errors.rentalReason && (
              <p className="text-xs text-[#dc2626]">{errors.rentalReason.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="dueDays">대여 기간 (일) *</Label>
            <Input
              id="dueDays"
              type="number"
              min={1}
              max={30}
              placeholder="1~30일"
              {...register('dueDays', { valueAsNumber: true })}
            />
            {errors.dueDays && (
              <p className="text-xs text-[#dc2626]">{errors.dueDays.message}</p>
            )}
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={handleClose}>
              취소
            </Button>
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? '등록 중...' : '등록'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
