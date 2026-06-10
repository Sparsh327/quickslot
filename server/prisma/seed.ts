/// <reference types="node" />
import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { PrismaLibSql } from '@prisma/adapter-libsql';

const adapter = new PrismaLibSql({ url: process.env.DATABASE_URL! });
const prisma = new PrismaClient({ adapter });

const VENUES = [
  {
    name: 'Green Park Badminton Arena',
    description: '4 indoor courts with AC and professional lighting',
    sport: 'Badminton',
    address: '12 Green Park Road, Delhi',
  },
  {
    name: 'Turf Zone',
    description: 'Premium synthetic turf, floodlit, 5-a-side and 7-a-side',
    sport: 'Football',
    address: '45 Sector 18, Noida',
  },
  {
    name: 'Champions Badminton Club',
    description: '6 professional courts with tournament-grade flooring',
    sport: 'Badminton',
    address: '8 MG Road, Bangalore',
  },
  {
    name: 'City Sports Turf',
    description: 'FIFA-approved synthetic turf, night games supported',
    sport: 'Football',
    address: '23 Indiranagar, Bangalore',
  },
  {
    name: 'AceSports Indoor Arena',
    description: 'Olympic-grade courts, coaching available',
    sport: 'Badminton',
    address: '56 Koramangala, Bangalore',
  },
];

const USERS = [
  { id: 'user_1', name: 'Alice Johnson' },
  { id: 'user_2', name: 'Bob Smith' },
  { id: 'user_3', name: 'Charlie Brown' },
];

function getDateRange(days: number): string[] {
  const dates: string[] = [];
  for (let i = 0; i < days; i++) {
    const d = new Date();
    d.setDate(d.getDate() + i);
    dates.push(d.toISOString().split('T')[0]);
  }
  return dates;
}

function getHourlySlots(): Array<{ startTime: string; endTime: string }> {
  const slots = [];
  for (let hour = 6; hour < 22; hour++) {
    slots.push({
      startTime: `${String(hour).padStart(2, '0')}:00`,
      endTime: `${String(hour + 1).padStart(2, '0')}:00`,
    });
  }
  return slots;
}

async function main() {
  console.log('Seeding database...');

  for (const user of USERS) {
    await prisma.user.upsert({
      where: { id: user.id },
      update: {},
      create: user,
    });
  }
  console.log(`Upserted ${USERS.length} users`);

  const dates = getDateRange(14);
  const timeSlots = getHourlySlots();

  for (const venueData of VENUES) {
    const venue = await prisma.venue.create({ data: venueData });

    const slotRows = dates.flatMap((date) =>
      timeSlots.map(({ startTime, endTime }) => ({
        venueId: venue.id,
        date,
        startTime,
        endTime,
        status: 'AVAILABLE',
      }))
    );

    await prisma.slot.createMany({ data: slotRows });
    console.log(`  Created venue "${venue.name}" with ${slotRows.length} slots`);
  }

  const totalSlots = VENUES.length * dates.length * timeSlots.length;
  console.log(`\nSeed complete: ${VENUES.length} venues, ${USERS.length} users, ${totalSlots} slots`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
