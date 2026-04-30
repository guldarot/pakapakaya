import { Request, Response } from 'express';

import { env } from '../config/env.js';
import { getUserIdForSession } from './dev-store.js';
import { sendError } from './http.js';
import { prisma } from './prisma.js';

function readBearerToken(req: Request): string | null {
  const authHeader = req.header('authorization');
  if (!authHeader) {
    return null;
  }

  const [scheme, token] = authHeader.split(' ');
  if (scheme?.toLowerCase() !== 'bearer' || !token) {
    return null;
  }

  return token;
}

export async function getSessionUserId(token: string): Promise<string | null> {
  if (env.PERSISTENCE_MODE === 'prisma') {
    const session = await prisma.devSession.findUnique({
      where: { token },
      select: { userId: true },
    });
    return session?.userId ?? null;
  }

  return getUserIdForSession(token);
}

export async function requireSessionUserId(req: Request, res: Response): Promise<string | null> {
  const token = readBearerToken(req);
  if (!token) {
    sendError(res, 401, 'Missing bearer token');
    return null;
  }

  const userId = await getSessionUserId(token);
  if (!userId) {
    sendError(res, 401, 'Invalid or expired session');
    return null;
  }

  return userId;
}
