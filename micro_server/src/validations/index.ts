import Joi from "joi";

export const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  firstName: Joi.string().max(100).optional(),
  lastName: Joi.string().max(100).optional(),
});

export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

export const createProductSchema = Joi.object({
  name: Joi.string().max(500).required(),
  description: Joi.string().max(2000).optional(),
  price: Joi.number().positive().max(999999.99).required(),
  stock: Joi.number().integer().min(0).max(1000000).required(),
  categoryId: Joi.string().required(),
  imageUrl: Joi.string().uri().max(2000).optional(),
});

export const updateProductSchema = Joi.object({
  name: Joi.string().max(500).optional(),
  description: Joi.string().max(2000).optional(),
  price: Joi.number().positive().max(999999.99).optional(),
  stock: Joi.number().integer().min(0).max(1000000).optional(),
  categoryId: Joi.string().optional(),
  imageUrl: Joi.string().uri().max(2000).optional(),
});

export const createCategorySchema = Joi.object({
  name: Joi.string().required(),
  description: Joi.string().optional(),
});

export const updateCategorySchema = Joi.object({
  name: Joi.string().optional(),
  description: Joi.string().optional(),
});

export const addToCartSchema = Joi.object({
  productId: Joi.string().required(),
  quantity: Joi.number().integer().min(1).required(),
});

export const updateCartItemSchema = Joi.object({
  quantity: Joi.number().integer().min(1).required(),
});

export const paginationSchema = Joi.object({
  page: Joi.number().integer().min(1).max(10000).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
});

export const productQuerySchema = paginationSchema.keys({
  category: Joi.string().optional(),
  search: Joi.string().optional(),
  minPrice: Joi.number().positive().optional(),
  maxPrice: Joi.number().positive().optional(),
});
