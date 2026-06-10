import { Router } from 'express';
import * as userController from '../controllers/user.controller';

export const userRouter = Router();

userRouter.get('/', userController.listUsers);
userRouter.get('/:id/bookings', userController.getUserBookings);
