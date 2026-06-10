import { Request, Response, NextFunction } from 'express';
import * as venueService from '../services/venue.service';
import { getSlotsQuerySchema } from '../validators/slot.validator';

export async function listVenues(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const venues = await venueService.listVenues();
    res.json({ data: venues });
  } catch (err) {
    next(err);
  }
}

export async function getVenueSlots(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const parsed = getSlotsQuerySchema.safeParse(req.query);
    if (!parsed.success) {
      res.status(400).json({ error: parsed.error.flatten().fieldErrors });
      return;
    }

    const result = await venueService.getVenueSlots(String(req.params.id), parsed.data.date);
    if (!result) {
      res.status(404).json({ error: 'Venue not found' });
      return;
    }

    res.json({ data: result });
  } catch (err) {
    next(err);
  }
}
