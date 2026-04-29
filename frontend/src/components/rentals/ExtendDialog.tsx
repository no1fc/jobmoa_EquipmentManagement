'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { rentalExtendSchema, type RentalExtendFormValues } from '@/lib/validations/rental';
import { useExtendRental } from '@/hooks/useRentals';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface ExtendDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  rentalId: number;
  assetName: string;
  currentDueDate: string;
}

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
}

export function ExtendDialog({
  open,
  onOpenChange,
  rentalId,
  assetName,
  currentDueDate,
}: ExtendDialogProps) {
  const mutation = useExtendRental();

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<RentalExtendFormValues>({
    resolver: zodResolver(rentalExtendSchema),
    defaultValues: {
      extensionDays: 7,
    },
  });

  function handleFormSubmit(data: RentalExtendFormValues) {
    mutation.mutate(
      {
        id: rentalId,
        request: {
          extensionDays: data.extensionDays,
        },
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
          <DialogTitle>대여 연장</DialogTitle>
          <DialogDescription>
            &apos;{assetName}&apos; 장비의 반납기한을 연장합니다. 현재 반납기한:{' '}
            {formatDate(currentDueDate)}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4 py-2">
          <div className="space-y-1.5">
            <Label htmlFor="extensionDays">연장 일수 *</Label>
            <Input
              id="extensionDays"
              type="number"
              min={1}
              max={14}
              placeholder="1~14일"
              {...register('extensionDays', { valueAsNumber: true })}
            />
            {errors.extensionDays && (
              <p className="text-xs text-[#dc2626]">{errors.extensionDays.message}</p>
            )}
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={handleClose}>
              취소
            </Button>
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? '연장 중...' : '연장'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
