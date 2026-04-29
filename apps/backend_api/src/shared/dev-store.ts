import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { buildStubTrust } from './stub-data.js';

type StoredOrder = Record<string, unknown>;
type StoredMessage = Record<string, unknown>;
type StoredTrust = Record<string, unknown>;

type DevStoreShape = {
  orders: Record<string, StoredOrder>;
  messagesByOrderId: Record<string, StoredMessage[]>;
  trusts: StoredTrust[];
  sessions: Record<string, string>;
};

const __dirname = dirname(fileURLToPath(import.meta.url));
const storePath = resolve(__dirname, '../../data/dev-store.json');

function defaultStore(): DevStoreShape {
  return {
    orders: {},
    messagesByOrderId: {},
    trusts: [
      buildStubTrust({
        vendorId: 'vendor-1',
        userId: 'user-buyer',
        status: 'approved',
      }),
    ],
    sessions: {},
  };
}

function ensureStoreFile() {
  if (!existsSync(storePath)) {
    mkdirSync(dirname(storePath), { recursive: true });
    writeFileSync(storePath, JSON.stringify(defaultStore(), null, 2), 'utf8');
  }
}

function readStore(): DevStoreShape {
  ensureStoreFile();
  return JSON.parse(readFileSync(storePath, 'utf8')) as DevStoreShape;
}

function writeStore(store: DevStoreShape) {
  writeFileSync(storePath, JSON.stringify(store, null, 2), 'utf8');
}

export function listOrders(): StoredOrder[] {
  return Object.values(readStore().orders);
}

export function getOrder(orderId: string): StoredOrder | null {
  return readStore().orders[orderId] ?? null;
}

export function saveOrder(orderId: string, order: StoredOrder): StoredOrder {
  const store = readStore();
  store.orders[orderId] = order;
  writeStore(store);
  return order;
}

export function nextOrderId(): string {
  return `order-${Object.keys(readStore().orders).length + 1}`;
}

export function getMessages(orderId: string): StoredMessage[] {
  return readStore().messagesByOrderId[orderId] ?? [];
}

export function saveMessages(orderId: string, messages: StoredMessage[]) {
  const store = readStore();
  store.messagesByOrderId[orderId] = messages;
  writeStore(store);
}

export function appendMessage(orderId: string, message: StoredMessage): StoredMessage {
  const messages = getMessages(orderId);
  messages.push(message);
  saveMessages(orderId, messages);
  return message;
}

export function listTrusts(): StoredTrust[] {
  return readStore().trusts;
}

export function saveTrust(trust: StoredTrust): StoredTrust {
  const store = readStore();
  const vendorId = String(trust.vendorId ?? '');
  const userId = String(trust.userId ?? '');
  const index = store.trusts.findIndex(
    (item) => item.vendorId === vendorId && item.userId === userId,
  );

  if (index >= 0) {
    store.trusts[index] = trust;
  } else {
    store.trusts.push(trust);
  }

  writeStore(store);
  return trust;
}

export function getTrust(vendorId: string, userId: string): StoredTrust | null {
  return (
    readStore().trusts.find((item) => item.vendorId === vendorId && item.userId === userId) ??
    null
  );
}

export function saveSession(token: string, userId: string) {
  const store = readStore();
  store.sessions[token] = userId;
  writeStore(store);
}

export function getUserIdForSession(token: string): string | null {
  return readStore().sessions[token] ?? null;
}

export function deleteSession(token: string) {
  const store = readStore();
  delete store.sessions[token];
  writeStore(store);
}
