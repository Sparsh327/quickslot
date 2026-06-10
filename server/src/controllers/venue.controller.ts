import { Request, Response, NextFunction } from 'express';
import * as venueService from '../services/venue.service';

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
