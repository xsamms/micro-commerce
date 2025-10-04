import { PrismaClient } from "@prisma/client";

// SAFETY CHECK: Ensure we're in test environment
if (process.env["NODE_ENV"] !== "test") {
  throw new Error(
    "Tests can only be run in test environment! Set NODE_ENV=test or use npm test command."
  );
}

// SAFETY CHECK: Ensure we're using test database
const testDatabaseUrl =
  process.env["TEST_DATABASE_URL"] || process.env["DATABASE_URL"] || "";

if (!testDatabaseUrl.includes("test")) {
  throw new Error(
    'DANGER: Test database URL must contain "test" to prevent accidentally wiping production data!\n' +
      "Please set TEST_DATABASE_URL to a separate test database.\n" +
      "Current DATABASE_URL: " +
      testDatabaseUrl
  );
}

console.log(
  "🧪 Using test database:",
  testDatabaseUrl.replace(/\/\/.*@/, "//***:***@")
);

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: testDatabaseUrl,
    },
  },
});

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

// Clean ONLY the test database
export const cleanDatabase = async () => {
  // Double-check we're using test database before cleaning
  if (!testDatabaseUrl.includes("test")) {
    throw new Error(
      'SAFETY: Will not clean database that does not contain "test" in URL!'
    );
  }

  console.log("🧹 Cleaning test database...");

  try {
    await prisma.$transaction([
      prisma.orderItem.deleteMany(),
      prisma.order.deleteMany(),
      prisma.cartItem.deleteMany(),
      prisma.cart.deleteMany(),
      prisma.product.deleteMany(),
      prisma.category.deleteMany(),
      prisma.user.deleteMany(),
    ]);
    console.log("✅ Test database cleaned successfully");
  } catch (error) {
    console.error("❌ Error cleaning test database:", error);
    throw error;
  }
};

export const setupTests = async () => {
  // Setup test database
  console.log("🚀 Setting up tests...");
};

export const teardownTests = async () => {
  console.log("🔌 Disconnecting from test database...");
  await prisma.$disconnect();
};

export { prisma };
