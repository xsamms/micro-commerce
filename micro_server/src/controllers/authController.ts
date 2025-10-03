import { NextFunction, Request, Response } from "express";
import { AuthService } from "../services/authService";
import { ApiResponse } from "../types";

export class AuthController {
  static async register(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await AuthService.register(req.body);

      const response: ApiResponse = {
        success: true,
        data: result,
        message: "User registered successfully",
      };

      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async login(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await AuthService.login(req.body);

      const response: ApiResponse = {
        success: true,
        data: result,
        message: "Login successful",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async getProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.id;
      const user = await AuthService.getUserById(userId);

      const response: ApiResponse = {
        success: true,
        data: user,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user.id;
      const updateData = req.body;

      const user = await AuthService.updateProfile(userId, updateData);

      const response: ApiResponse = {
        success: true,
        data: user,
        message: "Profile updated successfully",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
