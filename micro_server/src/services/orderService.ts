import { Order, OrderStatus } from "@prisma/client";
import prisma from "../config/database";
import { AppError } from "../utils/errors";
import { CartService } from "./cartService";

export class OrderService {
  static async createOrder(userId: string): Promise<Order> {
    // Get user's cart
    const cart = await CartService.getOrCreateCart(userId);

    if (cart.items.length === 0) {
      throw new AppError("Cart is empty", 400);
    }

    // Validate stock for all items
    for (const item of cart.items) {
      if (item.product.stock < item.quantity) {
        throw new AppError(`Insufficient stock for ${item.product.name}`, 400);
      }
    }

    // Calculate total
    const total = await CartService.getCartTotal(userId);

    // Create order with transaction
    const order = await prisma.$transaction(async (tx) => {
      // Create order
      const newOrder = await tx.order.create({
        data: {
          userId,
          total,
          status: OrderStatus.PENDING,
        },
      });

      // Create order items and update product stock
      for (const item of cart.items) {
        await tx.orderItem.create({
          data: {
            orderId: newOrder.id,
            productId: item.productId,
            quantity: item.quantity,
            price: item.product.price,
          },
        });

        // Update product stock
        await tx.product.update({
          where: { id: item.productId },
          data: {
            stock: {
              decrement: item.quantity,
            },
          },
        });
      }

      // Clear cart
      await tx.cartItem.deleteMany({
        where: { cartId: cart.id },
      });

      return newOrder;
    });

    return order;
  }

  static async getUserOrders(userId: string): Promise<Order[]> {
    return await prisma.order.findMany({
      where: { userId },
      include: {
        items: {
          include: {
            product: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });
  }

  static async getOrderById(
    orderId: string,
    userId?: string
  ): Promise<Order | null> {
    const where: any = { id: orderId };
    if (userId) {
      where.userId = userId;
    }

    return await prisma.order.findFirst({
      where,
      include: {
        items: {
          include: {
            product: true,
          },
        },
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });
  }

  static async updateOrderStatus(
    orderId: string,
    status: OrderStatus
  ): Promise<Order> {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
    });

    if (!order) {
      throw new AppError("Order not found", 404);
    }

    return await prisma.order.update({
      where: { id: orderId },
      data: { status },
    });
  }

  static async getAllOrders(): Promise<Order[]> {
    return await prisma.order.findMany({
      include: {
        items: {
          include: {
            product: true,
          },
        },
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });
  }
}
