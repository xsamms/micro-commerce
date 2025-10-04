import request from "supertest";
import app from "../app";
import { generateToken, hashPassword } from "../utils/auth";
import { cleanDatabase, prisma } from "./setup";

describe("Order Tests", () => {
  let userToken: string;
  let adminToken: string;
  let userId: string;
  let productId: string;
  let categoryId: string;

  beforeEach(async () => {
    await cleanDatabase();

    // Create test user with properly hashed password
    const hashedUserPassword = await hashPassword("user123");
    const user = await prisma.user.create({
      data: {
        email: "orders-user@example.com",
        password: hashedUserPassword,
        firstName: "Test",
        lastName: "User",
        role: "USER",
      },
    });
    userId = user.id;
    userToken = generateToken({ id: user.id, email: user.email });

    // Create admin user with properly hashed password
    const hashedAdminPassword = await hashPassword("admin123");
    const admin = await prisma.user.create({
      data: {
        email: "orders-admin@example.com",
        password: hashedAdminPassword,
        firstName: "Admin",
        lastName: "User",
        role: "ADMIN",
      },
    });
    adminToken = generateToken({ id: admin.id, email: admin.email });

    // Create test category and product
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

  describe("POST /api/orders", () => {
    beforeEach(async () => {
      // Add item to cart
      await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send({
          productId,
          quantity: 2,
        });
    });

    it("should create order from cart", async () => {
      const response = await request(app)
        .post("/api/orders")
        .set("Authorization", `Bearer ${userToken}`)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe("PENDING");
      expect(response.body.data.items).toHaveLength(1);
      expect(response.body.data.items[0].quantity).toBe(2);
      expect(parseFloat(response.body.data.total)).toBe(199.98);

      // Verify cart is cleared after order creation
      const cartResponse = await request(app)
        .get("/api/cart")
        .set("Authorization", `Bearer ${userToken}`);

      expect(cartResponse.body.data.items).toHaveLength(0);
    });

    it("should fail with empty cart", async () => {
      // Clear cart first
      await request(app)
        .delete("/api/cart")
        .set("Authorization", `Bearer ${userToken}`);

      const response = await request(app)
        .post("/api/orders")
        .set("Authorization", `Bearer ${userToken}`)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("empty");
    });

    it("should fail without authentication", async () => {
      const response = await request(app).post("/api/orders").expect(401);

      expect(response.body.success).toBe(false);
    });

    it("should handle insufficient stock during order creation", async () => {
      // Update product stock to less than cart quantity
      await prisma.product.update({
        where: { id: productId },
        data: { stock: 1 },
      });

      const response = await request(app)
        .post("/api/orders")
        .set("Authorization", `Bearer ${userToken}`)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("stock");
    });
  });

  describe("GET /api/orders", () => {
    let orderId: string;

    beforeEach(async () => {
      // Create test order
      const order = await prisma.order.create({
        data: {
          userId,
          status: "PENDING",
          total: 199.98,
          items: {
            create: {
              productId,
              quantity: 2,
              price: 99.99,
            },
          },
        },
      });
      orderId = order.id;
    });

    it("should get user orders", async () => {
      const response = await request(app)
        .get("/api/orders")
        .set("Authorization", `Bearer ${userToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].id).toBe(orderId);
      expect(response.body.data[0].items).toHaveLength(1);
    });

    it("should fail without authentication", async () => {
      const response = await request(app).get("/api/orders").expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe("GET /api/orders/:id", () => {
    let orderId: string;

    beforeEach(async () => {
      const order = await prisma.order.create({
        data: {
          userId,
          status: "PENDING",
          total: 199.98,
          items: {
            create: {
              productId,
              quantity: 2,
              price: 99.99,
            },
          },
        },
      });
      orderId = order.id;
    });

    it("should get order details", async () => {
      const response = await request(app)
        .get(`/api/orders/${orderId}`)
        .set("Authorization", `Bearer ${userToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(orderId);
      expect(response.body.data.items).toHaveLength(1);
      expect(parseFloat(response.body.data.total)).toBe(199.98);
    });

    it("should fail for non-existent order", async () => {
      const fakeId = "00000000-0000-0000-0000-000000000000";
      const response = await request(app)
        .get(`/api/orders/${fakeId}`)
        .set("Authorization", `Bearer ${userToken}`)
        .expect(404);

      expect(response.body.success).toBe(false);
    });

    it("should fail when accessing another user's order", async () => {
      // Create another user with properly hashed password
      const hashedOtherPassword = await hashPassword("other123");
      const otherUser = await prisma.user.create({
        data: {
          email: "orders-other@example.com",
          password: hashedOtherPassword,
          firstName: "Other",
          lastName: "User",
          role: "USER",
        },
      });
      const otherToken = generateToken({
        id: otherUser.id,
        email: otherUser.email,
      });

      const response = await request(app)
        .get(`/api/orders/${orderId}`)
        .set("Authorization", `Bearer ${otherToken}`)
        .expect(404);

      expect(response.body.success).toBe(false);
    });
  });

  describe("PUT /api/orders/:id/status (Admin)", () => {
    let orderId: string;

    beforeEach(async () => {
      const order = await prisma.order.create({
        data: {
          userId,
          status: "PENDING",
          total: 199.98,
          items: {
            create: {
              productId,
              quantity: 2,
              price: 99.99,
            },
          },
        },
      });
      orderId = order.id;
    });

    it("should update order status as admin", async () => {
      const response = await request(app)
        .put(`/api/orders/${orderId}/status`)
        .set("Authorization", `Bearer ${adminToken}`)
        .send({ status: "SHIPPED" })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe("SHIPPED");
    });

    it("should fail as regular user", async () => {
      const response = await request(app)
        .put(`/api/orders/${orderId}/status`)
        .set("Authorization", `Bearer ${userToken}`)
        .send({ status: "SHIPPED" })
        .expect(403);

      expect(response.body.success).toBe(false);
    });

    it("should fail with invalid status", async () => {
      const response = await request(app)
        .put(`/api/orders/${orderId}/status`)
        .set("Authorization", `Bearer ${adminToken}`)
        .send({ status: "INVALID_STATUS" })
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe("GET /api/orders/admin/all (Admin)", () => {
    beforeEach(async () => {
      // Create multiple orders for different users
      await prisma.order.create({
        data: {
          userId,
          status: "PENDING",
          total: 199.98,
          items: {
            create: {
              productId,
              quantity: 2,
              price: 99.99,
            },
          },
        },
      });
    });

    it("should get all orders as admin", async () => {
      const response = await request(app)
        .get("/api/orders/admin/all")
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].user).toBeDefined();
    });

    it("should fail as regular user", async () => {
      const response = await request(app)
        .get("/api/orders/admin/all")
        .set("Authorization", `Bearer ${userToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
    });
  });
});
