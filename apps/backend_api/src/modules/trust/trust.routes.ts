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

  res.json(await listPendingTrustRequests());
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

  res.json(await reviewTrustRequest(params.vendorId, params.userId, body.status));
});
