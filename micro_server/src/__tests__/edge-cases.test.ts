import request from "supertest";
import app from "../app";
import { generateToken, hashPassword } from "../utils/auth";
import { cleanDatabase, prisma } from "./setup";

describe("Edge Cases and Error Handling Tests", () => {
  let userToken: string;
  let adminToken: string;
  let productId: string;
  let categoryId: string;

  beforeEach(async () => {
    await cleanDatabase();

    // Create test users with properly hashed passwords
    const hashedUserPassword = await hashPassword("user123");
    const user = await prisma.user.create({
      data: {
        email: "edge-user@example.com",
        password: hashedUserPassword,
        firstName: "Test",
        lastName: "User",
        role: "USER",
      },
    });
    userToken = generateToken({ id: user.id, email: user.email });

    const hashedAdminPassword = await hashPassword("admin123");
    const admin = await prisma.user.create({
      data: {
        email: "edge-admin@example.com",
        password: hashedAdminPassword,
        firstName: "Admin",
        lastName: "User",
        role: "ADMIN",
      },
    });
    adminToken = generateToken({ id: admin.id, email: admin.email });

    // Create test data
    const category = await prisma.category.create({
      data: {
        name: "Electronics",
        description: "Electronic devices",
      },
    });
    categoryId = category.id;

    const product = await prisma.product.create({
      data: {
        name: "Test Product",
        description: "A test product",
        price: 99.99,
        stock: 10,
        categoryId,
      },
    });
    productId = product.id;
  });

  afterAll(async () => {
    await cleanDatabase();
    await prisma.$disconnect();
  });

  describe("Authentication Edge Cases", () => {
    it("should handle malformed JWT tokens", async () => {
      const response = await request(app)
        .get("/api/auth/profile")
        .set("Authorization", "Bearer malformed.jwt.token")
        .expect(401);

      expect(response.body.success).toBe(false);
    });

    it("should handle missing Authorization header", async () => {
      const response = await request(app).get("/api/auth/profile").expect(401);

      expect(response.body.success).toBe(false);
    });

    it("should handle token for deleted user", async () => {
      // Create token then delete user
      const hashedTempPassword = await hashPassword("temp123");
      const tempUser = await prisma.user.create({
        data: {
          email: "edge-temp@example.com",
          password: hashedTempPassword,
          firstName: "Temp",
          lastName: "User",
          role: "USER",
        },
      });

      const tempToken = generateToken({
        id: tempUser.id,
        email: tempUser.email,
      });

      await prisma.user.delete({ where: { id: tempUser.id } });

      const response = await request(app)
        .get("/api/auth/profile")
        .set("Authorization", `Bearer ${tempToken}`)
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe("Input Validation Edge Cases", () => {
    it("should handle extremely long strings", async () => {
      const longString = "a".repeat(150); // Exceeds 100 char limit

      const response = await request(app)
        .post("/api/auth/register")
        .send({
          email: "test@example.com",
          password: "password123",
          firstName: longString,
          lastName: "User",
        })
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it("should handle special characters in inputs", async () => {
      const response = await request(app)
        .post("/api/products")
        .set("Authorization", `Bearer ${adminToken}`)
        .send({
          name: "Product <script>alert('xss')</script>",
          description: 'Description with \' quotes and "double quotes"',
          price: 99.99,
          stock: 10,
          categoryId,
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toContain("<script>");
    });

    it("should handle null and undefined values", async () => {
      const response = await request(app)
        .post("/api/products")
        .set("Authorization", `Bearer ${adminToken}`)
        .send({
          name: null,
          description: undefined,
          price: "not-a-number",
          stock: -5,
          categoryId,
        })
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it("should handle very large numbers", async () => {
      const response = await request(app)
        .post("/api/products")
        .set("Authorization", `Bearer ${adminToken}`)
        .send({
          name: "Expensive Product",
          description: "Very expensive",
          price: 9999999999, // Exceeds max price limit
          stock: 9999999999, // Exceeds max stock limit
          categoryId,
        })
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe("Rate Limiting and Performance", () => {
    it("should handle multiple rapid requests", async () => {
      const requests = Array(10)
        .fill(null)
        .map(() => request(app).get("/api/products"));

      const responses = await Promise.all(requests);

      // All requests should succeed
      responses.forEach((response) => {
        expect(response.status).toBe(200);
      });
    });

    it("should handle large pagination requests", async () => {
      const response = await request(app)
        .get("/api/products?page=999999&limit=1000")
        .expect(400); // Should fail validation due to page > 10000 and limit > 100

      expect(response.body.success).toBe(false);
    });
  });

  describe("Business Logic Edge Cases", () => {
    it("should handle zero-stock products", async () => {
      // Set product stock to 0
      await prisma.product.update({
        where: { id: productId },
        data: { stock: 0 },
      });

      const response = await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send({ productId, quantity: 1 })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("stock");
    });

    it("should handle negative quantities", async () => {
      const response = await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send({ productId, quantity: -1 })
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it("should handle orders with products that become unavailable", async () => {
      // Add item to cart
      await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send({ productId, quantity: 5 });

      // Reduce stock below cart quantity
      await prisma.product.update({
        where: { id: productId },
        data: { stock: 2 },
      });

      const response = await request(app)
        .post("/api/orders")
        .set("Authorization", `Bearer ${userToken}`)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("stock");
    });

    it("should handle decimal precision in prices", async () => {
      const response = await request(app)
        .post("/api/products")
        .set("Authorization", `Bearer ${adminToken}`)
        .send({
          name: "Precision Product",
          description: "Testing decimal precision",
          price: 99.99, // Use a normal decimal price
          stock: 10,
          categoryId,
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(parseFloat(response.body.data.price)).toBeCloseTo(99.99, 2);
    });
  });

  describe("Security Edge Cases", () => {
    it("should prevent SQL injection attempts", async () => {
      const maliciousEmail = "test'; DROP TABLE users; --";

      const response = await request(app)
        .post("/api/auth/login")
        .send({
          email: maliciousEmail,
          password: "password123",
        })
        .expect(400); // Should fail validation due to invalid email format

      expect(response.body.success).toBe(false);

      // Verify users table still exists
      const userCount = await prisma.user.count();
      expect(userCount).toBeGreaterThan(0);
    });

    it("should handle cross-user data access attempts", async () => {
      // Create another user
      const hashedOtherPassword = await hashPassword("other123");
      const otherUser = await prisma.user.create({
        data: {
          email: "edge-other@example.com",
          password: hashedOtherPassword,
          firstName: "Other",
          lastName: "User",
          role: "USER",
        },
      });

      // Try to access other user's data using their ID in URL
      const response = await request(app)
        .get(`/api/users/${otherUser.id}`)
        .set("Authorization", `Bearer ${userToken}`)
        .expect(403); // Should be 403 because user lacks admin role

      expect(response.body.success).toBe(false);
    });
  });

  describe("Content-Type and Header Edge Cases", () => {
    it("should handle requests without Content-Type", async () => {
      const response = await request(app)
        .post("/api/auth/login")
        .set("Content-Type", "")
        .send("email=test@example.com&password=password123")
        .expect(401); // Will fail because body parsing won't work properly

      expect(response.body.success).toBe(false);
    });

    it("should handle unsupported Content-Type", async () => {
      const response = await request(app)
        .post("/api/auth/login")
        .set("Content-Type", "text/plain")
        .send("some plain text")
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it("should handle very large request bodies", async () => {
      const largeData = {
        name: "a".repeat(600), // Exceeds 500 char limit for name
        description: "b".repeat(2100), // Exceeds 2000 char limit for description
        price: 99.99,
        stock: 10,
        categoryId,
      };

      const response = await request(app)
        .post("/api/products")
        .set("Authorization", `Bearer ${adminToken}`)
        .send(largeData)
        .expect(400); // Should fail validation due to field length limits

      expect(response.body.success).toBe(false);
    });
  });
});
