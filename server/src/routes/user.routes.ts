import { Router } from 'express';
import * as userController from '../controllers/user.controller';

export const userRouter = Router();

userRouter.get('/:id/bookings', userController.getUserBookings);
