import { Router } from "express";
import { OrderController } from "../controllers/orderController";
import { authenticate, requireRole } from "../middleware/auth";

const router = Router();

// All order routes require authentication
router.use(authenticate as any);

router.post("/", OrderController.createOrder as any);
router.get("/", OrderController.getUserOrders as any);
router.get("/:id", OrderController.getOrderById as any);

// Admin only routes
router.put(
  "/:id/status",
  requireRole(["ADMIN"]) as any,
  OrderController.updateOrderStatus as any
);
router.get(
  "/admin/all",
  requireRole(["ADMIN"]) as any,
  OrderController.getAllOrders as any
);

export default router;
