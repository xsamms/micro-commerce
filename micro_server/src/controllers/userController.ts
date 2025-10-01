import { NextFunction, Request, Response } from "express";
import { UserService } from "../services/userService";
import { ApiResponse } from "../types";

export class UserController {
  static async getAllUsers(
    _req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const users = await UserService.getAllUsers();

      const response: ApiResponse = {
        success: true,
        data: users,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async getUserById(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;

      if (!id) {
        res.status(400).json({
          success: false,
          message: "User ID is required",
        });
        return;
      }

      const user = await UserService.getUserById(id);

      if (!user) {
        res.status(404).json({
          success: false,
          message: "User not found",
        });
        return;
      }

      const response: ApiResponse = {
        success: true,
        data: user,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async updateUser(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      const updateData = req.body;

      if (!id) {
        res.status(400).json({
          success: false,
          message: "User ID is required",
        });
        return;
      }

      const user = await UserService.updateUser(id, updateData);

      const response: ApiResponse = {
        success: true,
        data: user,
        message: "User updated successfully",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async deleteUser(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;

      if (!id) {
        res.status(400).json({
          success: false,
          message: "User ID is required",
        });
        return;
      }

      await UserService.deleteUser(id);

      const response: ApiResponse = {
        success: true,
        message: "User deleted successfully",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async updateUserRole(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      const { role } = req.body;

      if (!id) {
        res.status(400).json({
          success: false,
          message: "User ID is required",
        });
        return;
      }

      if (!role || !["USER", "ADMIN"].includes(role)) {
        res.status(400).json({
          success: false,
          message: "Invalid role. Must be USER or ADMIN",
        });
        return;
      }

      const user = await UserService.updateUserRole(id, role);

      const response: ApiResponse = {
        success: true,
        data: user,
        message: "User role updated successfully",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
