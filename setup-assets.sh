#!/bin/bash

# Expo Assets Setup Script
# This script copies required assets from public/assets/images to assets/images
# for Expo prebuild to work correctly

set -e  # Exit on error

echo "================================================"
echo "  Expo Assets Setup for xoso66.com"
echo "================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "app.json" ]; then
    echo "❌ Error: app.json not found. Please run this script from the project root."
    exit 1
fi

# Check if source directory exists
if [ ! -d "public/assets/images" ]; then
    echo "❌ Error: public/assets/images directory not found."
    exit 1
fi

echo "📁 Creating assets/images directory..."
mkdir -p assets/images

echo ""
echo "📋 Copying assets..."

# Copy main icon (use 512x512 android chrome icon as base)
if [ -f "public/assets/images/android-chrome-512x512.png" ]; then
    cp public/assets/images/android-chrome-512x512.png assets/images/icon.png
    echo "  ✓ icon.png copied (from android-chrome-512x512.png)"
elif [ -f "public/assets/images/icon.png" ]; then
    cp public/assets/images/icon.png assets/images/icon.png
    echo "  ✓ icon.png copied"
else
    echo "  ⚠️  Warning: No suitable icon found"
fi

# Copy favicon (use 32x32 version)
if [ -f "public/assets/images/favicon-32x32.png" ]; then
    cp public/assets/images/favicon-32x32.png assets/images/favicon.png
    echo "  ✓ favicon.png copied (from favicon-32x32.png)"
elif [ -f "public/assets/images/favicon.png" ]; then
    cp public/assets/images/favicon.png assets/images/favicon.png
    echo "  ✓ favicon.png copied"
else
    echo "  ⚠️  Warning: favicon not found"
fi

# Copy Android adaptive icon (512x512)
if [ -f "public/assets/images/android-chrome-512x512.png" ]; then
    cp public/assets/images/android-chrome-512x512.png assets/images/adaptive-icon.png
    echo "  ✓ adaptive-icon.png copied (from android-chrome-512x512.png)"
elif [ -f "public/assets/images/icon.png" ]; then
    cp public/assets/images/icon.png assets/images/adaptive-icon.png
    echo "  ✓ adaptive-icon.png copied (from icon.png)"
else
    echo "  ⚠️  Warning: No suitable file found for adaptive-icon.png"
fi

# Copy splash icon (use 512x512 icon)
if [ -f "public/assets/images/android-chrome-512x512.png" ]; then
    cp public/assets/images/android-chrome-512x512.png assets/images/splash-icon.png
    echo "  ✓ splash-icon.png copied (from android-chrome-512x512.png)"
elif [ -f "public/assets/images/icon.png" ]; then
    cp public/assets/images/icon.png assets/images/splash-icon.png
    echo "  ✓ splash-icon.png copied (from icon.png)"
else
    echo "  ⚠️  Warning: No suitable file found for splash-icon.png"
fi

echo ""
echo "================================================"
echo "✅ Assets setup completed!"
echo "================================================"
echo ""
echo "📂 Assets created in assets/images/:"
ls -lh assets/images/ 2>/dev/null || echo "  (directory listing failed)"

echo ""
echo "🔍 Verifying image dimensions:"
file assets/images/*.png 2>/dev/null || echo "  (file command not available)"

echo ""
echo "🚀 Next steps:"
echo "  1. Verify assets: ls -la assets/images/"
echo "  2. Run prebuild: npx expo prebuild --clean"
echo "  3. Build Android: eas build -p android --profile preview"
echo "  4. Build iOS: npm run ios:build:produc"
echo ""

# Made with Bob
