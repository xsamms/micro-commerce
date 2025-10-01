import { Role, User } from "@prisma/client";
import prisma from "../config/database";
import { AppError } from "../utils/errors";

export interface UpdateUserData {
  firstName?: string;
  lastName?: string;
  role?: Role;
}

export class UserService {
  static async getAllUsers(): Promise<Omit<User, "password">[]> {
    return await prisma.user.findMany({
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: { createdAt: "desc" },
    });
  }

  static async getUserById(id: string): Promise<Omit<User, "password"> | null> {
    return await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  static async updateUser(
    id: string,
    updateData: UpdateUserData
  ): Promise<Omit<User, "password">> {
    const user = await prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      throw new AppError("User not found", 404);
    }

    return await prisma.user.update({
      where: { id },
      data: updateData,
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  static async deleteUser(id: string): Promise<void> {
    const user = await prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      throw new AppError("User not found", 404);
    }

    // Don't allow deletion of admin users (safety measure)
    if (user.role === "ADMIN") {
      throw new AppError("Cannot delete admin users", 403);
    }

    await prisma.user.delete({
      where: { id },
    });
  }

  static async updateUserRole(
    id: string,
    role: Role
  ): Promise<Omit<User, "password">> {
    const user = await prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      throw new AppError("User not found", 404);
    }

    return await prisma.user.update({
      where: { id },
      data: { role },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }
}
