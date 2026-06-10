# QuickSlot — Backend

Node.js + TypeScript REST API for booking sports slots.

## Prerequisites

- Node.js 20+
- npm 10+

## Setup

```bash
cd server
npm install
```

## First-time database setup

```bash
# 1. Apply the migration (creates prisma/dev.db)
npm run db:migrate
# When prompted for a migration name, enter: init

# 2. Generate the Prisma client
npm run db:generate

# 3. Seed with 5 venues, 3 users, and 14 days of hourly slots
npm run db:seed
```

## Running locally

```bash
# Development (hot-reload via nodemon + tsx)
npm run dev

# Production build
npm run build
npm start
```

Server starts at **http://localhost:3000**

Health check: `GET http://localhost:3000/health`

## Available scripts

| Script | What it does |
|---|---|
| `npm run dev` | Start with hot-reload (tsx + nodemon) |
| `npm run build` | Compile TypeScript → `dist/` |
| `npm start` | Run compiled output |
| `npm run db:migrate` | Create & apply a new Prisma migration |
| `npm run db:generate` | Re-generate Prisma client after schema changes |
| `npm run db:seed` | Seed venues, users, and slots |
| `npm run db:studio` | Open Prisma Studio (visual DB browser) |

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `DATABASE_URL` | `file:./prisma/dev.db` | SQLite file path |
| `PORT` | `3000` | HTTP port |

Copy `.env` and adjust as needed (the file is git-ignored).
