import { env } from '../../../config/env.js';
import { ensureDemoData } from '../../../shared/demo-bootstrap.js';
import {
  appendMessage,
  getMessages,
  getOrder,
  listOrders,
  nextOrderId,
  saveMessages,
  saveOrder,
} from '../../../shared/dev-store.js';
import { presentOrder } from '../../../shared/prisma-presenters.js';
import { prisma } from '../../../shared/prisma.js';
import { buildStubOrder } from '../../../shared/stub-data.js';

export type CreateOrderInput = {
  buyerId: string;
  batchId: string;
  quantity: number;
  logisticsMode: 'pickup' | 'delivery';
  isByob: boolean;
};

export interface OrdersRepository {
  listForBuyer(userId: string): Promise<Record<string, unknown>[]>;
  listForVendorUser(vendorUserId: string): Promise<{ orders?: Record<string, unknown>[]; error?: 'forbidden' }>;
  createForBuyer(input: CreateOrderInput): Promise<Record<string, unknown>>;
  getForBuyer(orderId: string, buyerId: string): Promise<{ order?: Record<string, unknown>; error?: 'not-found' | 'forbidden' }>;
  getForParticipant(
    orderId: string,
    userId: string,
  ): Promise<{ order?: Record<string, unknown>; error?: 'not-found' | 'forbidden' }>;
  updateStatusForVendorUser(input: {
    orderId: string;
    vendorUserId: string;
    nextStatus: 'confirmed' | 'ready' | 'completed';
  }): Promise<{ order?: Record<string, unknown>; error?: 'not-found' | 'forbidden' | 'invalid-transition' }>;
  uploadPaymentProofForBuyer(
    orderId: string,
    buyerId: string,
    assetPath: string,
  ): Promise<{ order?: Record<string, unknown>; error?: 'not-found' | 'forbidden' }>;
}

class DevStoreOrdersRepository implements OrdersRepository {
  async listForBuyer(userId: string) {
    return listOrders()
      .filter((order) => order.buyerId === userId)
      .map((order) => buildStubOrder(order));
  }

  async listForVendorUser(vendorUserId: string) {
    if (vendorUserId !== 'user-vendor') {
      return { error: 'forbidden' as const };
    }

    return {
      orders: listOrders()
          .filter((order) => order.vendorId === 'vendor-1')
          .map((order) => buildStubOrder(order)),
    };
  }

  async createForBuyer(input: CreateOrderInput) {
    const packagingFeeSnapshot = input.isByob ? 0 : 40;
    const orderId = nextOrderId();
    const orderState = {
      id: orderId,
      batchId: input.batchId,
      buyerId: input.buyerId,
      logisticsMode: input.logisticsMode,
      isByob: input.isByob,
      quantity: input.quantity,
      packagingFeeSnapshot,
      totalAmount: input.quantity * (420 + packagingFeeSnapshot),
      batch: {
        ...buildStubOrder().batch,
        id: input.batchId,
      },
    };
    saveOrder(orderId, orderState);
    saveMessages(orderId, [
      {
        id: `message-${orderId}-1`,
        roomId: `room-${orderId}`,
        senderId: 'user-vendor',
        type: 'system',
        content: 'Order created. Upload payment proof to continue.',
        deliveryState: 'delivered',
        createdAt: new Date().toISOString(),
      },
    ]);

    return buildStubOrder(orderState);
  }

  async getForBuyer(orderId: string, buyerId: string) {
    const order = getOrder(orderId);
    if (!order) return { error: 'not-found' as const };
    if (order.buyerId !== buyerId) return { error: 'forbidden' as const };
    return { order: buildStubOrder(order) };
  }

  async getForParticipant(orderId: string, userId: string) {
    const order = getOrder(orderId);
    if (!order) return { error: 'not-found' as const };
    if (order.buyerId != userId && order.vendorId != 'vendor-1') return { error: 'forbidden' as const };
    if (order.vendorId == 'vendor-1' && userId == 'user-vendor') {
      return { order: buildStubOrder(order) };
    }
    if (order.buyerId === userId) {
      return { order: buildStubOrder(order) };
    }
    return { error: 'forbidden' as const };
  }

