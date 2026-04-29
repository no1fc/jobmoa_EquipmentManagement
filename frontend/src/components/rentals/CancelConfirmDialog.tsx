'use client';

import { useCancelRental } from '@/hooks/useRentals';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface CancelConfirmDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  rentalId: number;
  assetName: string;
}

export function CancelConfirmDialog({
  open,
  onOpenChange,
  rentalId,
  assetName,
}: CancelConfirmDialogProps) {
  const mutation = useCancelRental();

  function handleCancel() {
    mutation.mutate(rentalId, {
      onSuccess: () => {
        onOpenChange(false);
      },
    });
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>대여 취소</DialogTitle>
          <DialogDescription>
            &apos;{assetName}&apos; 장비의 대여를 취소하시겠습니까? 이 작업은 되돌릴 수 없습니다.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            닫기
          </Button>
          <Button variant="destructive" onClick={handleCancel} disabled={mutation.isPending}>
            {mutation.isPending ? '취소 중...' : '대여 취소'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
