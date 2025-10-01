import { Router } from "express";
import { ProductController } from "../controllers/productController";
import { authenticate, requireRole } from "../middleware/auth";
import { validate, validateQuery } from "../middleware/validation";
import {
  createProductSchema,
  productQuerySchema,
  updateProductSchema,
} from "../validations";

const router = Router();

router.get(
  "/",
  validateQuery(productQuerySchema),
  ProductController.getProducts
);
router.get("/:id", ProductController.getProductById);

// Admin only routes
router.post(
  "/",
  authenticate as any,
  requireRole(["ADMIN"]) as any,
  validate(createProductSchema),
  ProductController.createProduct
);

router.put(
  "/:id",
  authenticate as any,
  requireRole(["ADMIN"]) as any,
  validate(updateProductSchema),
  ProductController.updateProduct
);

router.delete(
  "/:id",
  authenticate as any,
  requireRole(["ADMIN"]) as any,
  ProductController.deleteProduct
);

export default router;
