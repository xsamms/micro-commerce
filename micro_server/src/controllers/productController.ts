import { NextFunction, Request, Response } from "express";
import { ProductService } from "../services/productService";
import { ApiResponse } from "../types";

export class ProductController {
  static async createProduct(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const product = await ProductService.createProduct(req.body);

      const response: ApiResponse = {
        success: true,
        data: product,
        message: "Product created successfully",
      };

      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async getProducts(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const {
        page = 1,
        limit = 10,
        category,
        search,
        minPrice,
        maxPrice,
      } = req.query as any;

      const filters: any = {};
      if (category) filters.category = category;
      if (search) filters.search = search;
      if (minPrice) filters.minPrice = parseFloat(minPrice);
      if (maxPrice) filters.maxPrice = parseFloat(maxPrice);

      const result = await ProductService.getProducts(
        parseInt(page),
        parseInt(limit),
        filters
      );

      const response: ApiResponse = {
        success: true,
        data: result,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async getProductById(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      if (!id) {
        res.status(400).json({
          success: false,
          message: "Product ID is required",
        });
        return;
      }
      const product = await ProductService.getProductById(id);

      if (!product) {
        res.status(404).json({
          success: false,
          message: "Product not found",
        });
        return;
      }

      const response: ApiResponse = {
        success: true,
        data: product,
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async updateProduct(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      if (!id) {
        res.status(400).json({
          success: false,
          message: "Product ID is required",
        });
        return;
      }
      const product = await ProductService.updateProduct(id, req.body);

      const response: ApiResponse = {
        success: true,
        data: product,
        message: "Product updated successfully",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  static async deleteProduct(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      if (!id) {
        res.status(400).json({
          success: false,
          message: "Product ID is required",
        });
        return;
      }
      await ProductService.deleteProduct(id);

      const response: ApiResponse = {
        success: true,
        message: "Product deleted successfully",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
