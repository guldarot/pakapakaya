import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';

import { env } from '../../config/env.js';

export type StorageAsset = {
  key: string;
  publicUrl: string;
};

export type PreparedUpload = {
  assetPath: string;
  uploadUrl: string;
  publicUrl: string;
  method: 'PUT';
  headers: Record<string, string>;
};

export interface StorageService {
  getPublicUrl(key: string): string;
  saveTextAsset(key: string, contents: string): StorageAsset;
  prepareTextUpload(key: string, contents: string, contentType: string): PreparedUpload;
}

class LocalStorageService implements StorageService {
  getPublicUrl(key: string) {
    const base = env.STORAGE_PUBLIC_BASE_URL.replace(/\/$/, '');
    return `${base}/v1/uploads/local/${encodeURIComponent(key)}`;
  }

  saveTextAsset(key: string, contents: string) {
    const fullPath = resolve(env.STORAGE_LOCAL_DIR, key);
    mkdirSync(dirname(fullPath), { recursive: true });
    writeFileSync(fullPath, contents, 'utf8');
    return {
      key,
      publicUrl: this.getPublicUrl(key),
    };
  }

  prepareTextUpload(key: string, contents: string, contentType: string) {
    const asset = this.saveTextAsset(key, contents);
    return {
      assetPath: asset.key,
      uploadUrl: asset.publicUrl,
      publicUrl: asset.publicUrl,
      method: 'PUT' as const,
      headers: {
        'content-type': contentType,
      },
    };
  }
}

class GcsStorageService implements StorageService {
  getPublicUrl(key: string) {
    const base = env.GCS_PUBLIC_BASE_URL ?? `https://storage.googleapis.com/${env.GCS_BUCKET_NAME ?? 'bucket-not-configured'}`;
    return `${base.replace(/\/$/, '')}/${key}`;
  }

  saveTextAsset(key: string, _contents: string) {
    return {
      key,
      publicUrl: this.getPublicUrl(key),
    };
  }

  prepareTextUpload(key: string, _contents: string, contentType: string) {
    return {
      assetPath: key,
      uploadUrl: this.getPublicUrl(key),
      publicUrl: this.getPublicUrl(key),
      method: 'PUT' as const,
      headers: {
        'content-type': contentType,
      },
    };
  }
}

class S3StorageService implements StorageService {
  getPublicUrl(key: string) {
    const base = env.S3_PUBLIC_BASE_URL ?? `https://${env.S3_BUCKET_NAME ?? 'bucket-not-configured'}.s3.amazonaws.com`;
    return `${base.replace(/\/$/, '')}/${key}`;
  }

  saveTextAsset(key: string, _contents: string) {
    return {
      key,
      publicUrl: this.getPublicUrl(key),
    };
  }

  prepareTextUpload(key: string, _contents: string, contentType: string) {
    return {
      assetPath: key,
      uploadUrl: this.getPublicUrl(key),
      publicUrl: this.getPublicUrl(key),
      method: 'PUT' as const,
      headers: {
        'content-type': contentType,
      },
    };
  }
}

export function getStorageService(): StorageService {
  switch (env.STORAGE_DRIVER) {
    case 'gcs':
      return new GcsStorageService();
    case 's3':
      return new S3StorageService();
    default:
      return new LocalStorageService();
  }
}
