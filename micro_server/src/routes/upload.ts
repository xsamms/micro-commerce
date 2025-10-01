import { Router } from "express";
import { UploadController } from "../controllers/uploadController";
import { authenticateToken, requireRole } from "../middleware/auth";
import { upload } from "../middleware/upload";

const router = Router();

// Upload product image (Admin only)
router.post(
  "/product-image",
  authenticateToken,
  requireRole(["ADMIN"]) as any,
  upload.single("image"),
  UploadController.uploadProductImage
);

export default router;
