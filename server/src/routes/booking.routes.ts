import { Router } from 'express';
import { requireUser } from '../middleware/auth';
import * as bookingController from '../controllers/booking.controller';

export const bookingRouter = Router();

bookingRouter.post('/', requireUser, bookingController.createBooking);
