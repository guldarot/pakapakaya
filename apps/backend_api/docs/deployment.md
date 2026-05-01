# Deployment Notes

## Portability-first shape

This backend is designed to stay portable across:

- local Docker Compose
- Google Cloud Run
- Kubernetes later
- other container hosts

The portability choices are:

- one stateless API container
- PostgreSQL via `DATABASE_URL`
- storage hidden behind `StorageService`
- environment-driven configuration
- no backend dependency on Firebase, Firestore, or other cloud-specific runtimes

## Local container run

From `C:\work\pakapakaya\apps\backend_api`:

```powershell
docker compose up --build
```

This starts:

- `postgres` on `localhost:5432`
- `backend` on `http://localhost:4000`

For local Docker, the backend container runs:

```text
node dist/server.js
```

Run migrations separately before or alongside release workflows:

```text
npm run prisma:deploy
```

## Google Cloud Run recommendation

Use Cloud Run for the API container, but keep the container generic.

Recommended pieces:

- Cloud Run for the backend container
- Cloud SQL for PostgreSQL for the database
- Cloud Storage only through the storage abstraction
- Secret Manager for runtime secrets

Important Cloud Run startup guidance:

- keep the Cloud Run container focused on starting the HTTP server
- do not block service startup on `prisma migrate deploy`
- run migrations as a separate release step so database problems fail clearly and do not surface as misleading port-health errors

The application itself should only know:

- `DATABASE_URL`
- `PERSISTENCE_MODE`
- `APP_VERSION`
- `APP_REVISION`
- storage env vars
- client origin

## Production env validation

When `NODE_ENV=production`, startup now fails fast unless the environment is explicit.

Required in production:

- `DATABASE_URL`
- `CLIENT_ORIGIN`
- `APP_VERSION`
- `APP_REVISION`

Additional production rules:

- `CLIENT_ORIGIN` must not point to `localhost` or `127.0.0.1`
- `GCS_BUCKET_NAME` is required when `STORAGE_DRIVER=gcs`
- `S3_BUCKET_NAME` is required when `STORAGE_DRIVER=s3`

Use [`.env.production.example`](../.env.production.example) as the baseline template.

## Runtime endpoints

The container exposes three useful operational endpoints:

- `/health`
  - lightweight liveness probe
  - returns service name, version, revision, timestamp, and request id
- `/ready`
  - dependency-aware readiness probe
  - checks the database when `PERSISTENCE_MODE=prisma`
- `/version`
  - lightweight build metadata endpoint
  - useful for support/debugging and deploy verification

Recommended platform usage:

- liveness checks should use `/health`
- post-deploy verification and readiness checks should use `/ready`
- human/operator diagnostics can use `/version`

## Cloud Run startup troubleshooting

If Cloud Run says the container did not listen on `PORT=8080` in time, for this repo the most likely real causes are:

- `DATABASE_URL` missing or malformed
- Cloud SQL instance not attached
- Cloud Run runtime service account missing `Cloud SQL Client`
- production env validation failing on startup

Because the container now starts only `node dist/server.js`, Cloud Run failures should be easier to interpret than when migrations were bundled into startup.

## Storage portability

`src/shared/storage/storage.service.ts` is the adapter seam.

Current drivers:

- `local`
- `gcs` placeholder
- `s3` placeholder

That means we can later add signed upload flows without changing order, chat, or trust business logic.

## Avoiding lock-in

To keep future migration easy:

- keep business logic in services and repositories
- keep GCP-specific code in adapters only
- keep PostgreSQL features conservative unless we intentionally choose otherwise
- keep Terraform or OpenTofu outside app code as the deployment layer
