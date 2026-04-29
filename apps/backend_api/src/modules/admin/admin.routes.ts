import { Router } from 'express';

import { stubSession } from '../../shared/stub-data.js';

export const adminRouter = Router();

adminRouter.get('/plans', (_req, res) => {
  res.json(stubSession.availablePlans);
});
