import { NextFunction, Request, Response } from "express";
import cloudinary from "../config/cloudinary";
import { ApiResponse } from "../types";
import { AppError } from "../utils/errors";

export class UploadController {
  static async uploadProductImage(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      if (!req.file) {
        throw new AppError("No image file provided", 400);
      }

      // Upload to Cloudinary
      const result = await new Promise((resolve, reject) => {
        cloudinary.uploader
          .upload_stream(
            {
              folder: "micro_ecom_products",
              upload_preset: "micro_ecom_products",
              resource_type: "image",
            },
            (error, result) => {
              if (error) {
                reject(error);
              } else {
                resolve(result);
              }
            }
          )
          .end(req.file!.buffer);
      });

      const uploadResult = result as any;

      const response: ApiResponse = {
        success: true,
        data: {
          imageUrl: uploadResult.secure_url,
          publicId: uploadResult.public_id,
        },
        message: "Image uploaded successfully",
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
