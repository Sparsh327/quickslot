import { prisma } from '../lib/db';

export async function listVenues() {
  return prisma.venue.findMany({
    orderBy: { name: 'asc' },
  });
}

export async function getVenueSlots(venueId: string, date: string) {
  const venue = await prisma.venue.findUnique({ where: { id: venueId } });
  if (!venue) return null;

  const slots = await prisma.slot.findMany({
    where: { venueId, date },
    orderBy: { startTime: 'asc' },
    select: {
      id: true,
      venueId: true,
      date: true,
      startTime: true,
      endTime: true,
      status: true,
    },
  });

  return { venue, slots };
}
