'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { rentalReturnSchema, type RentalReturnFormValues } from '@/lib/validations/rental';
import { useReturnRental } from '@/hooks/useRentals';
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

interface ReturnDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  rentalId: number;
  assetName: string;
}

export function ReturnDialog({ open, onOpenChange, rentalId, assetName }: ReturnDialogProps) {
  const mutation = useReturnRental();

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<RentalReturnFormValues>({
    resolver: zodResolver(rentalReturnSchema),
  });

  function handleFormSubmit(data: RentalReturnFormValues) {
    mutation.mutate(
      {
        id: rentalId,
        request: {
          returnCondition: data.returnCondition || undefined,
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
          <DialogTitle>반납 처리</DialogTitle>
          <DialogDescription>&apos;{assetName}&apos; 장비를 반납합니다.</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4 py-2">
          <div className="space-y-1.5">
            <Label htmlFor="returnCondition">반납 상태</Label>
            <Textarea
              id="returnCondition"
              placeholder="반납 시 장비 상태를 입력하세요 (선택)"
              rows={3}
              {...register('returnCondition')}
            />
            {errors.returnCondition && (
              <p className="text-xs text-[#dc2626]">{errors.returnCondition.message}</p>
            )}
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={handleClose}>
              취소
            </Button>
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? '처리 중...' : '반납'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
