'use client';

import { useRouter } from 'next/navigation';
import { useDeleteAsset } from '@/hooks/useAssets';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface DeleteConfirmDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  assetId: number;
  assetName: string;
}

export function DeleteConfirmDialog({
  open,
  onOpenChange,
  assetId,
  assetName,
}: DeleteConfirmDialogProps) {
  const router = useRouter();
  const mutation = useDeleteAsset();

  function handleDelete() {
    mutation.mutate(assetId, {
      onSuccess: () => {
        onOpenChange(false);
        router.push('/assets');
      },
    });
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>장비 삭제</DialogTitle>
          <DialogDescription>
            &apos;{assetName}&apos; 장비를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            취소
          </Button>
          <Button variant="destructive" onClick={handleDelete} disabled={mutation.isPending}>
            {mutation.isPending ? '삭제 중...' : '삭제'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
