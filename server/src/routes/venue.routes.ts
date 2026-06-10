import { Router } from 'express';
import * as venueController from '../controllers/venue.controller';

export const venueRouter = Router();

venueRouter.get('/', venueController.listVenues);
venueRouter.get('/:id/slots', venueController.getVenueSlots);
