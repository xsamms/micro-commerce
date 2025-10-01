import { Router } from "express";
import authRoutes from "./auth";
import cartRoutes from "./cart";
import categoryRoutes from "./categories";
import orderRoutes from "./orders";
import productRoutes from "./products";
import uploadRoutes from "./upload";
import userRoutes from "./users";

const router = Router();

router.use("/auth", authRoutes);
router.use("/products", productRoutes);
router.use("/categories", categoryRoutes);
router.use("/cart", cartRoutes);
router.use("/orders", orderRoutes);
router.use("/upload", uploadRoutes);
router.use("/users", userRoutes);

export default router;
