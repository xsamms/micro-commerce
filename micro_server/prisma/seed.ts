import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("Seeding database...");

  // Create admin user
  const adminPassword = await bcrypt.hash("admin123", 12);
  await prisma.user.upsert({
    where: { email: "admin@example.com" },
    update: {},
    create: {
      email: "admin@example.com",
      password: adminPassword,
      firstName: "Admin",
      lastName: "User",
      role: "ADMIN",
    },
  });

  // Create regular user
  const userPassword = await bcrypt.hash("user123", 12);
  await prisma.user.upsert({
    where: { email: "user@example.com" },
    update: {},
    create: {
      email: "user@example.com",
      password: userPassword,
      firstName: "John",
      lastName: "Doe",
      role: "USER",
    },
  });

  // Create categories
  const electronics = await prisma.category.upsert({
    where: { name: "Electronics" },
    update: {},
    create: {
      name: "Electronics",
      description: "Electronic devices and gadgets",
    },
  });

  const clothing = await prisma.category.upsert({
    where: { name: "Clothing" },
    update: {},
    create: {
      name: "Clothing",
      description: "Fashion and apparel",
    },
  });

  const books = await prisma.category.upsert({
    where: { name: "Books" },
    update: {},
    create: {
      name: "Books",
      description: "Books and literature",
    },
  });

  // Create products
  const products = [
    {
      name: "Smartphone",
      description: "Latest model smartphone with advanced features",
      price: 699.99,
      stock: 50,
      categoryId: electronics.id,
      imageUrl: "https://via.placeholder.com/300x300?text=Smartphone",
    },
    {
      name: "Laptop",
      description: "High-performance laptop for work and gaming",
      price: 1299.99,
      stock: 25,
      categoryId: electronics.id,
      imageUrl: "https://via.placeholder.com/300x300?text=Laptop",
    },
    {
      name: "T-Shirt",
      description: "Comfortable cotton t-shirt",
      price: 19.99,
      stock: 100,
      categoryId: clothing.id,
      imageUrl: "https://via.placeholder.com/300x300?text=T-Shirt",
    },
    {
      name: "Jeans",
      description: "Classic blue jeans",
      price: 49.99,
      stock: 75,
      categoryId: clothing.id,
      imageUrl: "https://via.placeholder.com/300x300?text=Jeans",
    },
    {
      name: "Programming Book",
      description: "Learn to code with this comprehensive guide",
      price: 29.99,
      stock: 40,
      categoryId: books.id,
      imageUrl: "https://via.placeholder.com/300x300?text=Programming+Book",
    },
  ];

  // Create products
  await prisma.product.createMany({
    data: products,
    skipDuplicates: true,
  });

  console.log("Database seeded successfully!");
  console.log("Admin credentials: admin@example.com / admin123");
  console.log("User credentials: user@example.com / user123");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
