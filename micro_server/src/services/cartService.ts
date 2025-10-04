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
    // Use a transaction to make concurrent add operations safe and rollback on stock overflow
    return await prisma.$transaction(async (tx) => {
      // Ensure product exists and get stock
      const product = await tx.product.findUnique({
        where: { id: data.productId },
        select: { stock: true },
      });

      if (!product) {
        throw new AppError("Product not found", 404);
      }

      // Ensure the user has a cart (create if missing) using the same transaction
      let cart = await tx.cart.findFirst({ where: { userId } });
      if (!cart) {
        cart = await tx.cart.create({ data: { userId } });
      }

      // Try to increment existing cart item quantity; if not found, create; if create races, retry update
      let item: CartItem | null = null;
      try {
        item = await tx.cartItem.update({
          where: {
            cartId_productId: {
              cartId: cart.id,
              productId: data.productId,
            },
          },
          data: { quantity: { increment: data.quantity } },
          include: {
            product: { include: { category: true } },
          },
        });
      } catch (e: any) {
        // Record not found error code P2025 => create new item
        if (e?.code === "P2025") {
          try {
            item = await tx.cartItem.create({
              data: {
                cartId: cart.id,
                productId: data.productId,
                quantity: data.quantity,
              },
              include: {
                product: { include: { category: true } },
              },
            });
          } catch (e2: any) {
            // Unique constraint (another concurrent created) => retry update
            if (e2?.code === "P2002") {
              item = await tx.cartItem.update({
                where: {
                  cartId_productId: {
                    cartId: cart.id,
                    productId: data.productId,
                  },
                },
                data: { quantity: { increment: data.quantity } },
                include: {
                  product: { include: { category: true } },
                },
              });
            } else {
              throw e2;
            }
          }
        } else {
          throw e;
        }
      }

      // At this point, item is non-null; validate against stock. If invalid, throw to rollback.
      if (!item) {
        throw new AppError("Failed to add item to cart", 500);
      }

      if (item.quantity > product.stock) {
        // Exceeds stock; rollback transaction by throwing
        throw new AppError("Insufficient stock", 400);
      }

      return item;
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
      include: {
        product: {
          include: {
            category: true,
          },
        },
      },
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
