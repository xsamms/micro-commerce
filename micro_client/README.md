# Micro Commerce Client

A modern Flutter e-commerce client application built with clean architecture, Riverpod state management, and responsive design.

## Features

- **Clean Architecture**: Domain-driven design with proper separation of concerns
- **State Management**: Riverpod with code generation for reactive state management
- **Type-safe API**: Dio HTTP client with Retrofit for API integration
- **Navigation**: Modern navigation with GoRouter
- **Responsive UI**: Adaptive widgets for different screen sizes
- **Secure Storage**: Flutter Secure Storage for sensitive data
- **Modern UI**: Material Design 3 with custom theme

## Prerequisites

- Flutter SDK (3.13.0 or higher)
- Dart SDK (3.1.0 or higher)
- Android Studio / VS Code with Flutter extensions

## Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd micro-commerce/micro_client
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Generate code (for Freezed, Riverpod, etc.):

   ```bash
   flutter packages pub run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── api/                # API client configurations
│   ├── constants/          # App constants and API endpoints
│   ├── models/             # Data models
│   ├── providers/          # Global providers
│   ├── services/           # Core services (API, Storage)
│   ├── theme/              # App theming
│   └── utils/              # Utilities and routing
├── features/               # Feature-based modules
│   ├── auth/               # Authentication
│   │   ├── providers/      # Auth state management
│   │   ├── screens/        # Auth UI screens
│   │   └── services/       # Auth services
│   ├── products/           # Product catalog
│   ├── cart/               # Shopping cart
│   ├── orders/             # Order management
│   └── admin/              # Admin functionality
├── shared/                 # Shared components
│   ├── widgets/            # Reusable UI components
│   └── extensions/         # Dart extensions
└── main.dart               # App entry point
```

## Features Overview

### Authentication

- User registration and login
- JWT token management
- Secure storage of credentials
- Role-based access control

### Product Catalog

- Browse products with pagination
- Search and filter functionality
- Product detail views
- Category-based organization

### Shopping Cart

- Add/remove items
- Quantity management
- Real-time total calculation
- Persistent cart state

### Order Management

- Order creation from cart
- Order history
- Order status tracking
- Order details view

### Admin Panel

- Product management (CRUD)
- Order management
- User management
- Dashboard analytics

## State Management

The app uses Riverpod for state management with the following patterns:

- **Providers**: For dependency injection and global state
- **StateNotifier**: For complex state management
- **FutureProvider**: For async data fetching
- **StreamProvider**: For real-time data streams

## API Integration

- **Dio**: HTTP client for API calls
- **Retrofit**: Type-safe API client generation
- **Interceptors**: Request/response logging and error handling
- **Token Management**: Automatic token injection and refresh

## Theming

The app uses Material Design 3 with:

- Custom color scheme
- Typography system with Inter font
- Consistent spacing and sizing
- Dark mode support

## Code Generation

The app uses several code generation tools:

```bash
# Generate all code
flutter packages pub run build_runner build

# Watch for changes and regenerate
flutter packages pub run build_runner watch

# Clean generated files
flutter packages pub run build_runner clean
```

## Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Build for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## Development Guidelines

### Folder Structure

- Follow feature-based folder structure
- Keep related files together
- Use barrel exports for clean imports

### Code Style

- Follow Dart/Flutter style guide
- Use meaningful variable names
- Add documentation for public APIs
- Keep functions small and focused

### State Management

- Use Riverpod providers for dependency injection
- Keep business logic in services
- Use StateNotifier for complex state
- Prefer immutable state objects

### API Integration

- Define API endpoints in constants
- Use models for request/response data
- Handle errors gracefully
- Implement proper loading states

## Environment Configuration

Create environment-specific configuration files:

```dart
// lib/core/config/env_config.dart
class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
}
```

Run with environment variables:

```bash
flutter run --dart-define=API_BASE_URL=https://api.yourapp.com
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.
