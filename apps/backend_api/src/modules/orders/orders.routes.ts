import { Router } from 'express';
import { z } from 'zod';

import { requireSessionUserId } from '../../shared/auth.js';
import {
  createOrderForBuyer,
  getOrderForBuyer,
  listOrdersForBuyer,
  uploadPaymentProofForBuyer,
} from './orders.service.js';
import { readBody, readParams } from '../../shared/validation.js';

export const ordersRouter = Router();

ordersRouter.get('/', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  res.json(await listOrdersForBuyer(userId));
});

ordersRouter.post('/', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  const body = readBody(
    z.object({
      batchId: z.string().min(1),
      quantity: z.number().int().min(1).max(20),
      logisticsMode: z.enum(['pickup', 'delivery']),
      isByob: z.boolean(),
    }),
    req,
    res,
  );
  if (!body) return;

  res.status(201).json(
    await createOrderForBuyer({
      buyerId: userId,
      batchId: body.batchId,
      quantity: body.quantity,
      logisticsMode: body.logisticsMode,
      isByob: body.isByob,
    }),
  );
});

ordersRouter.get('/:orderId', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  const params = readParams(
    z.object({
      orderId: z.string().min(1),
    }),
    req,
    res,
  );
  if (!params) return;

  const result = await getOrderForBuyer(params.orderId, userId);
  if ('error' in result && result.error === 'not-found') {
    res.status(404).json({ error: 'Order not found' });
    return;
  }
  if ('error' in result && result.error === 'forbidden') {
    res.status(403).json({ error: 'Forbidden' });
    return;
  }

  res.json(result.order);
});

ordersRouter.post('/:orderId/payment-proof', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  const params = readParams(
    z.object({
      orderId: z.string().min(1),
    }),
    req,
    res,
  );
  if (!params) return;

  const body = readBody(
    z.object({
      assetPath: z.string().min(1),
    }),
    req,
    res,
  );
  if (!body) return;

  const result = await uploadPaymentProofForBuyer(params.orderId, userId, body.assetPath);
  if ('error' in result && result.error === 'not-found') {
    res.status(404).json({ error: 'Order not found' });
    return;
  }
  if ('error' in result && result.error === 'forbidden') {
    res.status(403).json({ error: 'Forbidden' });
    return;
  }
  res.json(result.order);
});
