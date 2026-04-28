import { z } from 'zod';

export const assetFormSchema = z.object({
  categoryId: z
    .number({ error: '카테고리를 선택해주세요.' })
    .positive({ message: '카테고리를 선택해주세요.' }),
  assetName: z
    .string()
    .min(1, { message: '장비명을 입력해주세요.' })
    .max(200, { message: '장비명은 200자 이하로 입력해주세요.' }),
  serialNumber: z.string().max(128).optional().or(z.literal('')),
  manufacturer: z.string().max(100).optional().or(z.literal('')),
  modelNumber: z.string().max(128).optional().or(z.literal('')),
  purchaseDate: z.string().optional().or(z.literal('')),
  location: z.string().max(200).optional().or(z.literal('')),
  managingDepartment: z.string().max(100).optional().or(z.literal('')),
  usingDepartment: z.string().max(100).optional().or(z.literal('')),
  conditionRating: z.number().min(1).max(5),
  technicalSpecs: z.string().optional().or(z.literal('')),
  aiClassified: z.boolean(),
  notes: z.string().optional().or(z.literal('')),
});

export type AssetFormValues = z.infer<typeof assetFormSchema>;
