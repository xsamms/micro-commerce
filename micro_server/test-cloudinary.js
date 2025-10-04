// Test Cloudinary Configuration
const { v2: cloudinary } = require("cloudinary");

cloudinary.config({
  cloud_name: process.env["CLOUDINARY_CLOUD_NAME"] || "",
  api_key: process.env["CLOUDINARY_API_KEY"] || "",
  api_secret: process.env["CLOUDINARY_API_SECRET"] || "",
});

async function testCloudinary() {
  try {
    console.log("Testing Cloudinary configuration...");

    console.log("Cloudinary config:", {
      cloud_name: cloudinary.config().cloud_name,
      api_key: cloudinary.config().api_key ? "***configured***" : "missing",
      api_secret: cloudinary.config().api_secret
        ? "***configured***"
        : "missing",
    });

    // Test basic API connectivity
    const result = await cloudinary.api.ping();
    console.log("Cloudinary ping successful:", result);
  } catch (error) {
    console.error("Cloudinary test failed:", error);
  }
}

testCloudinary();
