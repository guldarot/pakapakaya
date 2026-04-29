import { Router } from 'express';
import { z } from 'zod';

import { requireSessionUserId } from '../../shared/auth.js';
import { getVendorForUser } from './vendors.service.js';
import { readParams } from '../../shared/validation.js';

export const vendorsRouter = Router();

vendorsRouter.get('/:vendorId', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  const params = readParams(
    z.object({
      vendorId: z.string().min(1),
    }),
    req,
    res,
  );
  if (!params) return;

  res.json(await getVendorForUser(params.vendorId, userId));
});
