# GitHub Actions and Deployment

This monorepo includes baseline GitHub Actions workflows for CI and backend deployment.

## Workflows

- `.github/workflows/backend-ci.yml`
  - installs backend dependencies
  - generates Prisma client
  - builds the TypeScript backend
  - builds the backend Docker image

- `.github/workflows/flutter-ci.yml`
  - installs Flutter dependencies
  - runs `flutter analyze`
  - runs `flutter test`
  - builds the Flutter web target

- `.github/workflows/deploy-backend-cloud-run.yml`
  - manual deployment workflow for the backend
  - builds and pushes a container image to Artifact Registry
  - deploys the backend container to Cloud Run
  - injects build metadata through `APP_VERSION` and `APP_REVISION`
  - verifies the deployed service with `/ready`

## Recommended GitHub Secrets

For the Cloud Run deployment workflow:

- `GCP_PROJECT_ID`
- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

Recommended runtime secrets for the deployed service should live in Secret Manager rather than GitHub:

- `DATABASE_URL`
- storage credentials if you use signed uploads or non-default service identity

## Infra as Code

Infrastructure scaffolding for the backend deployment path lives in:

- `infra/terraform/gcp`

It covers:

- Artifact Registry
- Cloud Run
- Cloud SQL
- Secret Manager
- Cloud Storage
- GitHub OIDC wiring

See also:

- `infra/terraform/gcp/SETUP_CHECKLIST.md`
- `docs/deployment-secrets.md`

## Portability Notes

The deployment workflow is intentionally kept at the container boundary:

- the app stays Docker-based
- Cloud Run is treated as a runtime target
- PostgreSQL stays externalized through `DATABASE_URL`
- storage remains behind the backend storage adapter

The backend now exposes:

- `/health` for lightweight liveness
- `/ready` for dependency-aware readiness
- `/version` for operator-facing build metadata

The Cloud Run workflow uses `/ready` as the post-deploy sanity check.

If you later move away from Cloud Run, the CI workflows can stay mostly unchanged while only the deploy workflow changes.
