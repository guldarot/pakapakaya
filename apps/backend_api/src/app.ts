import cors from 'cors';
import express from 'express';
import { resolve } from 'node:path';

import { env } from './config/env.js';
import { adminRouter } from './modules/admin/admin.routes.js';
import { authRouter } from './modules/auth/auth.routes.js';
import { chatRouter } from './modules/chat/chat.routes.js';
import { discoveryRouter } from './modules/discovery/discovery.routes.js';
import { ordersRouter } from './modules/orders/orders.routes.js';
import { trustRouter } from './modules/trust/trust.routes.js';
import { vendorsRouter } from './modules/vendors/vendors.routes.js';
import { createJsonApp } from './shared/http.js';

export function buildApp() {
  const app = createJsonApp();

  app.use(
    cors({
      origin: (origin, callback) => {
        if (!origin) {
          callback(null, true);
          return;
        }

        const isExactClientOrigin = origin === env.CLIENT_ORIGIN;
        const isLocalhostOrigin =
          origin.startsWith('http://localhost:') ||
          origin.startsWith('http://127.0.0.1:');

        if (isExactClientOrigin || isLocalhostOrigin) {
          callback(null, true);
          return;
        }

        callback(new Error(`Origin not allowed by CORS: ${origin}`));
      },
    }),
  );

  app.get('/health', (_req, res) => {
    res.json({ ok: true });
  });

  if (env.STORAGE_DRIVER === 'local') {
    app.use('/v1/uploads/local', express.static(resolve(env.STORAGE_LOCAL_DIR)));
  }

  app.use('/v1/auth', authRouter);
  app.use('/v1/discovery', discoveryRouter);
  app.use('/v1/trust', trustRouter);
  app.use('/v1/vendors', vendorsRouter);
  app.use('/v1/orders', ordersRouter);
  app.use('/v1/chat', chatRouter);
  app.use('/v1/admin', adminRouter);

  return app;
}
