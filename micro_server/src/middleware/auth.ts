import { NextFunction, Response } from "express";
import jwt from "jsonwebtoken";
import { config } from "../config";
import prisma from "../config/database";
import { AuthenticatedRequest } from "../types";
import { AppError } from "../utils/errors";

export const authenticateToken = (
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "");

    if (!token) {
      return next(new AppError("Access denied. No token provided.", 401));
    }

    const decoded = jwt.verify(token, config.jwt.secret) as any;
    req.user = decoded;
    next();
  } catch (error) {
    next(new AppError("Invalid token.", 401));
  }
};

export const authenticate = async (
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "");

    if (!token) {
      return next(new AppError("Access denied. No token provided.", 401));
    }

    const decoded = jwt.verify(token, config.jwt.secret) as any;
    const user = await prisma.user.findUnique({
      where: { id: decoded.id },
      select: { id: true, email: true, role: true },
    });

    if (!user) {
      return next(new AppError("Invalid token.", 401));
    }

    req.user = user;
    next();
  } catch (error) {
    next(new AppError("Invalid token.", 401));
  }
};

export const requireRole = (roles: string[]) => {
  return (req: AuthenticatedRequest, _res: Response, next: NextFunction) => {
    const userRole = req.user?.role;

    if (!userRole || !roles.includes(userRole)) {
      return next(
        new AppError("Access denied. Insufficient permissions.", 403)
      );
    }

    next();
  };
};