  async uploadPaymentProofForBuyer(orderId: string, buyerId: string, assetPath: string) {
    const order = getOrder(orderId);
    if (!order) return { error: 'not-found' as const };
    if (order.buyerId !== buyerId) return { error: 'forbidden' as const };

    const updatedState = {
      ...order,
      id: orderId,
      paymentStatus: 'uploaded',
      paymentScreenshotUrl: assetPath,
      status: 'verification',
    };
    saveOrder(orderId, updatedState);
    appendMessage(orderId, {
      id: `message-${orderId}-${getMessages(orderId).length + 1}`,
      roomId: `room-${orderId}`,
      senderId: buyerId,
      type: 'image',
      content: assetPath,
      metadata: { kind: 'paymentProof' },
      deliveryState: 'sent',
      createdAt: new Date().toISOString(),
    });

    return { order: buildStubOrder(updatedState) };
  }

  async updateStatusForVendorUser(input: {
    orderId: string;
    vendorUserId: string;
    nextStatus: 'confirmed' | 'ready' | 'completed';
  }) {
    const order = getOrder(input.orderId);
    if (!order) return { error: 'not-found' as const };
    if (input.vendorUserId !== 'user-vendor') return { error: 'forbidden' as const };

    const allowedTransitions: Record<string, string> = {
      verification: 'confirmed',
      confirmed: 'ready',
      ready: 'completed',
    };
    const currentStatus = typeof order.status === 'string' ? order.status : '';
    if (allowedTransitions[currentStatus] !== input.nextStatus) {
      return { error: 'invalid-transition' as const };
    }
    const currentPaymentStatus =
      typeof order.paymentStatus === 'string' ? order.paymentStatus : 'pending';

    const updatedState = {
      ...order,
      status: input.nextStatus,
      paymentStatus: input.nextStatus === 'confirmed' ? 'confirmed' : currentPaymentStatus,
    };
    saveOrder(input.orderId, updatedState);

    return { order: buildStubOrder(updatedState) };
  }
}

class PrismaOrdersRepository implements OrdersRepository {
  async listForBuyer(userId: string) {
    await ensureDemoData();
    const orders = await prisma.order.findMany({
      where: { buyerId: userId },
      orderBy: { createdAt: 'desc' },
      include: {
        batch: {
          include: {
            item: true,
          },
        },
      },
    });
    return orders.map((order: (typeof orders)[number]) => presentOrder(order));
  }

  async listForVendorUser(vendorUserId: string) {
    await ensureDemoData();
    const vendor = await prisma.vendorProfile.findUnique({
      where: { userId: vendorUserId },
      select: { id: true },
    });
    if (!vendor) {
      return { error: 'forbidden' as const };
    }

    const orders = await prisma.order.findMany({
      where: { vendorId: vendor.id },
      orderBy: { createdAt: 'desc' },
      include: {
        batch: {
          include: {
            item: true,
          },
        },
      },
    });
    return { orders: orders.map((order: (typeof orders)[number]) => presentOrder(order)) };
  }

  async createForBuyer(input: CreateOrderInput) {
    await ensureDemoData();
    const createdOrder = await prisma.$transaction(async (tx: any) => {
      const batch = await tx.batch.findUnique({
        where: { id: input.batchId },
        include: {
          item: {
            include: {
              vendor: true,
            },
          },
        },
      });
      if (!batch || !batch.item?.vendor) {
        throw new Error('Batch not found');
      }
      if (batch.remainingQuantity < input.quantity) {
        throw new Error('Batch sold out');
      }

      const updated = await tx.batch.updateMany({
        where: {
          id: input.batchId,
          remainingQuantity: { gte: input.quantity },
        },
        data: {
          remainingQuantity: {
            decrement: input.quantity,
          },
        },
      });
      if (updated.count === 0) {
        throw new Error('Batch sold out');
      }

      const packagingFeeSnapshot = input.isByob ? 0 : batch.item.vendor.packagingCost;
      const order = await tx.order.create({
        data: {
          batchId: batch.id,
          buyerId: input.buyerId,
          vendorId: batch.item.vendor.id,
          status: 'PENDING_PAYMENT',
          logisticsMode: input.logisticsMode === 'delivery' ? 'DELIVERY' : 'PICKUP',
          isByob: input.isByob,
          quantity: input.quantity,
          unitPriceSnapshot: batch.item.basePrice,
          packagingFeeSnapshot,
          totalAmount: input.quantity * (batch.item.basePrice + packagingFeeSnapshot),
          paymentStatus: 'PENDING',
          chatRoom: {
            create: {
              vendorId: batch.item.vendor.id,
              buyerId: input.buyerId,
            },
          },
        },
        include: {
          batch: {
            include: {
              item: true,
            },
          },
          chatRoom: true,
        },
      });

      await tx.message.create({
        data: {
          roomId: order.chatRoom!.id,
          senderId: batch.item.vendor.userId,
          type: 'SYSTEM',
          content: 'Order created. Upload payment proof to continue.',
          deliveryState: 'DELIVERED',
        },
      });

      return order;
    });

    const hydrated = await prisma.order.findUniqueOrThrow({
      where: { id: createdOrder.id },
      include: {
        batch: {
          include: {
            item: true,
          },
        },
      },
    });

    return presentOrder(hydrated);
  }

