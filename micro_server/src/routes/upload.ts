import { Router } from "express";
import { UploadController } from "../controllers/uploadController";
import { authenticate, requireRole } from "../middleware/auth";
import { upload } from "../middleware/upload";

const router = Router();

// Upload product image (Admin only)
router.post(
  "/product-image",
  authenticate as any,
  requireRole(["ADMIN"]) as any,
  upload.single("image"),
  UploadController.uploadProductImage
);

export default router;
