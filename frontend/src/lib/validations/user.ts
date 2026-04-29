import { z } from 'zod';

export const userCreateSchema = z.object({
  email: z
    .string()
    .min(1, { message: '이메일을 입력해주세요.' })
    .email({ message: '올바른 이메일 형식이 아닙니다.' }),
  password: z
    .string()
    .min(8, { message: '비밀번호는 8자 이상이어야 합니다.' }),
  name: z
    .string()
    .min(1, { message: '이름을 입력해주세요.' }),
  role: z.enum(['COUNSELOR', 'MANAGER'], {
    error: '역할을 선택해주세요.',
  }),
  branchName: z.string().optional().or(z.literal('')),
  phone: z.string().optional().or(z.literal('')),
});

export type UserCreateFormValues = z.infer<typeof userCreateSchema>;

export const userUpdateSchema = z.object({
  name: z
    .string()
    .min(1, { message: '이름을 입력해주세요.' }),
  role: z.enum(['COUNSELOR', 'MANAGER'], {
    error: '역할을 선택해주세요.',
  }),
  branchName: z.string().optional().or(z.literal('')),
  phone: z.string().optional().or(z.literal('')),
});

export type UserUpdateFormValues = z.infer<typeof userUpdateSchema>;

export const profileUpdateSchema = z.object({
  name: z
    .string()
    .min(1, { message: '이름을 입력해주세요.' }),
  phone: z.string().optional().or(z.literal('')),
});

export type ProfileUpdateFormValues = z.infer<typeof profileUpdateSchema>;

export const passwordChangeSchema = z.object({
  currentPassword: z
    .string()
    .min(1, { message: '현재 비밀번호를 입력해주세요.' }),
  newPassword: z
    .string()
    .min(8, { message: '새 비밀번호는 8자 이상이어야 합니다.' }),
  confirmPassword: z
    .string()
    .min(1, { message: '비밀번호 확인을 입력해주세요.' }),
}).refine((data) => data.newPassword === data.confirmPassword, {
  message: '새 비밀번호가 일치하지 않습니다.',
  path: ['confirmPassword'],
});

export type PasswordChangeFormValues = z.infer<typeof passwordChangeSchema>;
