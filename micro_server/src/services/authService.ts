import { Role, User } from "@prisma/client";
import prisma from "../config/database";
import { comparePassword, generateToken, hashPassword } from "../utils/auth";
import { AppError } from "../utils/errors";

export interface CreateUserData {
  email: string;
  password: string;
  firstName?: string;
  lastName?: string;
  role?: Role;
}

export interface LoginData {
  email: string;
  password: string;
}

export interface UpdateProfileData {
  firstName?: string;
  lastName?: string;
}

export class AuthService {
  static async register(
    userData: CreateUserData
  ): Promise<{ user: Omit<User, "password">; token: string }> {
    const existingUser = await prisma.user.findUnique({
      where: { email: userData.email },
    });

    if (existingUser) {
      throw new AppError("User already exists with this email", 400);
    }

    const hashedPassword = await hashPassword(userData.password);

    const user = await prisma.user.create({
      data: {
        ...userData,
        password: hashedPassword,
      },
    });

    const token = generateToken({ id: user.id, email: user.email });

    const { password, ...userWithoutPassword } = user;

    return { user: userWithoutPassword, token };
  }

  static async login(
    loginData: LoginData
  ): Promise<{ user: Omit<User, "password">; token: string }> {
    const user = await prisma.user.findUnique({
      where: { email: loginData.email },
    });

    if (!user || !(await comparePassword(loginData.password, user.password))) {
      throw new AppError("Invalid email or password", 401);
    }

    const token = generateToken({ id: user.id, email: user.email });

    const { password, ...userWithoutPassword } = user;

    return { user: userWithoutPassword, token };
  }

  static async getUserById(id: string): Promise<Omit<User, "password"> | null> {
    const user = await prisma.user.findUnique({
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

    return user;
  }

  static async updateProfile(
    id: string,
    updateData: UpdateProfileData
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
}
