# GCP Setup Checklist

Use this checklist before your first `terraform plan`.

## 1. Decide the canonical values

Recommended starting values:

- `project_id`: your existing or new GCP project ID
- `region`: `asia-south1`
- `artifact_registry_repository_id`: `pakapakaya`
- `backend_service_name`: `pakapakaya-backend`
- `cloud_sql_instance_name`: `pakapakaya-postgres`
- `cloud_sql_database_name`: `pakapakaya`
- `db_user_name`: `pakapakaya_app`
- `db_user_password_secret_name`: `pakapakaya-db-password`
- `database_url_secret_name`: `pakapakaya-database-url`
- `persistence_mode`: `prisma`

Recommended naming examples:

- bucket: `pakapakaya-uploads-yourproject`
- GitHub owner: your GitHub username or org
- GitHub repo: the monorepo repo name

## 2. Fill `terraform.tfvars`

Copy:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Then replace the placeholders with real values.

## 3. Prepare runtime secrets

You will need:

- DB password secret value
- final `DATABASE_URL`

Suggested `DATABASE_URL` shape for Cloud SQL Postgres:

```text
postgresql://pakapakaya_app:<db-password>@/<database-name>?host=/cloudsql/<project>:<region>:<instance>
```

Example:

```text
postgresql://pakapakaya_app:replace-me@/pakapakaya?host=/cloudsql/my-project:asia-south1:pakapakaya-postgres
```

## 4. Prepare GitHub Actions secrets

Add these repository secrets in GitHub:

- `GCP_PROJECT_ID`
- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

These values come from Terraform outputs after apply.

## 5. Prepare frontend origin

For `client_origin`, choose the actual host that will call the backend.

Examples:

- local Flutter web during dev: `http://localhost:3000`
- deployed web app: `https://app.example.com`

If you expect both local and deployed callers, start with the deployed origin and keep localhost only in local envs.
