import { Request, Response, NextFunction } from 'express';
import * as bookingService from '../services/booking.service';
import { createBookingSchema } from '../validators/booking.validator';

export async function createBooking(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const parsed = createBookingSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: parsed.error.flatten().fieldErrors });
      return;
    }

    const booking = await bookingService.createBooking(
      parsed.data.slotId,
      res.locals.userId as string
    );

    res.status(201).json({ data: booking });
  } catch (err) {
    next(err);
  }
}
