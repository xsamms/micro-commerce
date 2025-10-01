import dotenv from "dotenv";

dotenv.config();

export const config = {
  port: parseInt(process.env["PORT"] || "4500", 10),
  nodeEnv: process.env["NODE_ENV"] || "development",

  database: {
    url: process.env["DATABASE_URL"] || "",
  },

  jwt: {
    secret: process.env["JWT_SECRET"] || "fallback-secret-key",
    expiresIn: process.env["JWT_EXPIRES_IN"] || "7d",
  },

  cors: {
    origin: process.env["CORS_ORIGIN"] || "http://localhost:4500",
  },

  rateLimit: {
    windowMs: parseInt(process.env["RATE_LIMIT_WINDOW_MS"] || "900000", 10), // 15 minutes
    maxRequests: parseInt(process.env["RATE_LIMIT_MAX_REQUESTS"] || "100", 10),
  },
};
