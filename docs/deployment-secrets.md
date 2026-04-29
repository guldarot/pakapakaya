# Deployment Secrets Reference

This repo uses two secret layers:

## GitHub repository secrets

Used by GitHub Actions deployment workflows:

- `GCP_PROJECT_ID`
- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

## Google Secret Manager secrets

Used by the running backend service:

- database password secret
- `DATABASE_URL` secret

## Keep out of Git

Do not commit:

- `.env`
- service account JSON files
- Terraform state files if you keep state local
- raw database credentials

If you later add more backend secrets such as signed upload credentials, keep them in Secret Manager as well.
