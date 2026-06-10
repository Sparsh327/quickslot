import { Request, Response, NextFunction } from 'express';

export function requireUser(req: Request, res: Response, next: NextFunction): void {
  const userId = req.headers['x-user-id'];
  if (!userId || typeof userId !== 'string') {
    res.status(401).json({ error: 'X-User-Id header is required' });
    return;
  }
  res.locals.userId = userId;
  next();
}
