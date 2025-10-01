import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { config } from "../config";

export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, 12);
};

export const comparePassword = async (
  password: string,
  hashedPassword: string
): Promise<boolean> => {
  return bcrypt.compare(password, hashedPassword);
};

export const generateToken = (payload: object): string => {
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn as any,
  });
};

export const verifyToken = (token: string): jwt.JwtPayload | string => {
  return jwt.verify(token, config.jwt.secret as string);
};
