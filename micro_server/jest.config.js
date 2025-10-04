module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/src"],
  testMatch: ["**/__tests__/**/*.test.ts"],
  transform: {
    "^.+.ts$": "ts-jest",
  },
  coverageDirectory: "coverage",
  collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts", "!src/__tests__/**"],
  setupFilesAfterEnv: ["<rootDir>/src/__tests__/setup.ts"],
  // Load test environment variables
  setupFiles: ["<rootDir>/jest.setup.js"],
  // Run tests serially to avoid cross-suite DB interference
  maxWorkers: 1,
};
