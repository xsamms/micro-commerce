import request from "supertest";
import app from "../app";
import { generateToken, hashPassword } from "../utils/auth";
import { cleanDatabase, prisma } from "./setup";

describe("Product CRUD Tests", () => {
  let adminToken: string;
  let userToken: string;
  let categoryId: string;

  beforeEach(async () => {
    await cleanDatabase();

    // Create admin user with properly hashed password
    const hashedAdminPassword = await hashPassword("admin123");
    const adminUser = await prisma.user.create({
      data: {
        email: "products-admin@example.com",
        password: hashedAdminPassword,
        firstName: "Admin",
        lastName: "User",
        role: "ADMIN",
      },
    });
    adminToken = generateToken({ id: adminUser.id, email: adminUser.email });

    // Create regular user with properly hashed password
    const hashedUserPassword = await hashPassword("user123");
    const regularUser = await prisma.user.create({
      data: {
        email: "products-user@example.com",
        password: hashedUserPassword,
        firstName: "Regular",
        lastName: "User",
        role: "USER",
      },
    });
    userToken = generateToken({ id: regularUser.id, email: regularUser.email });

    // Create test category
    const category = await prisma.category.create({
      data: {
        name: "Electronics",
        description: "Electronic devices",
      },
    });
    categoryId = category.id;
  });

  afterAll(async () => {
    await cleanDatabase();
    await prisma.$disconnect();
  });

  describe("GET /api/products", () => {
    beforeEach(async () => {
      // Create test products
      await prisma.product.createMany({
        data: [
          {
            name: "Laptop",
            description: "Gaming laptop",
            price: 999.99,
            stock: 10,
            categoryId,
          },
          {
            name: "Mouse",
            description: "Wireless mouse",
            price: 29.99,
            stock: 50,
            categoryId,
          },
        ],
      });
    });

    it("should get all products", async () => {
      const response = await request(app).get("/api/products").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.data).toHaveLength(2);
      expect(response.body.data.data[0]).toHaveProperty("name");
      expect(response.body.data.data[0]).toHaveProperty("price");
      expect(response.body.data.data[0]).toHaveProperty("category");
    });

    it("should filter products by category", async () => {
      const response = await request(app)
        .get(`/api/products?category=${categoryId}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.data).toHaveLength(2);
    });

    it("should paginate products", async () => {
      const response = await request(app)
        .get("/api/products?page=1&limit=1")
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.data).toHaveLength(1);
      expect(response.body.data.pagination.totalPages).toBe(2);
    });
  });

  describe("GET /api/products/:id", () => {
    let productId: string;

    beforeEach(async () => {
      const product = await prisma.product.create({
        data: {
          name: "Test Product",
          description: "A test product",
          price: 99.99,
          stock: 5,
          categoryId,
        },
      });
      productId = product.id;
    });

    it("should get product by ID", async () => {
      const response = await request(app)
        .get(`/api/products/${productId}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(productId);
      expect(response.body.data.name).toBe("Test Product");
      expect(response.body.data.category).toBeDefined();
    });

    it("should return 404 for non-existent product", async () => {
      const fakeId = "00000000-0000-0000-0000-000000000000";
      const response = await request(app)
        .get(`/api/products/${fakeId}`)
        .expect(404);

      expect(response.body.success).toBe(false);
    });
  });

  describe("POST /api/products", () => {
    const productData = {
      name: "New Product",
      description: "A new product",
      price: 49.99,
      stock: 20,
      categoryId: "", // Will be set in beforeEach
    };

    beforeEach(() => {
      productData.categoryId = categoryId;
    });

    it("should create product as admin", async () => {
      const response = await request(app)
        .post("/api/products")
        .set("Authorization", `Bearer ${adminToken}`)
        .send(productData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(productData.name);
      expect(parseFloat(response.body.data.price)).toBe(productData.price);
    });

    it("should fail to create product as regular user", async () => {
      const response = await request(app)
        .post("/api/products")
        .set("Authorization", `Bearer ${userToken}`)
        .send(productData)
        .expect(403);

      expect(response.body.success).toBe(false);
    });

    it("should fail without authentication", async () => {
      const response = await request(app)
        .post("/api/products")
        .send(productData)
        .expect(401);

      expect(response.body.success).toBe(false);
    });

    it("should fail with invalid category", async () => {
      const invalidData = {
        ...productData,
        categoryId: "invalid-category-id",
      };

      const response = await request(app)
        .post("/api/products")
        .set("Authorization", `Bearer ${adminToken}`)
        .send(invalidData)
        .expect(404);

      expect(response.body.success).toBe(false);
    });
  });

  describe("PUT /api/products/:id", () => {
    let productId: string;

    beforeEach(async () => {
      const product = await prisma.product.create({
        data: {
          name: "Original Product",
          description: "Original description",
          price: 99.99,
          stock: 10,
          categoryId,
        },
      });
      productId = product.id;
    });

    it("should update product as admin", async () => {
      const updateData = {
        name: "Updated Product",
        price: 149.99,
      };

      const response = await request(app)
        .put(`/api/products/${productId}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(updateData.name);
      expect(parseFloat(response.body.data.price)).toBe(updateData.price);
    });

    it("should fail to update as regular user", async () => {
      const updateData = { name: "Hacked Product" };

      const response = await request(app)
        .put(`/api/products/${productId}`)
        .set("Authorization", `Bearer ${userToken}`)
        .send(updateData)
        .expect(403);

      expect(response.body.success).toBe(false);
    });
  });

  describe("DELETE /api/products/:id", () => {
    let productId: string;

    beforeEach(async () => {
      const product = await prisma.product.create({
        data: {
          name: "Product to Delete",
          description: "Will be deleted",
          price: 99.99,
          stock: 10,
          categoryId,
        },
      });
      productId = product.id;
    });

    it("should delete product as admin", async () => {
      const response = await request(app)
        .delete(`/api/products/${productId}`)
        .set("Authorization", `Bearer ${adminToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);

      // Verify product is deleted
      await request(app).get(`/api/products/${productId}`).expect(404);
    });

    it("should fail to delete as regular user", async () => {
      const response = await request(app)
        .delete(`/api/products/${productId}`)
        .set("Authorization", `Bearer ${userToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
    });
  });
});
