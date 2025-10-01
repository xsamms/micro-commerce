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
}
