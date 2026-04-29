import { Router } from 'express';
import { z } from 'zod';

import { requireSessionUserId } from '../../shared/auth.js';
import { listDiscoveryVendorsForUser } from './discovery.service.js';
import { readQuery } from '../../shared/validation.js';

export const discoveryRouter = Router();

discoveryRouter.get('/vendors', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  const query = readQuery(
    z.object({
      radiusKm: z.coerce.number().int().min(1).max(5).default(1),
    }),
    req,
    res,
  );
  if (!query) return;

  res.json(await listDiscoveryVendorsForUser(userId, query.radiusKm ?? 1));
});
