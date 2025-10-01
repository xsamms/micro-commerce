import { Cart, CartItem } from "@prisma/client";
import prisma from "../config/database";
import { AppError } from "../utils/errors";

export interface AddToCartData {
  productId: string;
  quantity: number;
}

export class CartService {
  static async getOrCreateCart(
    userId: string
  ): Promise<Cart & { items: (CartItem & { product: any })[] }> {
    let cart = await prisma.cart.findFirst({
      where: { userId },
      include: {
        items: {
          include: {
            product: {
              include: {
                category: true,
              },
            },
          },
        },
      },
    });

    if (!cart) {
      cart = await prisma.cart.create({
        data: { userId },
        include: {
          items: {
            include: {
              product: {
                include: {
                  category: true,
                },
              },
            },
          },
        },
      });
    }

    return cart;
  }

  static async addToCart(
    userId: string,
    data: AddToCartData
  ): Promise<CartItem> {
    // Check if product exists and has enough stock
    const product = await prisma.product.findUnique({
      where: { id: data.productId },
    });

    if (!product) {
      throw new AppError("Product not found", 404);
    }

    if (product.stock < data.quantity) {
      throw new AppError("Insufficient stock", 400);
    }

    const cart = await this.getOrCreateCart(userId);

    // Check if item already exists in cart
    const existingItem = await prisma.cartItem.findUnique({
      where: {
        cartId_productId: {
          cartId: cart.id,
          productId: data.productId,
        },
      },
    });

    if (existingItem) {
      const newQuantity = existingItem.quantity + data.quantity;

      if (product.stock < newQuantity) {
        throw new AppError("Insufficient stock", 400);
      }

      return await prisma.cartItem.update({
        where: { id: existingItem.id },
        data: { quantity: newQuantity },
      });
    }

    return await prisma.cartItem.create({
      data: {
        cartId: cart.id,
        productId: data.productId,
        quantity: data.quantity,
      },
    });
  }

  static async updateCartItem(
    userId: string,
    itemId: string,
    quantity: number
  ): Promise<CartItem> {
    const cartItem = await prisma.cartItem.findFirst({
      where: {
        id: itemId,
        cart: { userId },
      },
      include: {
        product: true,
      },
    });

    if (!cartItem) {
      throw new AppError("Cart item not found", 404);
    }

    if (cartItem.product.stock < quantity) {
      throw new AppError("Insufficient stock", 400);
    }

    return await prisma.cartItem.update({
      where: { id: itemId },
      data: { quantity },
    });
  }

  static async removeFromCart(userId: string, itemId: string): Promise<void> {
    const cartItem = await prisma.cartItem.findFirst({
      where: {
        id: itemId,
        cart: { userId },
      },
    });

    if (!cartItem) {
      throw new AppError("Cart item not found", 404);
    }

    await prisma.cartItem.delete({
      where: { id: itemId },
    });
  }

  static async clearCart(userId: string): Promise<void> {
    const cart = await prisma.cart.findFirst({
      where: { userId },
    });

    if (cart) {
      await prisma.cartItem.deleteMany({
        where: { cartId: cart.id },
      });
    }
  }

  static async getCartTotal(userId: string): Promise<number> {
    const cart = await this.getOrCreateCart(userId);

    let total = 0;
    for (const item of cart.items) {
      total += Number(item.product.price) * item.quantity;
    }

    return total;
  }
}
