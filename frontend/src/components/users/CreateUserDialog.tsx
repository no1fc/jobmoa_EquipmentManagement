'use client';

import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { userCreateSchema, type UserCreateFormValues } from '@/lib/validations/user';
import { useCreateUser } from '@/hooks/useUsers';
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

interface CreateUserDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

const ROLE_OPTIONS = [
  { value: 'COUNSELOR', label: '상담사' },
  { value: 'MANAGER', label: '관리자' },
];

export function CreateUserDialog({ open, onOpenChange }: CreateUserDialogProps) {
  const mutation = useCreateUser();

  const {
    register,
    handleSubmit,
    reset,
    control,
    formState: { errors },
  } = useForm<UserCreateFormValues>({
    resolver: zodResolver(userCreateSchema),
    defaultValues: {
      email: '',
      password: '',
      name: '',
      role: 'COUNSELOR',
      branchName: '',
      phone: '',
    },
  });

  function handleFormSubmit(data: UserCreateFormValues) {
    mutation.mutate(
      {
        email: data.email,
        password: data.password,
        name: data.name,
        role: data.role,
        branchName: data.branchName || undefined,
        phone: data.phone || undefined,
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
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>사용자 등록</DialogTitle>
          <DialogDescription>새로운 사용자를 등록합니다.</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4 py-2">
          <div className="space-y-1.5">
            <Label htmlFor="create-email">이메일 *</Label>
            <Input
              id="create-email"
              type="email"
              placeholder="user@jobmoa.kr"
              {...register('email')}
            />
            {errors.email && (
              <p className="text-xs text-[#dc2626]">{errors.email.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="create-password">비밀번호 *</Label>
            <Input
              id="create-password"
              type="password"
              placeholder="8자 이상"
              {...register('password')}
            />
            {errors.password && (
              <p className="text-xs text-[#dc2626]">{errors.password.message}</p>
            )}
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="create-name">이름 *</Label>
            <Input
              id="create-name"
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
            <Label htmlFor="create-branchName">지점명</Label>
            <Input
              id="create-branchName"
              type="text"
              placeholder="소속 지점 (선택)"
              {...register('branchName')}
            />
          </div>

          <div className="space-y-1.5">
            <Label htmlFor="create-phone">연락처</Label>
            <Input
              id="create-phone"
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
              {mutation.isPending ? '등록 중...' : '등록'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
