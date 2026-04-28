'use client';

import { useState } from 'react';
import type { AssetStatus } from '@/types/asset';
import { useUpdateAssetStatus } from '@/hooks/useAssets';
import { getStatusLabel } from './AssetStatusBadge';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from '@/components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';

interface StatusChangeDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  assetId: number;
  currentStatus: AssetStatus;
}

const ALL_STATUSES: AssetStatus[] = ['IN_USE', 'RENTED', 'BROKEN', 'IN_STORAGE', 'DISPOSED'];

export function StatusChangeDialog({
  open,
  onOpenChange,
  assetId,
  currentStatus,
}: StatusChangeDialogProps) {
  const [newStatus, setNewStatus] = useState<string>('');
  const mutation = useUpdateAssetStatus(assetId);

  const availableStatuses = ALL_STATUSES.filter((s) => s !== currentStatus);
  const items = availableStatuses.map((s) => ({ value: s, label: getStatusLabel(s) }));

  function handleConfirm() {
    if (!newStatus) return;
    mutation.mutate(
      { status: newStatus as AssetStatus },
      {
        onSuccess: () => {
          onOpenChange(false);
          setNewStatus('');
        },
      },
    );
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>상태 변경</DialogTitle>
          <DialogDescription>
            현재 상태: {getStatusLabel(currentStatus)}
          </DialogDescription>
        </DialogHeader>
        <div className="py-2">
          <Select value={newStatus} onValueChange={(val) => setNewStatus(val ?? '')} items={items}>
            <SelectTrigger className="w-full">
              <SelectValue placeholder="변경할 상태 선택" />
            </SelectTrigger>
            <SelectContent>
              {items.map((item) => (
                <SelectItem key={item.value} value={item.value}>
                  {item.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            취소
          </Button>
          <Button onClick={handleConfirm} disabled={!newStatus || mutation.isPending}>
            {mutation.isPending ? '변경 중...' : '변경'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
