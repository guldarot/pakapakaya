import { randomUUID } from 'node:crypto';

import { env } from '../../config/env.js';
import { ensureDemoData } from '../../shared/demo-bootstrap.js';
import { getSessionUserId } from '../../shared/auth.js';
import { deleteSession, getUserIdForSession, saveSession } from '../../shared/dev-store.js';
import { prisma } from '../../shared/prisma.js';
import { presentUser } from '../../shared/prisma-presenters.js';
import { stubSession, stubUsers } from '../../shared/stub-data.js';

export async function loginWithDemoOtp(phone: string) {
  if (env.PERSISTENCE_MODE === 'prisma') {
    await ensureDemoData();
    const user = await prisma.user.findUnique({
      where: { phone },
    });
    if (!user) {
      throw new Error('Demo user not found for phone number');
    }

    const token = `dev-${randomUUID()}`;
    await prisma.devSession.upsert({
      where: { token },
      update: { userId: user.id },
      create: {
        token,
        userId: user.id,
      },
    });

    return {
      ...stubSession,
      token,
      currentUser: presentUser(user),
    };
  }

  const user = stubUsers.find((item) => item.phone === phone);
  if (!user) {
    throw new Error('Demo user not found for phone number');
  }

  const token = `dev-${randomUUID()}`;
  saveSession(token, user.id);

  return {
    ...stubSession,
    token,
    currentUser: user,
  };
}

export async function refreshSession(token: string) {
  const userId = await getSessionUserId(token);
  if (!userId) {
    throw new Error('Invalid or expired session');
  }

  if (env.PERSISTENCE_MODE === 'prisma') {
    await ensureDemoData();
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) {
      throw new Error('User not found for session');
    }

    return {
      ...stubSession,
      token,
      currentUser: presentUser(user),
    };
  }

  const user = stubUsers.find((item) => item.id === userId);
  if (!user) {
    throw new Error('User not found for session');
  }

  return {
    ...stubSession,
    token,
    currentUser: user,
  };
}

export async function logoutSession(token: string) {
  if (env.PERSISTENCE_MODE === 'prisma') {
    await prisma.devSession.deleteMany({
      where: { token },
    });
    return;
  }

  deleteSession(token);
}
