import { Router } from "express";
import { CategoryController } from "../controllers/categoryController";
import { authenticate, requireRole } from "../middleware/auth";
import { validate } from "../middleware/validation";
import { createCategorySchema, updateCategorySchema } from "../validations";

const router = Router();

// Public routes
router.get("/", CategoryController.getCategories);
router.get("/:id", CategoryController.getCategoryById);

// Admin only routes
router.post(
  "/",
  authenticate as any,
  requireRole(["ADMIN"]) as any,
  validate(createCategorySchema),
  CategoryController.createCategory
);

router.put(
  "/:id",
  authenticate as any,
  requireRole(["ADMIN"]) as any,
  validate(updateCategorySchema),
  CategoryController.updateCategory
);

router.delete(
  "/:id",
  authenticate as any,
  requireRole(["ADMIN"]) as any,
  CategoryController.deleteCategory
);

export default router;
