import { prisma } from '../lib/db';

export async function listVenues() {
  return prisma.venue.findMany({
    orderBy: { name: 'asc' },
  });
}
