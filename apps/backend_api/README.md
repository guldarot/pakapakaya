# PakaPakaya Backend

First backend implementation slice for the Flutter rebuild.

Included here:
- Express + TypeScript service skeleton
- Route modules grouped by product contract
- Starter Prisma schema plus a checked-in baseline migration for the canonical domain
- Prisma-backed demo flow for auth, discovery, orders, payment proof, and chat
- Deployment-friendly health, readiness, version, and request-id behavior
- Docker packaging for portable deployment
- Docker Compose for local PostgreSQL + backend
- Storage abstraction for local/GCS/S3-backed asset URLs
- Integration smoke test for the core buyer journey

Next:
1. copy `.env.example` to `.env`
2. `npm run db:prepare`
3. `npm run dev`
4. `npm test`
5. or run `docker compose up --build`
6. use `PERSISTENCE_MODE=prisma` for the database-backed flow

Production configuration:
- use `.env.production.example` as the starting template
- set `APP_VERSION` and `APP_REVISION` explicitly in deployed environments
- production startup now fails fast if critical env vars are missing or still pointing at localhost

For a fresh deploy target, prefer:
- `npm run prisma:deploy`
- then `npm run seed:demo` only for non-production demo environments

Operational endpoints:
- `/health`
- `/ready`
- `/version`

See:
- [deployment.md](docs/deployment.md)
- [architecture.md](docs/architecture.md)
