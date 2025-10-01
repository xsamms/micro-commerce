#!/bin/bash

# Micro Commerce Setup Script
echo "🚀 Setting up Micro Commerce..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js (v18+) first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter SDK first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Setup Backend
echo "📦 Setting up backend..."
cd micro_server

# Install dependencies
echo "Installing Node.js dependencies..."
npm install

# Copy environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "📝 Created .env file. Please update it with your database credentials."
fi

# Generate Prisma client
echo "Generating Prisma client..."
npx prisma generate

echo "✅ Backend setup complete!"
echo ""
echo "⚠️  Next steps for backend:"
echo "1. Update .env file with your PostgreSQL database URL"
echo "2. Run: npm run migrate"
echo "3. Run: npm run seed"
echo "4. Run: npm run dev"
echo ""

# Setup Frontend
cd ../micro_client
echo "📱 Setting up frontend..."

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

echo "✅ Frontend setup complete!"
echo ""
echo "⚠️  Next steps for frontend:"
echo "1. Run: flutter packages pub run build_runner build"
echo "2. Run: flutter run"
echo ""

echo "🎉 Setup complete! Check the README.md for detailed instructions."