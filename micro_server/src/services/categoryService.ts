import { Category } from "@prisma/client";
import prisma from "../config/database";
import { AppError } from "../utils/errors";

export interface CreateCategoryData {
  name: string;
  description?: string;
}

export interface UpdateCategoryData {
  name?: string;
  description?: string;
}

export class CategoryService {
  static async createCategory(
    categoryData: CreateCategoryData
  ): Promise<Category> {
    // Check if category name already exists
    const existingCategory = await prisma.category.findUnique({
      where: { name: categoryData.name },
    });

    if (existingCategory) {
      throw new AppError("Category with this name already exists", 400);
    }

    const category = await prisma.category.create({
      data: categoryData,
    });

    return category;
  }

  static async getCategories(): Promise<Category[]> {
    const categories = await prisma.category.findMany({
      orderBy: { name: "asc" },
    });

    return categories;
  }

  static async getCategoryById(id: string): Promise<Category | null> {
    const category = await prisma.category.findUnique({
      where: { id },
    });

    return category;
  }

  static async updateCategory(
    id: string,
    updateData: UpdateCategoryData
  ): Promise<Category> {
    const existingCategory = await prisma.category.findUnique({
      where: { id },
    });

    if (!existingCategory) {
      throw new AppError("Category not found", 404);
    }

    // Check if new name conflicts with existing category
    if (updateData.name) {
      const conflictingCategory = await prisma.category.findUnique({
        where: { name: updateData.name },
      });

      if (conflictingCategory && conflictingCategory.id !== id) {
        throw new AppError("Category with this name already exists", 400);
      }
    }

    const category = await prisma.category.update({
      where: { id },
      data: updateData,
    });

    return category;
  }

  static async deleteCategory(id: string): Promise<void> {
    const existingCategory = await prisma.category.findUnique({
      where: { id },
    });

    if (!existingCategory) {
      throw new AppError("Category not found", 404);
    }

    // Check if category has products
    const productsCount = await prisma.product.count({
      where: { categoryId: id },
    });

    if (productsCount > 0) {
      throw new AppError(
        "Cannot delete category that contains products. Move or delete products first.",
        400
      );
    }

    await prisma.category.delete({
      where: { id },
    });
  }
}
