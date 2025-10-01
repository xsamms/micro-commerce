# Micro Commerce Server

A secure and scalable e-commerce backend built with Node.js, Express.js, TypeScript, Prisma, and PostgreSQL.

## Features

- **Authentication & Authorization**: JWT-based authentication with role-based access control
- **Product Management**: CRUD operations for products with category support
- **Shopping Cart**: Session-based cart functionality
- **Order Management**: Order creation and status tracking
- **Security**: Helmet, CORS, rate limiting, input sanitization
- **Validation**: Request validation using Joi
- **Logging**: Winston and Morgan for comprehensive logging
- **Database**: PostgreSQL with Prisma ORM
- **Testing**: Jest for unit and integration tests

## Prerequisites

- Node.js (v18 or higher)
- PostgreSQL database
- npm or yarn

## Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd micro-commerce/micro_server
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Set up environment variables:

   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your database URL and other configuration values.

4. Set up the database:

   ```bash
   # Generate Prisma client
   npm run generate

   # Run database migrations
   npm run migrate

   # Seed the database with sample data
   npm run seed
   ```

## Running the Application

### Development

```bash
npm run dev
```

### Production

```bash
npm run build
npm start
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get user profile (authenticated)

### Products

- `GET /api/products` - Get all products (with pagination and filters)
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create product (admin only)
- `PUT /api/products/:id` - Update product (admin only)
- `DELETE /api/products/:id` - Delete product (admin only)

### Cart

- `GET /api/cart` - Get user's cart
- `POST /api/cart` - Add item to cart
- `PUT /api/cart/:itemId` - Update cart item quantity
- `DELETE /api/cart/:itemId` - Remove item from cart
- `DELETE /api/cart` - Clear cart

### Orders

- `POST /api/orders` - Create order from cart
- `GET /api/orders` - Get user's orders
- `GET /api/orders/:id` - Get order by ID
- `PUT /api/orders/:id/status` - Update order status (admin only)
- `GET /api/orders/admin/all` - Get all orders (admin only)

## Default Credentials

After seeding the database, you can use these credentials:

- **Admin**: admin@example.com / admin123
- **User**: user@example.com / user123

## Project Structure

```
src/
├── config/          # Configuration files
├── controllers/     # Route controllers
├── middleware/      # Custom middleware
├── routes/          # API routes
├── services/        # Business logic
├── types/           # TypeScript type definitions
├── utils/           # Utility functions
├── validations/     # Request validation schemas
└── __tests__/       # Test files
```

## Database Schema

The application uses the following main entities:

- **User**: User accounts with role-based permissions
- **Category**: Product categories
- **Product**: Product catalog with inventory
- **Cart/CartItem**: Shopping cart functionality
- **Order/OrderItem**: Order management

## Environment Variables

```env
NODE_ENV=development
PORT=3000
DATABASE_URL="postgresql://username:password@localhost:5432/micro_commerce?schema=public"
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=7d
CORS_ORIGIN=http://localhost:3000
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

## Security Features

- **Helmet**: Security headers
- **CORS**: Cross-origin resource sharing
- **Rate Limiting**: Request rate limiting
- **Input Sanitization**: XSS and injection protection
- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Bcrypt for password security
- **Environment Variables**: Secure configuration management

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.
