import { randomUUID } from 'node:crypto';

import express, { NextFunction, Request, Response } from 'express';

import { env } from '../config/env.js';
import { prisma } from './prisma.js';

type ErrorPayload = {
  error: string;
  requestId: string;
  details?: unknown;
};

function requestIdFor(req: Request) {
  const headerValue = req.header('x-request-id');
  return headerValue && headerValue.trim().length > 0 ? headerValue.trim() : randomUUID();
}

function responseRequestId(res: Response) {
  return String(res.locals.requestId ?? 'unknown-request');
}

function safeString(value: unknown) {
  return typeof value === 'string' && value.trim().length > 0;
}

export function sendError(
  res: Response,
  status: number,
  error: string,
  details?: unknown,
) {
  const payload: ErrorPayload = {
    error,
    requestId: responseRequestId(res),
    ...(details == null ? {} : { details }),
  };
  return res.status(status).json(payload);
}

export function createJsonApp() {
  const app = express();

  app.disable('x-powered-by');
  app.use((req, res, next) => {
    const requestId = requestIdFor(req);
    res.locals.requestId = requestId;
    res.setHeader('x-request-id', requestId);
    next();
  });
  app.use(express.json());

  if (env.LOG_REQUESTS) {
    app.use((req, res, next) => {
      const startedAt = Date.now();
      res.on('finish', () => {
        const durationMs = Date.now() - startedAt;
        console.log(
          JSON.stringify({
            level: 'info',
            requestId: responseRequestId(res),
            method: req.method,
            path: req.originalUrl,
            statusCode: res.statusCode,
            durationMs,
          }),
        );
      });
      next();
    });
  }

  return app;
}

export async function buildReadinessPayload() {
  const base = {
    ok: true,
    service: 'pakapakaya-backend',
    version: env.APP_VERSION,
    revision: env.APP_REVISION,
    persistenceMode: env.PERSISTENCE_MODE,
    storageDriver: env.STORAGE_DRIVER,
    environment: env.NODE_ENV,
    timestamp: new Date().toISOString(),
  };

  if (env.PERSISTENCE_MODE !== 'prisma') {
    return {
      ...base,
      checks: {
        database: 'skipped',
      },
    };
  }

  await prisma.$queryRaw`SELECT 1`;
  return {
    ...base,
    checks: {
      database: 'ok',
    },
  };
}

export function attachErrorHandlers(app: express.Express) {
  app.use((_req, res) => {
    sendError(res, 404, 'Route not found');
  });

  app.use((error: unknown, _req: Request, res: Response, _next: NextFunction) => {
    const message =
      error instanceof Error && safeString(error.message)
        ? error.message
        : 'Internal server error';

    if (env.NODE_ENV !== 'production') {
      console.error(
        JSON.stringify({
          level: 'error',
          requestId: responseRequestId(res),
          message,
          stack: error instanceof Error ? error.stack : undefined,
        }),
      );
    }

    if (res.headersSent) {
      return;
    }

    sendError(res, 500, message);
  });
}
