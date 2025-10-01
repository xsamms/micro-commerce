import { PrismaClient } from "@prisma/client";

const testDatabaseUrl =
  process.env["TEST_DATABASE_URL"] || process.env["DATABASE_URL"] || "";

const prisma = new PrismaClient(
  testDatabaseUrl
    ? {
        datasources: {
          db: {
            url: testDatabaseUrl,
          },
        },
      }
    : undefined
);

// Mock data for testing
export const mockUser = {
  email: "test@example.com",
  password: "password123",
  firstName: "Test",
  lastName: "User",
  role: "USER",
};

export const mockProduct = {
  name: "Test Product",
  description: "A test product",
  price: 29.99,
  stock: 100,
  categoryId: 1,
};

export const cleanDatabase = async () => {
  await prisma.$transaction([
    prisma.orderItem.deleteMany(),
    prisma.order.deleteMany(),
    prisma.cartItem.deleteMany(),
    prisma.cart.deleteMany(),
    prisma.product.deleteMany(),
    prisma.category.deleteMany(),
    prisma.user.deleteMany(),
  ]);
};

export const setupTests = async () => {
  // Setup test database
};

export const teardownTests = async () => {
  await prisma.$disconnect();
};

export { prisma };
