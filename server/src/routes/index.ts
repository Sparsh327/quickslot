import { Router } from 'express';
import { venueRouter } from './venue.routes';
import { bookingRouter } from './booking.routes';

export const router = Router();

router.use('/venues', venueRouter);
router.use('/bookings', bookingRouter);
