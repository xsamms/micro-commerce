# Test Database Setup Guide

## Problem Solved

Previously, running tests would wipe out your development database data because tests and development were using the same database. This has been fixed!

## What Was Done

### 1. Separate Test Database

- Created `micro_commerce_test` database specifically for testing
- Tests now use `postgresql://postgres:PjR4bat15local@localhost:5432/micro_commerce_test`
- Development still uses `postgresql://postgres:PjR4bat15local@localhost:5432/micro_commerce`

### 2. Safety Checks Added

The test setup now includes multiple safety checks:

- **Environment Check**: Tests only run in `NODE_ENV=test`
- **Database URL Check**: Test database URL must contain "test"
- **Double Verification**: Before cleaning, it verifies it's using test database

### 3. Test Configuration Files

- `.env.test` - Test environment variables
- `jest.setup.js` - Loads test environment before Jest runs
- Enhanced `jest.config.js` - Properly configured for test environment
- Updated `package.json` scripts - All test commands now use `NODE_ENV=test`

## Commands

### Running Tests (Safe)

```bash
npm test                    # Run all tests
npm run test:watch         # Run tests in watch mode
npm run test:coverage      # Run tests with coverage
npm test -- auth.test.ts   # Run specific test file
```

### Setting Up Test Database (One-time)

```bash
npm run test:setup   # Creates/migrates test database
```

### Development (Unchanged)

```bash
npm run dev     # Your development data is safe!
npm run seed    # Seeds development database only
```

## Safety Features

### 🛡️ Protection Against Data Loss

1. **Environment Isolation**: Tests cannot run unless `NODE_ENV=test`
2. **Database Name Validation**: Test database must contain "test" in name
3. **URL Verification**: Multiple checks before any database cleaning
4. **Error Messages**: Clear error messages if safety checks fail

### 🧹 Clean Test Runs

- Each test file starts with clean database
- Tests are isolated from each other
- No data pollution between test runs

### 📊 Logging

- Shows which database is being used (with masked credentials)
- Logs when cleaning test database
- Confirms successful operations

## Troubleshooting

### "Tests can only be run in test environment" Error

- Solution: Use `npm test` instead of `jest` directly
- The npm script properly sets `NODE_ENV=test`

### "DANGER: Test database URL must contain 'test'" Error

- Solution: Check your `.env.test` file has correct `TEST_DATABASE_URL`
- Ensure the database name contains "test"

### Database Connection Errors

- Solution: Run `npm run test:setup` to create/migrate test database
- Ensure PostgreSQL is running and credentials are correct

## File Structure

```
micro_server/
├── .env              # Development environment (unchanged)
├── .env.test         # Test environment (NEW)
├── jest.config.js    # Updated for test environment
├── jest.setup.js     # Loads test environment (NEW)
├── package.json      # Updated test scripts
└── src/__tests__/
    ├── setup.ts      # Enhanced with safety checks
    └── *.test.ts     # All test files (safe to run)
```

## Your Data Is Now Safe! 🔒

✅ **Development database**: Untouched when running tests
✅ **Test database**: Isolated and cleaned automatically  
✅ **Safety checks**: Multiple layers of protection
✅ **Clear logging**: Always know which database is being used

You can now run tests freely without worrying about losing your development data!
