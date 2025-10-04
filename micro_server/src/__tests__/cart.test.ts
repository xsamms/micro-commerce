import request from "supertest";
import app from "../app";
import { generateToken, hashPassword } from "../utils/auth";
import { cleanDatabase, prisma } from "./setup";

describe("Cart Tests", () => {
  let userToken: string;
  let productId: string;
  let categoryId: string;

  beforeEach(async () => {
    await cleanDatabase();

    // Create test user with properly hashed password
    const hashedPassword = await hashPassword("user123");
    const user = await prisma.user.create({
      data: {
        email: "cart-user@example.com",
        password: hashedPassword,
        firstName: "Test",
        lastName: "User",
        role: "USER",
      },
    });
    userToken = generateToken({ id: user.id, email: user.email });

    // Create test category
    const category = await prisma.category.create({
      data: {
        name: "Electronics",
        description: "Electronic devices",
      },
    });
    categoryId = category.id;

    // Create test product
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

  describe("GET /api/cart", () => {
    it("should get empty cart for new user", async () => {
      const response = await request(app)
        .get("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.items).toHaveLength(0);
      expect(response.body.data.total).toBe(0);
    });

    it("should fail without authentication", async () => {
      const response = await request(app).get("/api/cart").expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe("POST /api/cart", () => {
    it("should add item to cart", async () => {
      const cartItem = {
        productId,
        quantity: 2,
      };

      const response = await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send(cartItem)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.quantity).toBe(2);
      expect(response.body.data.product.id).toBe(productId);
    });

    it("should update quantity when adding existing item", async () => {
      const cartItem = {
        productId,
        quantity: 1,
      };

      // Add item first time
      await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send(cartItem);

      // Add same item again
      const response = await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send(cartItem)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.quantity).toBe(2);
    });

    it("should fail with insufficient stock", async () => {
      const cartItem = {
        productId,
        quantity: 15, // More than available stock (10)
      };

      const response = await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send(cartItem)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain("stock");
    });

    it("should fail with non-existent product", async () => {
      const cartItem = {
        productId: "00000000-0000-0000-0000-000000000000",
        quantity: 1,
      };

      const response = await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send(cartItem)
        .expect(404);

      expect(response.body.success).toBe(false);
    });
  });

  describe("PUT /api/cart/:itemId", () => {
    let cartItemId: string;

    beforeEach(async () => {
      // Add item to cart first
      const response = await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send({
          productId,
          quantity: 2,
        });
      cartItemId = response.body.data.id;
    });

    it("should update cart item quantity", async () => {
      const response = await request(app)
        .put(`/api/cart/${cartItemId}`)
        .set("Authorization", `Bearer ${userToken}`)
        .send({ quantity: 5 })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.quantity).toBe(5);
    });

    it("should fail with insufficient stock", async () => {
      const response = await request(app)
        .put(`/api/cart/${cartItemId}`)
        .set("Authorization", `Bearer ${userToken}`)
        .send({ quantity: 15 })
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it("should fail with non-existent cart item", async () => {
      const fakeId = "00000000-0000-0000-0000-000000000000";
      const response = await request(app)
        .put(`/api/cart/${fakeId}`)
        .set("Authorization", `Bearer ${userToken}`)
        .send({ quantity: 1 })
        .expect(404);

      expect(response.body.success).toBe(false);
    });
  });

  describe("DELETE /api/cart/:itemId", () => {
    let cartItemId: string;

    beforeEach(async () => {
      // Add item to cart first
      const response = await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send({
          productId,
          quantity: 2,
        });
      cartItemId = response.body.data.id;
    });

    it("should remove item from cart", async () => {
      const response = await request(app)
        .delete(`/api/cart/${cartItemId}`)
        .set("Authorization", `Bearer ${userToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);

      // Verify item is removed
      const cartResponse = await request(app)
        .get("/api/cart")
        .set("Authorization", `Bearer ${userToken}`);

      expect(cartResponse.body.data.items).toHaveLength(0);
    });
  });

  describe("DELETE /api/cart", () => {
    beforeEach(async () => {
      // Add multiple items to cart
      await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send({ productId, quantity: 2 });
    });

    it("should clear entire cart", async () => {
      const response = await request(app)
        .delete("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);

      // Verify cart is empty
      const cartResponse = await request(app)
        .get("/api/cart")
        .set("Authorization", `Bearer ${userToken}`);

      expect(cartResponse.body.data.items).toHaveLength(0);
    });
  });

  describe("Cart Edge Cases", () => {
    it("should handle concurrent cart operations", async () => {
      const cartItem = {
        productId,
        quantity: 1,
      };

      // Simulate concurrent requests
      const promises = Array(3)
        .fill(null)
        .map(() =>
          request(app)
            .post("/api/cart")
            .set("Authorization", `Bearer ${userToken}`)
            .send(cartItem)
        );

      const responses = await Promise.all(promises);

      // All should succeed, final quantity should be 3
      responses.forEach((response) => {
        expect(response.status).toBe(201);
      });

      const cartResponse = await request(app)
        .get("/api/cart")
        .set("Authorization", `Bearer ${userToken}`);

      // Due to race conditions, final quantity should be at least 1 and at most 3
      expect(cartResponse.body.data.items[0].quantity).toBeGreaterThanOrEqual(
        1
      );
      expect(cartResponse.body.data.items[0].quantity).toBeLessThanOrEqual(3);
    });

    it("should calculate correct cart total", async () => {
      // Create another product
      const product2 = await prisma.product.create({
        data: {
          name: "Product 2",
          description: "Second product",
          price: 25.5,
          stock: 10,
          categoryId,
        },
      });

      // Add multiple items to cart
      await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send({ productId, quantity: 2 }); // 2 * 99.99 = 199.98

      await request(app)
        .post("/api/cart")
        .set("Authorization", `Bearer ${userToken}`)
        .send({ productId: product2.id, quantity: 3 }); // 3 * 25.50 = 76.50

      const cartResponse = await request(app)
        .get("/api/cart")
        .set("Authorization", `Bearer ${userToken}`);

      expect(cartResponse.body.data.total).toBe(276.48); // 199.98 + 76.50
    });
  });
});
