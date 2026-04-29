'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import {
  profileUpdateSchema,
  passwordChangeSchema,
  type ProfileUpdateFormValues,
  type PasswordChangeFormValues,
} from '@/lib/validations/user';
import { useMyProfile, useUpdateProfile, useChangePassword } from '@/hooks/useUsers';
import { RoleBadge } from '@/components/users/RoleBadge';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';

export default function ProfilePage() {
  const { data: profile, isLoading } = useMyProfile();

  if (isLoading) {
    return <ProfileSkeleton />;
  }

  if (!profile) {
    return (
      <div className="py-16 text-center text-sm text-[#615d59]">
        프로필 정보를 불러올 수 없습니다.
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-[26px] font-bold tracking-[-0.625px]">내 프로필</h1>

      <div className="grid gap-6 md:grid-cols-2">
        <ProfileInfoCard profile={profile} />
        <PasswordChangeCard />
      </div>
    </div>
  );
}

function ProfileInfoCard({ profile }: { profile: NonNullable<ReturnType<typeof useMyProfile>['data']> }) {
  const mutation = useUpdateProfile();

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isDirty },
  } = useForm<ProfileUpdateFormValues>({
    resolver: zodResolver(profileUpdateSchema),
    defaultValues: {
      name: profile.name,
      phone: profile.phone ?? '',
    },
  });

  useEffect(() => {
    reset({
      name: profile.name,
      phone: profile.phone ?? '',
    });
  }, [profile, reset]);

  function handleFormSubmit(data: ProfileUpdateFormValues) {
    mutation.mutate({
      name: data.name,
      phone: data.phone || undefined,
    });
  }

  return (
    <div
      className="rounded-xl bg-background p-6"
      style={{ border: '1px solid rgba(0,0,0,0.1)' }}
    >
      <h2 className="mb-4 text-lg font-semibold">기본 정보</h2>
      <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
        <div className="space-y-1.5">
          <Label className="text-[#615d59]">이메일</Label>
          <p className="text-sm">{profile.email}</p>
        </div>

        <div className="space-y-1.5">
          <Label className="text-[#615d59]">역할</Label>
          <div>
            <RoleBadge role={profile.role} />
          </div>
        </div>

        <div className="space-y-1.5">
          <Label className="text-[#615d59]">지점</Label>
          <p className="text-sm">{profile.branchName ?? '-'}</p>
        </div>

        <div className="space-y-1.5">
          <Label htmlFor="profile-name">이름 *</Label>
          <Input
            id="profile-name"
            type="text"
            {...register('name')}
          />
          {errors.name && (
            <p className="text-xs text-[#dc2626]">{errors.name.message}</p>
          )}
        </div>

        <div className="space-y-1.5">
          <Label htmlFor="profile-phone">연락처</Label>
          <Input
            id="profile-phone"
            type="tel"
            placeholder="010-0000-0000"
            {...register('phone')}
          />
        </div>

        <Button type="submit" disabled={!isDirty || mutation.isPending}>
          {mutation.isPending ? '저장 중...' : '프로필 저장'}
        </Button>
      </form>
    </div>
  );
}

function PasswordChangeCard() {
  const mutation = useChangePassword();

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<PasswordChangeFormValues>({
    resolver: zodResolver(passwordChangeSchema),
    defaultValues: {
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    },
  });

  function handleFormSubmit(data: PasswordChangeFormValues) {
    mutation.mutate(
      {
        currentPassword: data.currentPassword,
        newPassword: data.newPassword,
      },
      {
        onSuccess: () => {
          reset();
        },
      },
    );
  }

  return (
    <div
      className="rounded-xl bg-background p-6"
      style={{ border: '1px solid rgba(0,0,0,0.1)' }}
    >
      <h2 className="mb-4 text-lg font-semibold">비밀번호 변경</h2>
      <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
        <div className="space-y-1.5">
          <Label htmlFor="currentPassword">현재 비밀번호 *</Label>
          <Input
            id="currentPassword"
            type="password"
            placeholder="현재 비밀번호"
            {...register('currentPassword')}
          />
          {errors.currentPassword && (
            <p className="text-xs text-[#dc2626]">{errors.currentPassword.message}</p>
          )}
        </div>

        <div className="space-y-1.5">
          <Label htmlFor="newPassword">새 비밀번호 *</Label>
          <Input
            id="newPassword"
            type="password"
            placeholder="8자 이상"
            {...register('newPassword')}
          />
          {errors.newPassword && (
            <p className="text-xs text-[#dc2626]">{errors.newPassword.message}</p>
          )}
        </div>

        <div className="space-y-1.5">
          <Label htmlFor="confirmPassword">새 비밀번호 확인 *</Label>
          <Input
            id="confirmPassword"
            type="password"
            placeholder="새 비밀번호 다시 입력"
            {...register('confirmPassword')}
          />
          {errors.confirmPassword && (
            <p className="text-xs text-[#dc2626]">{errors.confirmPassword.message}</p>
          )}
        </div>

        <Button type="submit" disabled={mutation.isPending}>
          {mutation.isPending ? '변경 중...' : '비밀번호 변경'}
        </Button>
      </form>
    </div>
  );
}

function ProfileSkeleton() {
  return (
    <div className="space-y-6">
      <div className="h-8 w-32 animate-pulse rounded bg-muted" />
      <div className="grid gap-6 md:grid-cols-2">
        <div className="rounded-xl p-6" style={{ border: '1px solid rgba(0,0,0,0.1)' }}>
          <div className="space-y-4">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="space-y-1.5">
                <div className="h-3.5 w-16 animate-pulse rounded bg-muted" />
                <div className="h-9 w-full animate-pulse rounded bg-muted" />
              </div>
            ))}
          </div>
        </div>
        <div className="rounded-xl p-6" style={{ border: '1px solid rgba(0,0,0,0.1)' }}>
          <div className="space-y-4">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="space-y-1.5">
                <div className="h-3.5 w-24 animate-pulse rounded bg-muted" />
                <div className="h-9 w-full animate-pulse rounded bg-muted" />
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
