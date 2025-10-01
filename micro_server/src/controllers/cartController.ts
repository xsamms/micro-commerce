import { NextFunction, Response } from "express";
import { CartService } from "../services/cartService";
import { ApiResponse, AuthenticatedRequest } from "../types";

export class CartController {
  static async getCart(
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const userId = req.user!.id;
      const cart = await CartService.getOrCreateCart(userId);
      const total = await CartService.getCartTotal(userId);

      const response: ApiResponse = {
        success: true,
        data: { ...cart, total },
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async addToCart(
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const userId = req.user!.id;
      const cartItem = await CartService.addToCart(userId, req.body);

      const response: ApiResponse = {
        success: true,
        data: cartItem,
        message: "Item added to cart",
      };

      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async updateCartItem(
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const userId = req.user!.id;
      const { itemId } = req.params;
      const { quantity } = req.body;

      if (!itemId) {
        res.status(400).json({
          success: false,
          message: "Item ID is required",
        });
        return;
      }

      const cartItem = await CartService.updateCartItem(
        userId,
        itemId,
        quantity
      );

      const response: ApiResponse = {
        success: true,
        data: cartItem,
        message: "Cart item updated",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async removeFromCart(
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const userId = req.user!.id;
      const { itemId } = req.params;

      if (!itemId) {
        res.status(400).json({
          success: false,
          message: "Item ID is required",
        });
        return;
      }

      await CartService.removeFromCart(userId, itemId);

      const response: ApiResponse = {
        success: true,
        message: "Item removed from cart",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async clearCart(
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const userId = req.user!.id;

      await CartService.clearCart(userId);

      const response: ApiResponse = {
        success: true,
        message: "Cart cleared",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
