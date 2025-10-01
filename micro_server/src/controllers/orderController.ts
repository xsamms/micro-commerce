import { NextFunction, Request, Response } from "express";
import { OrderService } from "../services/orderService";
import { ApiResponse, AuthenticatedRequest } from "../types";

export class OrderController {
  static async createOrder(
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const userId = req.user!.id;
      const order = await OrderService.createOrder(userId);

      const response: ApiResponse = {
        success: true,
        data: order,
        message: "Order created successfully",
      };

      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async getUserOrders(
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const userId = req.user!.id;
      const orders = await OrderService.getUserOrders(userId);

      const response: ApiResponse = {
        success: true,
        data: orders,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async getOrderById(
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = (req as any).params;
      const userId = req.user!.role === "ADMIN" ? undefined : req.user!.id;

      const order = await OrderService.getOrderById(id, userId);

      if (!order) {
        res.status(404).json({
          success: false,
          message: "Order not found",
        });
        return;
      }

      const response: ApiResponse = {
        success: true,
        data: order,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async updateOrderStatus(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      const { status } = req.body;

      if (!id) {
        res.status(400).json({
          success: false,
          message: "Order ID is required",
        });
        return;
      }

      const order = await OrderService.updateOrderStatus(id, status);

      const response: ApiResponse = {
        success: true,
        data: order,
        message: "Order status updated",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async getAllOrders(
    _req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const orders = await OrderService.getAllOrders();

      const response: ApiResponse = {
        success: true,
        data: orders,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
