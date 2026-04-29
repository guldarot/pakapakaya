# PakaPakaya Backend

First backend implementation slice for the Flutter rebuild.

Included here:
- Express + TypeScript service skeleton
- Route modules grouped by product contract
- Starter Prisma schema for the canonical domain
- Stub handlers so the mobile app can be wired against real endpoints next
- Docker packaging for portable deployment
- Docker Compose for local PostgreSQL + backend
- Storage abstraction for local/GCS/S3-backed asset URLs

Next:
1. copy `.env.example` to `.env`
2. `npm run prisma:generate`
3. `npm run dev`
4. or run `docker compose up --build`
5. use `PERSISTENCE_MODE=prisma` for the database-backed flow

See:
- [deployment.md](docs/deployment.md)
- [architecture.md](docs/architecture.md)
