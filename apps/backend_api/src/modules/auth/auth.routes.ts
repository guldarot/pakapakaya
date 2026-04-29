import { Router } from 'express';
import { z } from 'zod';

import { requireSessionUserId } from '../../shared/auth.js';
import { loginWithDemoOtp, logoutSession, refreshSession } from './auth.service.js';
import { readBody } from '../../shared/validation.js';

export const authRouter = Router();

authRouter.post('/otp/login', async (req, res) => {
  const body = readBody(
    z.object({
      phone: z.string().min(5),
      otpCode: z.string().min(4),
    }),
    req,
    res,
  );
  if (!body) return;

  try {
    res.json(await loginWithDemoOtp(body.phone));
  } catch (error) {
    res.status(404).json({ error: error instanceof Error ? error.message : 'Login failed' });
  }
});

authRouter.post('/session/refresh', async (req, res) => {
  const userId = await requireSessionUserId(req, res);
  if (!userId) return;

  const authHeader = req.header('authorization')!;
  const token = authHeader.split(' ')[1];

  try {
    res.json(await refreshSession(token));
  } catch (error) {
    res.status(401).json({ error: error instanceof Error ? error.message : 'Refresh failed' });
  }
});

authRouter.post('/logout', async (req, res) => {
  const authHeader = req.header('authorization');
  const token = authHeader?.split(' ')[1];
  if (token) {
    await logoutSession(token);
  }
  res.status(204).send();
});
