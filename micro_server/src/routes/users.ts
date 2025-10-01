import { Router } from "express";
import { UserController } from "../controllers/userController";
import { authenticate, requireRole } from "../middleware/auth";

const router = Router();

// All user management routes require authentication and admin role
router.use(authenticate as any);
router.use(requireRole(["ADMIN"]) as any);

router.get("/", UserController.getAllUsers as any);
router.get("/:id", UserController.getUserById as any);
router.put("/:id", UserController.updateUser as any);
router.delete("/:id", UserController.deleteUser as any);
router.patch("/:id/role", UserController.updateUserRole as any);

export default router;
