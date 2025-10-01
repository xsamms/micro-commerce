import { NextFunction, Request, Response } from "express";
import { CategoryService } from "../services/categoryService";
import { ApiResponse } from "../types";

export class CategoryController {
  static async createCategory(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const category = await CategoryService.createCategory(req.body);

      const response: ApiResponse = {
        success: true,
        data: category,
        message: "Category created successfully",
      };

      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async getCategories(
    _req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const categories = await CategoryService.getCategories();

      const response: ApiResponse = {
        success: true,
        data: categories,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async getCategoryById(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      if (!id) {
        res.status(400).json({
          success: false,
          message: "Category ID is required",
        });
        return;
      }

      const category = await CategoryService.getCategoryById(id);

      if (!category) {
        res.status(404).json({
          success: false,
          message: "Category not found",
        });
        return;
      }

      const response: ApiResponse = {
        success: true,
        data: category,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async updateCategory(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      if (!id) {
        res.status(400).json({
          success: false,
          message: "Category ID is required",
        });
        return;
      }

      const category = await CategoryService.updateCategory(id, req.body);

      const response: ApiResponse = {
        success: true,
        data: category,
        message: "Category updated successfully",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async deleteCategory(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      if (!id) {
        res.status(400).json({
          success: false,
          message: "Category ID is required",
        });
        return;
      }

      await CategoryService.deleteCategory(id);

      const response: ApiResponse = {
        success: true,
        message: "Category deleted successfully",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
