import assert from 'node:assert/strict';
import { after, before, describe, test } from 'node:test';
import type { AddressInfo } from 'node:net';

import { buildApp } from '../app.js';
import { resetAndSeedDemoData } from '../shared/demo-bootstrap.js';
import { prisma } from '../shared/prisma.js';

type JsonRecord = Record<string, unknown>;
type SessionResponse = JsonRecord & {
  token: string;
  currentUser: JsonRecord & {
    id: string;
  };
};
type VendorResponse = JsonRecord & {
  id: string;
  storeName: string;
};
type VendorDetailResponse = JsonRecord & {
  trustStatus: string;
  batches: Array<JsonRecord & { id: string }>;
};
type OrderResponse = JsonRecord & {
  id: string;
  status: string;
  paymentStatus?: string;
};
type PreparedUploadResponse = JsonRecord & {
  method: string;
  assetPath: string;
};
type MessageResponse = JsonRecord & {
  type: string;
  senderId: string;
  content?: string;
};
type TrustResponse = JsonRecord & {
  vendorId: string;
  userId: string;
  status: string;
};
type ErrorResponse = JsonRecord & {
  error: string;
  requestId: string;
};

describe('buyer flow integration', () => {
  let baseUrl = '';
  let closeServer: (() => Promise<void>) | undefined;

  before(async () => {
    await resetAndSeedDemoData();

    const app = buildApp();
    const server = await new Promise<import('node:http').Server>((resolve) => {
      const instance = app.listen(0, () => resolve(instance));
    });
    const address = server.address() as AddressInfo;
    baseUrl = `http://127.0.0.1:${address.port}`;
    closeServer = async () =>
      await new Promise<void>((resolve, reject) => {
        server.close((error) => {
          if (error) {
            reject(error);
            return;
          }
          resolve();
        });
      });
  });

  after(async () => {
    if (closeServer) {
      await closeServer();
    }
    await prisma.$disconnect();
  });

  test('login, discovery, order, payment proof, and chat all work together', async () => {
    const session = await postJson<SessionResponse>('/v1/auth/otp/login', {
      phone: '+923001234567',
      otpCode: '1234',
    });
    const token = session.token;

    const vendors = await getJson<VendorResponse[]>('/v1/discovery/vendors?radiusKm=1', token);
    assert.ok(Array.isArray(vendors));
    assert.equal(vendors.length > 0, true);

    const vendor = vendors[0];
    assert.equal(vendor.storeName, 'Hina Kitchen');
    const vendorId = vendor.id;

    const vendorDetail = await getJson<VendorDetailResponse>(`/v1/vendors/${vendorId}`, token);
    assert.equal(vendorDetail.trustStatus, 'approved');

    const batches = vendorDetail.batches;
    assert.equal(Array.isArray(batches), true);
    assert.equal(batches.length > 0, true);
    const batchId = batches[0].id;

    const order = await postJson<OrderResponse>(
      '/v1/orders',
      {
        batchId,
        quantity: 1,
        logisticsMode: 'pickup',
        isByob: false,
      },
      token,
      201,
    );
    assert.equal(order.status, 'pendingPayment');
    const orderId = order.id;

    const upload = await postJson<PreparedUploadResponse>(
      `/v1/orders/${orderId}/payment-proof/prepare`,
      {
        fileName: 'proof.txt',
        contentType: 'text/plain',
      },
      token,
      201,
    );
    assert.equal(upload.method, 'PUT');

    const paidOrder = await postJson<OrderResponse>(
      `/v1/orders/${orderId}/payment-proof`,
      {
        assetPath: upload.assetPath,
      },
      token,
    );
    assert.equal(paidOrder.status, 'verification');
    assert.equal(paidOrder.paymentStatus, 'uploaded');

    const message = await postJson<MessageResponse>(
      `/v1/chat/orders/${orderId}/messages`,
      {
        type: 'text',
        content: 'Payment proof uploaded. Please confirm.',
      },
      token,
      201,
    );
    assert.equal(message.type, 'text');
    assert.equal(message.senderId, session.currentUser.id);

    const messages = await getJson<MessageResponse[]>(`/v1/chat/orders/${orderId}/messages`, token);
    assert.ok(Array.isArray(messages));
    assert.equal(messages.length >= 3, true);
    const latest = messages[messages.length - 1];
    assert.equal(latest.content, 'Payment proof uploaded. Please confirm.');

    const vendorSession = await postJson<SessionResponse>('/v1/auth/otp/login', {
      phone: '+923009876543',
      otpCode: '1234',
    });
    const vendorToken = vendorSession.token;

    const confirmedOrder = await patchJson<OrderResponse>(
      `/v1/orders/${orderId}/vendor-status`,
      { status: 'confirmed' },
      vendorToken,
    );
    assert.equal(confirmedOrder.status, 'confirmed');
    assert.equal(confirmedOrder.paymentStatus, 'confirmed');

    const vendorView = await getJson<OrderResponse>(`/v1/orders/${orderId}`, vendorToken);
    assert.equal(vendorView.status, 'confirmed');

    const vendorMessage = await postJson<MessageResponse>(
      `/v1/chat/orders/${orderId}/messages`,
      {
        type: 'text',
        content: 'Payment confirmed. We are cooking now.',
      },
      vendorToken,
      201,
    );
    assert.equal(vendorMessage.senderId, vendorSession.currentUser.id);

    const vendorMessages = await getJson<MessageResponse[]>(
      `/v1/chat/orders/${orderId}/messages`,
      vendorToken,
    );
    assert.equal(
      vendorMessages.some((message) => message.content == 'Payment confirmed. We are cooking now.'),
      true,
    );

    const readyOrder = await patchJson<OrderResponse>(
      `/v1/orders/${orderId}/vendor-status`,
      { status: 'ready' },
      vendorToken,
    );
    assert.equal(readyOrder.status, 'ready');

    const completedOrder = await patchJson<OrderResponse>(
      `/v1/orders/${orderId}/vendor-status`,
      { status: 'completed' },
      vendorToken,
    );
    assert.equal(completedOrder.status, 'completed');
  });

  test('health and readiness endpoints expose deployment-friendly status', async () => {
    const health = await getJson<JsonRecord>('/health');
    assert.equal(health.ok, true);
    assert.equal(health.service, 'pakapakaya-backend');
    assert.equal(health.version, '0.1.0');
    assert.equal(typeof health.revision, 'string');
    assert.equal(typeof health.requestId, 'string');

    const ready = await getJson<JsonRecord>('/ready');
    assert.equal(ready.ok, true);
    assert.equal(ready.service, 'pakapakaya-backend');
    assert.equal(ready.version, '0.1.0');
    assert.equal(ready.persistenceMode, 'prisma');
    assert.equal(typeof ready.requestId, 'string');

    const version = await getJson<JsonRecord>('/version');
    assert.equal(version.service, 'pakapakaya-backend');
    assert.equal(version.version, '0.1.0');
    assert.equal(typeof version.revision, 'string');
  });

  test('vendor can review a new trust request for their own storefront', async () => {
    await prisma.user.upsert({
      where: { phone: '+923221110000' },
      update: {
        name: 'Maha',
        role: 'USER',
        status: 'ACTIVE',
        trustScore: 85,
        codStrikeCount: 0,
      },
      create: {
        id: 'demo-second-buyer-user',
        phone: '+923221110000',
        name: 'Maha',
        role: 'USER',
        status: 'ACTIVE',
        trustScore: 85,
        codStrikeCount: 0,
      },
    });

    const requesterSession = await postJson<SessionResponse>('/v1/auth/otp/login', {
      phone: '+923221110000',
      otpCode: '1234',
    });
    const vendorSession = await postJson<SessionResponse>('/v1/auth/otp/login', {
      phone: '+923009876543',
      otpCode: '1234',
    });

    const vendors = await getJson<VendorResponse[]>('/v1/discovery/vendors?radiusKm=1', requesterSession.token);
    const vendorId = vendors[0].id;

    const createdTrust = await postJson<TrustResponse>(
      '/v1/trust/requests',
      { vendorId },
      requesterSession.token,
      201,
    );
    assert.equal(createdTrust.status, 'pending');

    const pendingTrusts = await getJson<TrustResponse[]>('/v1/trust/requests', vendorSession.token);
    const pendingTrust = pendingTrusts.find((item) => item.userId === requesterSession.currentUser.id);
    assert.ok(pendingTrust);
    assert.equal(pendingTrust?.status, 'pending');

    const approvedTrust = await patchJson<TrustResponse>(
      `/v1/trust/requests/${vendorId}/${requesterSession.currentUser.id}`,
      { status: 'approved' },
      vendorSession.token,
    );
    assert.equal(approvedTrust.status, 'approved');
  });

  test('protected routes reject missing auth, wrong role, and non-participants', async () => {
    const unauthenticatedDiscovery = await getJson<ErrorResponse>(
      '/v1/discovery/vendors?radiusKm=1',
      undefined,
      401,
    );
    assert.equal(unauthenticatedDiscovery.error, 'Missing bearer token');
    assert.equal(typeof unauthenticatedDiscovery.requestId, 'string');

    const invalidTokenResponse = await getJson<ErrorResponse>(
      '/v1/discovery/vendors?radiusKm=1',
      'invalid-token',
      401,
    );
    assert.equal(invalidTokenResponse.error, 'Invalid or expired session');
    assert.equal(typeof invalidTokenResponse.requestId, 'string');

    await prisma.user.upsert({
      where: { phone: '+923334440000' },
      update: {
        name: 'Sara',
        role: 'USER',
        status: 'ACTIVE',
        trustScore: 81,
        codStrikeCount: 0,
      },
      create: {
        id: 'demo-third-buyer-user',
        phone: '+923334440000',
        name: 'Sara',
        role: 'USER',
        status: 'ACTIVE',
        trustScore: 81,
        codStrikeCount: 0,
      },
    });

    const buyerSession = await postJson<SessionResponse>('/v1/auth/otp/login', {
      phone: '+923001234567',
      otpCode: '1234',
    });
    const secondBuyerSession = await postJson<SessionResponse>('/v1/auth/otp/login', {
      phone: '+923334440000',
      otpCode: '1234',
    });

    const vendors = await getJson<VendorResponse[]>('/v1/discovery/vendors?radiusKm=1', buyerSession.token);
    const vendorDetail = await getJson<VendorDetailResponse>(
      `/v1/vendors/${vendors[0].id}`,
      buyerSession.token,
    );
    const order = await postJson<OrderResponse>(
      '/v1/orders',
      {
        batchId: vendorDetail.batches[0].id,
        quantity: 1,
        logisticsMode: 'pickup',
        isByob: false,
      },
      buyerSession.token,
      201,
    );

    const wrongRoleTrusts = await getJson<ErrorResponse>('/v1/trust/requests', buyerSession.token, 403);
    assert.equal(wrongRoleTrusts.error, 'Only vendors can view trust requests');

    const strangerOrder = await getJson<ErrorResponse>(
      `/v1/orders/${order.id}`,
      secondBuyerSession.token,
      403,
    );
    assert.equal(strangerOrder.error, 'Forbidden');

    const strangerMessage = await postJson<ErrorResponse>(
      `/v1/chat/orders/${order.id}/messages`,
      {
        type: 'text',
        content: 'I should not be allowed here.',
      },
      secondBuyerSession.token,
      403,
    );
    assert.equal(strangerMessage.error, 'Forbidden');
  });

  async function getJson<T>(path: string, token?: string, expectedStatus = 200): Promise<T> {
    const response = await fetch(`${baseUrl}${path}`, {
      headers: token
        ? {
            authorization: `Bearer ${token}`,
          }
        : undefined,
    });
    if (response.status !== expectedStatus) {
      const body = await response.text();
      assert.fail(`Expected ${expectedStatus} from ${path}, got ${response.status}: ${body}`);
    }
    return (await response.json()) as T;
  }

  async function postJson<T>(
    path: string,
    body: JsonRecord,
    token?: string,
    expectedStatus = 200,
  ): Promise<T> {
    const response = await fetch(`${baseUrl}${path}`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        ...(token
          ? {
              authorization: `Bearer ${token}`,
            }
          : {}),
      },
      body: JSON.stringify(body),
    });
    if (response.status !== expectedStatus) {
      const responseBody = await response.text();
      assert.fail(`Expected ${expectedStatus} from ${path}, got ${response.status}: ${responseBody}`);
    }
    return (await response.json()) as T;
  }

  async function patchJson<T>(
    path: string,
    body: JsonRecord,
    token: string,
    expectedStatus = 200,
  ): Promise<T> {
    const response = await fetch(`${baseUrl}${path}`, {
      method: 'PATCH',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(body),
    });
    if (response.status !== expectedStatus) {
      const responseBody = await response.text();
      assert.fail(`Expected ${expectedStatus} from ${path}, got ${response.status}: ${responseBody}`);
    }
    return (await response.json()) as T;
  }
});
