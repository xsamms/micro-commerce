import { Router } from "express";
import { AuthController } from "../controllers/authController";
import { authenticate } from "../middleware/auth";
import { validate } from "../middleware/validation";
import { loginSchema, registerSchema } from "../validations";

const router = Router();

router.post("/register", validate(registerSchema), AuthController.register);
router.post("/login", validate(loginSchema), AuthController.login);
router.get("/profile", authenticate as any, AuthController.getProfile as any);
router.patch(
  "/profile",
  authenticate as any,
  AuthController.updateProfile as any
);

export default router;
