import { Router } from "express";
import { CartController } from "../controllers/cartController";
import { authenticate } from "../middleware/auth";
import { validate } from "../middleware/validation";
import { addToCartSchema, updateCartItemSchema } from "../validations";

const router = Router();

// All cart routes require authentication
router.use(authenticate as any);

router.get("/", CartController.getCart as any);
router.post("/", validate(addToCartSchema), CartController.addToCart as any);
router.put(
  "/:itemId",
  validate(updateCartItemSchema),
  CartController.updateCartItem as any
);
router.delete("/:itemId", CartController.removeFromCart as any);
router.delete("/", CartController.clearCart as any);

export default router;
