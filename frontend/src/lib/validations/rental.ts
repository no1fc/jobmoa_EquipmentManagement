import { z } from 'zod';

export const rentalCreateSchema = z.object({
  assetId: z
    .number({ error: '장비를 선택해주세요.' })
    .positive({ message: '장비를 선택해주세요.' }),
  borrowerName: z.string().max(100).optional().or(z.literal('')),
  rentalReason: z.string().max(500).optional().or(z.literal('')),
  dueDays: z
    .number({ error: '대여 기간을 입력해주세요.' })
    .min(1, { message: '최소 1일입니다.' })
    .max(30, { message: '최대 30일입니다.' }),
});

export type RentalCreateFormValues = z.infer<typeof rentalCreateSchema>;

export const rentalReturnSchema = z.object({
  returnCondition: z.string().max(500).optional().or(z.literal('')),
});

export type RentalReturnFormValues = z.infer<typeof rentalReturnSchema>;

export const rentalExtendSchema = z.object({
  extensionDays: z
    .number({ error: '연장 일수를 입력해주세요.' })
    .min(1, { message: '최소 1일입니다.' })
    .max(14, { message: '최대 14일입니다.' }),
});

export type RentalExtendFormValues = z.infer<typeof rentalExtendSchema>;
