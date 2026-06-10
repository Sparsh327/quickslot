import { z } from 'zod';

export const getSlotsQuerySchema = z.object({
  date: z
    .string({ error: 'date is required' })
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'date must be YYYY-MM-DD'),
});

export type GetSlotsQuery = z.infer<typeof getSlotsQuerySchema>;
