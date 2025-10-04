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

      // Upload to Cloudinary with optimization
      const result = await new Promise((resolve, reject) => {
        const options: Record<string, any> = {
          folder: "micro_ecom_products",
          resource_type: "image",
          transformation: [
            { width: 1000, height: 1000, crop: "limit" },
            { quality: "auto" },
          ],
        };

        // If an upload preset is configured, include it
        if (process.env["CLOUDINARY_UPLOAD_PRESET"]) {
          options["upload_preset"] = process.env["CLOUDINARY_UPLOAD_PRESET"];
        }

        cloudinary.uploader
          .upload_stream(options, (error, result) => {
            if (error) {
              console.log("Cloudinary upload error:", error);
              reject(error);
            } else {
              resolve(result);
            }
          })
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
      console.log("Upload error:", error);
      next(error);
    }
  }
}
