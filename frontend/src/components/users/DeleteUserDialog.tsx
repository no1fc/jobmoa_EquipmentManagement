'use client';

import { useDeleteUser } from '@/hooks/useUsers';
import type { User } from '@/types/user';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface DeleteUserDialogProps {
  user: User | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function DeleteUserDialog({ user, open, onOpenChange }: DeleteUserDialogProps) {
  const mutation = useDeleteUser();

  function handleConfirm() {
    if (!user) return;
    mutation.mutate(user.userId, {
      onSuccess: () => {
        onOpenChange(false);
      },
    });
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>사용자 비활성화</DialogTitle>
          <DialogDescription>
            <strong>{user?.name}</strong> ({user?.email}) 사용자를 비활성화하시겠습니까?
            비활성화된 사용자는 로그인할 수 없습니다.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
            취소
          </Button>
          <Button
            type="button"
            variant="destructive"
            onClick={handleConfirm}
            disabled={mutation.isPending}
          >
            {mutation.isPending ? '처리 중...' : '비활성화'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
