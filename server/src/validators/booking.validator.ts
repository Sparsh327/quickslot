import { z } from 'zod';

export const createBookingSchema = z.object({
  slotId: z.string().min(1, 'slotId is required'),
});

export type CreateBookingBody = z.infer<typeof createBookingSchema>;
