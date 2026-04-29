'use client';

import { useEffect } from 'react';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { userUpdateSchema, type UserUpdateFormValues } from '@/lib/validations/user';
import { useUpdateUser } from '@/hooks/useUsers';
import type { User } from '@/types/user';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
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

interface EditUserDialogProps {
  user: User | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

const ROLE_OPTIONS = [
  { value: 'COUNSELOR', label: '상담사' },
  { value: 'MANAGER', label: '관리자' },
];

export function EditUserDialog({ user, open, onOpenChange }: EditUserDialogProps) {
  const mutation = useUpdateUser();

  const {
    register,
    handleSubmit,
    reset,
    control,
    formState: { errors },
  } = useForm<UserUpdateFormValues>({
    resolver: zodResolver(userUpdateSchema),
  });

  useEffect(() => {
    if (user && open) {
      reset({
        name: user.name,
        role: user.role,
        branchName: user.branchName ?? '',
        phone: user.phone ?? '',
      });
    }
  }, [user, open, reset]);

  function handleFormSubmit(data: UserUpdateFormValues) {
    if (!user) return;
    mutation.mutate(
      {
        id: user.userId,
        request: {
          name: data.name,
          role: data.role,
          branchName: data.branchName || undefined,
          phone: data.phone || undefined,
        },
      },
      {
        onSuccess: () => {
          onOpenChange(false);
        },
      },
    );
  }

  function handleClose() {
    onOpenChange(false);
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>사용자 수정</DialogTitle>
          <DialogDescription>
            {user?.email} 사용자의 정보를 수정합니다.
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4 py-2">
          <div className="space-y-1.5">
            <Label htmlFor="edit-name">이름 *</Label>
            <Input
              id="edit-name"
              type="text"
              placeholder="이름을 입력하세요"
              {...register('name')}
            />
            {errors.name && (
              <p className="text-xs text-[#dc2626]">{errors.name.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <Label>역할 *</Label>
            <Controller
              name="role"
              control={control}
              render={({ field }) => (
                <Select
                  value={field.value}
                  onValueChange={field.onChange}
                  items={ROLE_OPTIONS}
                >
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="역할 선택" />
                  </SelectTrigger>
                  <SelectContent>
                    {ROLE_OPTIONS.map((opt) => (
                      <SelectItem key={opt.value} value={opt.value}>
                        {opt.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              )}
            />
            {errors.role && (
              <p className="text-xs text-[#dc2626]">{errors.role.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="edit-branchName">지점명</Label>
            <Input
              id="edit-branchName"
              type="text"
              placeholder="소속 지점 (선택)"
              {...register('branchName')}
            />
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="edit-phone">연락처</Label>
            <Input
              id="edit-phone"
              type="tel"
              placeholder="010-0000-0000 (선택)"
              {...register('phone')}
            />
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={handleClose}>
              취소
            </Button>
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? '수정 중...' : '수정'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
