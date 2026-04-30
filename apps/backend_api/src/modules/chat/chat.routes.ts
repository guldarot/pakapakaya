import { Router } from 'express';
import { z } from 'zod';

import { requireSessionUserId } from '../../shared/auth.js';
import { listMessagesForParticipant, sendMessageForParticipant } from './chat.service.js';
import { readBody, readParams } from '../../shared/validation.js';

export const chatRouter = Router();

chatRouter.get('/orders/:orderId/messages', async (req, res) => {
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

  const result = await listMessagesForParticipant(params.orderId, userId);
  if ('error' in result && result.error === 'not-found') {
    res.status(404).json({ error: 'Order not found' });
    return;
  }
  if ('error' in result && result.error === 'forbidden') {
    res.status(403).json({ error: 'Forbidden' });
    return;
  }

  res.json(result.messages);
});

chatRouter.post('/orders/:orderId/messages', async (req, res) => {
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
      type: z.enum(['text', 'image', 'audio', 'offer', 'system']),
      content: z.string().min(1),
      metadata: z.record(z.any()).optional(),
    }),
    req,
    res,
  );
  if (!body) return;

  const result = await sendMessageForParticipant({
    orderId: params.orderId,
    userId: userId,
    type: body.type,
    content: body.content,
    metadata: body.metadata,
  });
  if ('error' in result && result.error === 'not-found') {
    res.status(404).json({ error: 'Order not found' });
    return;
  }
  if ('error' in result && result.error === 'forbidden') {
    res.status(403).json({ error: 'Forbidden' });
    return;
  }

  res.status(201).json(result.message);
});
