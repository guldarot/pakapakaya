import 'dotenv/config';
import { z } from 'zod';

const envSchema = z.object({
  PORT: z.string().default('4000'),
  DATABASE_URL: z.string().default('postgresql://postgres:postgres@localhost:5432/pakapakaya'),
  CLIENT_ORIGIN: z.string().default('http://localhost:3000'),
  PERSISTENCE_MODE: z.enum(['dev-store', 'prisma']).default('dev-store'),
  STORAGE_DRIVER: z.enum(['local', 'gcs', 's3']).default('local'),
  STORAGE_LOCAL_DIR: z.string().default('./data/storage'),
  STORAGE_PUBLIC_BASE_URL: z.string().default('http://localhost:4000'),
  GCS_BUCKET_NAME: z.string().optional(),
  GCS_PUBLIC_BASE_URL: z.string().optional(),
  S3_BUCKET_NAME: z.string().optional(),
  S3_PUBLIC_BASE_URL: z.string().optional(),
});

export const env = envSchema.parse(process.env);
