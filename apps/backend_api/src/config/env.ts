import 'dotenv/config';
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.string().default('4000'),
  APP_VERSION: z.string().default('0.1.0'),
  APP_REVISION: z.string().default('dev'),
  DATABASE_URL: z.string().default('postgresql://postgres:postgres@localhost:5432/pakapakaya'),
  CLIENT_ORIGIN: z.string().default('http://localhost:3000'),
  PERSISTENCE_MODE: z.enum(['dev-store', 'prisma']).default('prisma'),
  LOG_REQUESTS: z
    .enum(['true', 'false'])
    .default(process.env.NODE_ENV === 'production' ? 'true' : 'false')
    .transform((value) => value === 'true'),
  STORAGE_DRIVER: z.enum(['local', 'gcs', 's3']).default('local'),
  STORAGE_LOCAL_DIR: z.string().default('./data/storage'),
  STORAGE_PUBLIC_BASE_URL: z.string().default('http://localhost:4000'),
  GCS_BUCKET_NAME: z.string().optional(),
  GCS_PUBLIC_BASE_URL: z.string().optional(),
  S3_BUCKET_NAME: z.string().optional(),
  S3_PUBLIC_BASE_URL: z.string().optional(),
});

function isMissingRaw(name: string) {
  const value = process.env[name];
  return value == null || value.trim().length == 0;
}

function validateProductionEnv(parsedEnv: z.infer<typeof envSchema>) {
  if (parsedEnv.NODE_ENV !== 'production') {
    return;
  }

  const errors: string[] = [];

  for (const requiredName of ['DATABASE_URL', 'CLIENT_ORIGIN', 'APP_VERSION', 'APP_REVISION']) {
    if (isMissingRaw(requiredName)) {
      errors.push(`${requiredName} must be explicitly set in production.`);
    }
  }

  if (
    parsedEnv.CLIENT_ORIGIN.startsWith('http://localhost:') ||
    parsedEnv.CLIENT_ORIGIN.startsWith('http://127.0.0.1:')
  ) {
    errors.push('CLIENT_ORIGIN cannot point to localhost in production.');
  }

  if (parsedEnv.STORAGE_DRIVER === 'gcs' && isMissingRaw('GCS_BUCKET_NAME')) {
    errors.push('GCS_BUCKET_NAME must be set when STORAGE_DRIVER=gcs.');
  }

  if (parsedEnv.STORAGE_DRIVER === 's3' && isMissingRaw('S3_BUCKET_NAME')) {
    errors.push('S3_BUCKET_NAME must be set when STORAGE_DRIVER=s3.');
  }

  if (errors.length > 0) {
    throw new Error(`Invalid production environment:\n- ${errors.join('\n- ')}`);
  }
}

const parsedEnv = envSchema.parse(process.env);
validateProductionEnv(parsedEnv);

export const env = parsedEnv;
