import { Router } from 'express';
import { z } from 'zod';

import { requireSessionUserId } from '../../shared/auth.js';
import {
  createOrderForBuyer,
  getOrderForParticipant,
  listOrdersForBuyer,
  listOrdersForVendorUser,
  preparePaymentProofUploadForBuyer,
  updateOrderStatusForVendorUser,
  uploadPaymentProofForBuyer,
} from './orders.service.js';
import { readBody, readParams } from '../../shared/validation.js';

export const ordersRouter = Router();

ordersRouter.get('/', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  res.json(await listOrdersForBuyer(userId));
});

ordersRouter.get('/vendor', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  const result = await listOrdersForVendorUser(userId);
  if ('error' in result && result.error === 'forbidden') {
    res.status(403).json({ error: 'Only vendors can view vendor order queues' });
    return;
  }

  res.json(result.orders);
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

  const result = await getOrderForParticipant(params.orderId, userId);
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

ordersRouter.post('/:orderId/payment-proof/prepare', async (req, res) => {
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
      fileName: z.string().min(1),
      contentType: z.string().min(1),
    }),
    req,
    res,
  );
  if (!body) return;

  const result = await preparePaymentProofUploadForBuyer({
    orderId: params.orderId,
    buyerId: userId,
    fileName: body.fileName,
    contentType: body.contentType,
  });
  if ('error' in result && result.error === 'not-found') {
    res.status(404).json({ error: 'Order not found' });
    return;
  }
  if ('error' in result && result.error === 'forbidden') {
    res.status(403).json({ error: 'Forbidden' });
    return;
  }
  if (!('upload' in result)) {
    res.status(500).json({ error: 'Upload preparation failed' });
    return;
  }

  res.status(201).json(result.upload);
});

ordersRouter.patch('/:orderId/vendor-status', async (req, res) => {
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
      status: z.enum(['confirmed', 'ready', 'completed']),
    }),
    req,
    res,
  );
  if (!body) return;

  const result = await updateOrderStatusForVendorUser({
    orderId: params.orderId,
    vendorUserId: userId,
    nextStatus: body.status,
  });

  if ('error' in result && result.error === 'not-found') {
    res.status(404).json({ error: 'Order not found' });
    return;
  }
  if ('error' in result && result.error === 'forbidden') {
    res.status(403).json({ error: 'Only the vendor who owns this order can update it' });
    return;
  }
  if ('error' in result && result.error === 'invalid-transition') {
    res.status(409).json({ error: 'Order cannot move to that status from its current state' });
    return;
  }

  res.json(result.order);
});
