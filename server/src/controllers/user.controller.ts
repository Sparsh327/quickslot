import { Request, Response, NextFunction } from 'express';
import * as userService from '../services/user.service';

export async function getUserBookings(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const result = await userService.getUserBookings(String(req.params.id));
    res.json({ data: result });
  } catch (err) {
    next(err);
  }
}
