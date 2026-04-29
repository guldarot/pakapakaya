# GCP Terraform Scaffold

This directory contains a portability-first infrastructure scaffold for deploying the backend to Google Cloud.

## What it provisions

- Artifact Registry Docker repository
- Cloud Storage bucket for uploads
- Secret Manager secrets for DB password and `DATABASE_URL`
- Cloud SQL PostgreSQL instance, database, and app user
- Cloud Run backend service
- GitHub OIDC workload identity resources for deployment automation

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Fill in project and repository values
3. Create secret versions for:
   - DB password
   - `DATABASE_URL`
4. Run:

```powershell
cd C:\work\pakapakaya\infra\terraform\gcp
terraform init
terraform plan
terraform apply
```

## Notes

- This scaffold is compatible with Terraform and should also be straightforward to use with OpenTofu.
- `DATABASE_URL` is intentionally injected through Secret Manager rather than assembled in app code.
- The backend remains a generic container; Google Cloud is only the hosting layer here.
- See `SETUP_CHECKLIST.md` for the first real values and secrets you will need.
