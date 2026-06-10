import { Router } from 'express';
import { venueRouter } from './venue.routes';
import { bookingRouter } from './booking.routes';
import { userRouter } from './user.routes';

export const router = Router();

router.use('/venues', venueRouter);
router.use('/bookings', bookingRouter);
router.use('/users', userRouter);
