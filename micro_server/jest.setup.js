// Load test environment variables before tests run
const path = require("path");
const dotenv = require("dotenv");

// Load test environment variables
dotenv.config({ path: path.resolve(__dirname, ".env.test") });

// Ensure we're in test environment
process.env.NODE_ENV = "test";
