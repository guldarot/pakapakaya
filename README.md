# PakaPakaya Monorepo

This repository is the active rebuild workspace for PakaPakaya.

## Structure

- `apps/backend_api` - Express + Prisma backend API
- `apps/flutter_app` - Flutter client application
- `packages/contracts` - shared API contract artifacts
- `docs` - repo-level delivery and workflow notes
- `infra` - infrastructure as code and deployment scaffolding

## Local Development

Backend:

```powershell
cd C:\work\pakapakaya\apps\backend_api
npm run dev
```

Flutter:

```powershell
cd C:\work\pakapakaya\apps\flutter_app
flutter run -d chrome --dart-define=USE_MOCK_BACKEND=false --dart-define=API_BASE_URL=http://localhost:4000
```

## Notes

- The old top-level `pakapakaya_backend/` and `pakapakaya_flutter/` folders are temporarily left in place because live processes had those directories locked during migration.
- The monorepo source of truth is now under `apps/` and `packages/`.
- CI and deployment workflow notes live in `docs/github-actions.md`.
- GCP Terraform scaffolding for the backend lives in `infra/terraform/gcp`.
- Deployment secret guidance lives in `docs/deployment-secrets.md`.
