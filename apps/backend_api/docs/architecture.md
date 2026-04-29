# Backend Slice Notes

This backend scaffold is intentionally narrow but real:

- `src/app.ts` wires the Express app and route modules
- `src/modules/*` mirrors the OpenAPI and Flutter repository boundaries
- `src/modules/*/*.service.ts` now owns module logic so routes stay thin
- `src/modules/*/repositories/*.repository.ts` chooses the persistence implementation
- `prisma/schema.prisma` starts the PostgreSQL-aligned canonical schema
- route handlers return validated stub payloads so the mobile app can switch from mocks incrementally
- `src/shared/dev-store.ts` persists trust requests, orders, and chat messages to `data/dev-store.json`
- `PERSISTENCE_MODE` now switches between the JSON dev store and Prisma-backed repositories for auth bootstrap, discovery, vendor detail, trust, orders, and chat
- `src/shared/demo-bootstrap.ts` seeds a small repeatable demo dataset when Prisma mode is enabled
- `src/shared/prisma-presenters.ts` keeps Prisma records shaped like the Flutter-facing DTOs so the app contract stays stable

Recommended next order:
1. add Prisma migrations and generate the client from the current schema
2. move auth sessions off the dev JSON store and into a database-backed session table or signed token flow
3. replace demo seed assumptions with real vendor/menu/batch CRUD
4. tighten error handling in routes so domain failures return clean 4xx responses
5. add integration tests for the buyer flow in both `dev-store` and `prisma` modes
