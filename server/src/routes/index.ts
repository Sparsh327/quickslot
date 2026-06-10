import { Router } from 'express';
import { venueRouter } from './venue.routes';

export const router = Router();

router.use('/venues', venueRouter);
