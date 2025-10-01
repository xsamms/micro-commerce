# Micro Commerce - Full Stack E-commerce System

A complete e-commerce solution built with Node.js/Express backend and Flutter frontend.

## 🚀 Quick Start

### Prerequisites

- Node.js (v18+)
- PostgreSQL database
- Flutter SDK (3.13.0+)
- Git

### 1. Clone the Repository

```bash
git clone <repository-url>
cd micro-commerce
```

### 2. Backend Setup (micro_server)

```bash
cd micro_server

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your database credentials
# DATABASE_URL="postgresql://username:password@localhost:5432/micro_commerce?schema=public"
# JWT_SECRET=your-super-secret-jwt-key

# Generate Prisma client
npm run generate

# Run database migrations
npm run migrate

# Seed the database with sample data
npm run seed

# Start development server
npm run dev
```

The backend will be available at `http://localhost:4500`

### 3. Frontend Setup (micro_client)

```bash
cd ../micro_client

# Install dependencies
flutter pub get

# Generate code (if using Freezed/Riverpod generators)
flutter packages pub run build_runner build

# Run the app
flutter run
```

## 📁 Project Structure

```
micro-commerce/
├── micro_server/           # Node.js Backend
│   ├── src/
│   │   ├── config/         # Configuration files
│   │   ├── controllers/    # Route controllers
│   │   ├── middleware/     # Custom middleware
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   ├── types/          # TypeScript types
│   │   ├── utils/          # Utility functions
│   │   └── validations/    # Request validation schemas
│   ├── prisma/             # Database schema and migrations
│   └── package.json
│
├── micro_client/           # Flutter Frontend
│   ├── lib/
│   │   ├── core/           # Core functionality
│   │   ├── features/       # Feature modules
│   │   ├── shared/         # Shared components
│   │   └── main.dart
│   ├── assets/             # App assets
│   └── pubspec.yaml
│
└── README.md              # This file
```

## 🔧 Technology Stack

### Backend (micro_server)

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT with Passport.js
- **Validation**: Joi
- **Logging**: Winston & Morgan
- **Security**: Helmet, CORS, Rate Limiting
- **Testing**: Jest
- **Language**: TypeScript

### Frontend (micro_client)

- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Storage**: Shared Preferences & Secure Storage
- **UI**: Material Design 3
- **Code Generation**: Freezed, Retrofit
- **Language**: Dart

## 🎯 Features

### Core E-commerce Features

- ✅ User registration and authentication
- ✅ Product catalog with categories
- ✅ Shopping cart functionality
- ✅ Order management
- ✅ Admin panel for product management
- ✅ Role-based access control

### Technical Features

- ✅ RESTful API design
- ✅ JWT authentication
- ✅ Input validation and sanitization
- ✅ Error handling and logging
- ✅ Database migrations and seeding
- ✅ Responsive mobile UI
- ✅ Clean architecture patterns

## 📱 API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile

### Products

- `GET /api/products` - Get products (with pagination/filters)
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create product (admin only)
- `PUT /api/products/:id` - Update product (admin only)
- `DELETE /api/products/:id` - Delete product (admin only)

### Cart

- `GET /api/cart` - Get user's cart
- `POST /api/cart` - Add item to cart
- `PUT /api/cart/:itemId` - Update cart item
- `DELETE /api/cart/:itemId` - Remove cart item
- `DELETE /api/cart` - Clear cart

### Orders

- `POST /api/orders` - Create order from cart
- `GET /api/orders` - Get user's orders
- `GET /api/orders/:id` - Get order details
- `PUT /api/orders/:id/status` - Update order status (admin)
- `GET /api/orders/admin/all` - Get all orders (admin)

## 🔐 Default Credentials

After seeding the database:

**Admin User:**

- Email: `admin@example.com`
- Password: `admin123`

**Regular User:**

- Email: `user@example.com`
- Password: `user123`

## 🛠️ Development

### Backend Development

```bash
cd micro_server

# Start in development mode
npm run dev

# Run tests
npm test

# Run with coverage
npm run test:coverage

# Generate Prisma client after schema changes
npm run generate

# Create and run migrations
npm run migrate

# Reset database (development only)
npx prisma migrate reset
```

### Frontend Development

```bash
cd micro_client

# Hot reload development
flutter run

# Run tests
flutter test

# Build for production
flutter build apk --release

# Generate code after model changes
flutter packages pub run build_runner build
```

## 🚀 Deployment

### Backend Deployment

1. Set environment variables for production
2. Run database migrations: `npm run migrate`
3. Build the app: `npm run build`
4. Start the server: `npm start`

### Frontend Deployment

1. Update API base URL in configuration
2. Build for target platform:
   - Android: `flutter build apk --release`
   - iOS: `flutter build ios --release`
   - Web: `flutter build web --release`

## 🧪 Testing

### Backend Testing

```bash
cd micro_server
npm test
```

### Frontend Testing

```bash
cd micro_client
flutter test
```

## 🔒 Security Features

- JWT token authentication
- Password hashing with bcrypt
- Input validation and sanitization
- XSS protection
- SQL injection prevention
- Rate limiting
- CORS configuration
- Security headers with Helmet

## 📊 Database Schema

The system uses the following main entities:

- **Users**: User accounts with roles
- **Categories**: Product categories
- **Products**: Product catalog
- **Cart/CartItems**: Shopping cart
- **Orders/OrderItems**: Order management

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Add tests for new features
5. Ensure all tests pass
6. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:

1. Check the documentation in each module's README
2. Review the API documentation
3. Check existing issues on GitHub
4. Create a new issue if needed

---

**Happy Coding! 🎉**
