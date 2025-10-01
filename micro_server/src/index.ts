import app from "./app";
import { config } from "./config";
// import { logger } from './config/logger';
import prisma from "./config/database";

const startServer = async () => {
  try {
    // Test database connection
    await prisma.$connect();
    console.log("Database connected successfully");

    const server = app.listen(config.port, () => {
      console.log(
        `Server running on port ${config.port} in ${config.nodeEnv} mode`
      );
    });

    // Graceful shutdown
    process.on("SIGTERM", async () => {
      console.log("SIGTERM received, shutting down gracefully");
      server.close(() => {
        console.log("Process terminated");
      });
    });

    process.on("SIGINT", async () => {
      console.log("SIGINT received, shutting down gracefully");
      await prisma.$disconnect();
      server.close(() => {
        console.log("Process terminated");
      });
    });
  } catch (error) {
    console.error("Error starting server:", error);
    process.exit(1);
  }
};

startServer();
