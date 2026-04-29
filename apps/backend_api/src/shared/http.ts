import express from 'express';

export function createJsonApp() {
  const app = express();
  app.use(express.json());
  return app;
}
