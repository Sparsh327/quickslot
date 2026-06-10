import { prisma } from '../lib/db';
import { AppError } from '../middleware/errorHandler';

export async function listUsers() {
  return prisma.user.findMany({ orderBy: { name: 'asc' } });
}

export async function getUserBookings(userId: string) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw new AppError(404, 'User not found');

  const bookings = await prisma.booking.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
    select: {
      id: true,
      createdAt: true,
      slot: {
        select: {
          id: true,
          date: true,
          startTime: true,
          endTime: true,
          status: true,
          venue: {
            select: { id: true, name: true, sport: true, address: true },
          },
        },
      },
    },
  });

  return { user: { id: user.id, name: user.name }, bookings };
}