  async getForBuyer(orderId: string, buyerId: string) {
    await ensureDemoData();
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        batch: {
          include: {
            item: true,
          },
        },
      },
    });
    if (!order) return { error: 'not-found' as const };
    if (order.buyerId !== buyerId) return { error: 'forbidden' as const };
    return { order: presentOrder(order) };
  }

  async getForParticipant(orderId: string, userId: string) {
    await ensureDemoData();
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        vendor: true,
        batch: {
          include: {
            item: true,
          },
        },
      },
    });
    if (!order) return { error: 'not-found' as const };
    if (order.buyerId !== userId && order.vendor.userId !== userId) return { error: 'forbidden' as const };
    return { order: presentOrder(order) };
  }

  async uploadPaymentProofForBuyer(orderId: string, buyerId: string, assetPath: string) {
    await ensureDemoData();
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        chatRoom: true,
        batch: {
          include: {
            item: true,
          },
        },
      },
    });
    if (!order) return { error: 'not-found' as const };
    if (order.buyerId !== buyerId) return { error: 'forbidden' as const };

    const updated = await prisma.$transaction(async (tx: any) => {
      const savedOrder = await tx.order.update({
        where: { id: orderId },
        data: {
          paymentScreenshotUrl: assetPath,
          paymentStatus: 'UPLOADED',
          status: 'VERIFICATION',
        },
        include: {
          batch: {
            include: {
              item: true,
            },
          },
          chatRoom: true,
        },
      });

      const roomId = savedOrder.chatRoom?.id;
      if (roomId) {
        await tx.message.create({
          data: {
            roomId,
            senderId: buyerId,
            type: 'IMAGE',
            content: assetPath,
            metadata: { kind: 'paymentProof' },
            deliveryState: 'SENT',
          },
        });
      }

      return savedOrder;
    });

    return { order: presentOrder(updated) };
  }

  async updateStatusForVendorUser(input: {
    orderId: string;
    vendorUserId: string;
    nextStatus: 'confirmed' | 'ready' | 'completed';
  }) {
    await ensureDemoData();
    const order = await prisma.order.findUnique({
      where: { id: input.orderId },
      include: {
        vendor: true,
        batch: {
          include: {
            item: true,
          },
        },
      },
    });
    if (!order) return { error: 'not-found' as const };
    if (order.vendor.userId !== input.vendorUserId) return { error: 'forbidden' as const };

    const allowedTransitions: Record<string, 'CONFIRMED' | 'READY' | 'COMPLETED'> = {
      VERIFICATION: 'CONFIRMED',
      CONFIRMED: 'READY',
      READY: 'COMPLETED',
    };
    const targetStatus = input.nextStatus.toUpperCase() as 'CONFIRMED' | 'READY' | 'COMPLETED';
    if (allowedTransitions[order.status] !== targetStatus) {
      return { error: 'invalid-transition' as const };
    }

    const updated = await prisma.order.update({
      where: { id: input.orderId },
      data: {
        status: targetStatus,
        paymentStatus: targetStatus === 'CONFIRMED' ? 'CONFIRMED' : order.paymentStatus,
      },
      include: {
        batch: {
          include: {
            item: true,
          },
        },
      },
    });

    return { order: presentOrder(updated) };
  }
}

export function getOrdersRepository(): OrdersRepository {
  return env.PERSISTENCE_MODE === 'prisma'
    ? new PrismaOrdersRepository()
    : new DevStoreOrdersRepository();
}
