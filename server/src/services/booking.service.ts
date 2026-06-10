import { prisma } from '../lib/db';
import { AppError } from '../middleware/errorHandler';


export async function createBooking(slotId: string, userId: string) {
  const [slot, user] = await Promise.all([
    prisma.slot.findUnique({ where: { id: slotId } }),
    prisma.user.findUnique({ where: { id: userId } }),
  ]);

  if (!user) throw new AppError(401, 'Unknown user — send a valid X-User-Id');
  if (!slot) throw new AppError(404, 'Slot not found');

  return prisma.$transaction(async (tx) => {
    // Atomic claim: matches only if slot is still AVAILABLE.
    // SQLite serialises writes, so exactly one concurrent caller wins.
    const claimed = await tx.slot.updateMany({
      where: { id: slotId, status: 'AVAILABLE' },
      data: { status: 'BOOKED' },
    });

    if (claimed.count === 0) {
      throw new AppError(409, 'Slot is already booked');
    }

    return tx.booking.create({
      data: { slotId, userId },
      select: {
        id: true,
        userId: true,
        slotId: true,
        createdAt: true,
        slot: {
          select: {
            date: true,
            startTime: true,
            endTime: true,
            venueId: true,
          },
        },
      },
    });
  });
}

export async function cancelBooking(bookingId: string, userId: string) {
  const booking = await prisma.booking.findUnique({ where: { id: bookingId } });

  if (!booking) throw new AppError(404, 'Booking not found');
  if (booking.userId !== userId) throw new AppError(403, 'You can only cancel your own bookings');

  await prisma.$transaction(async (tx) => {
    await tx.booking.delete({ where: { id: bookingId } });
    await tx.slot.update({
      where: { id: booking.slotId },
      data: { status: 'AVAILABLE' },
    });
  });
}
