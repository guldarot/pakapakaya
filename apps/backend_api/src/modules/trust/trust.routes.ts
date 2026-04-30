import { Router } from 'express';
import { z } from 'zod';

import { requireSessionUserId } from '../../shared/auth.js';
import {
  createTrustRequest,
  listPendingTrustRequests,
  reviewTrustRequest,
} from './trust.service.js';
import { readBody, readParams } from '../../shared/validation.js';

export const trustRouter = Router();

trustRouter.post('/requests', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  const body = readBody(
    z.object({
      vendorId: z.string().min(1),
    }),
    req,
    res,
  );
  if (!body) return;

  res.status(201).json(await createTrustRequest(body.vendorId, userId));
});

trustRouter.get('/requests', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  const result = await listPendingTrustRequests(userId);
  if ('error' in result && result.error === 'forbidden') {
    res.status(403).json({ error: 'Only vendors can view trust requests' });
    return;
  }

  res.json(result.trusts);
});

trustRouter.patch('/requests/:vendorId/:userId', async (req, res) => {
  const sessionUserId = await requireSessionUserId(req, res);
  if (!sessionUserId) return;

  const params = readParams(
    z.object({
      vendorId: z.string().min(1),
      userId: z.string().min(1),
    }),
    req,
    res,
  );
  if (!params) return;

  const body = readBody(
    z.object({
      status: z.enum(['pending', 'approved', 'blocked']),
    }),
    req,
    res,
  );
  if (!body) return;

  const result = await reviewTrustRequest(params.vendorId, params.userId, body.status, sessionUserId);
  if ('error' in result && result.error === 'forbidden') {
    res.status(403).json({ error: 'Only the vendor who owns this storefront can review requests' });
    return;
  }

  res.json(result.trust);
});
