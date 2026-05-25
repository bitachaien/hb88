# Expo Assets Setup Plan

## Problem Analysis

**Error**: `ENOENT: no such file or directory, open './assets/images/icon.png'`

**Root Cause**:
- Expo prebuild expects assets in `./assets/images/` directory
- Current assets are located in `./public/assets/images/`
- The [`app.json`](app.json:7) configuration references `./assets/images/` paths

## Required Assets

Based on [`app.json`](app.json) configuration, we need:

1. **icon.png** (1024x1024) - Main app icon
   - Path: `./assets/images/icon.png`
   - Used for: iOS and Android app icons

2. **adaptive-icon.png** (512x512) - Android adaptive icon
   - Path: `./assets/images/adaptive-icon.png`
   - Used for: Android adaptive icon foreground

3. **favicon.png** (48x48 or larger) - Web favicon
   - Path: `./assets/images/favicon.png`
   - Used for: Web app favicon

4. **splash-icon.png** (200px width) - Splash screen logo
   - Path: `./assets/images/splash-icon.png`
   - Used for: App splash screen

## Current Assets Available

In `./public/assets/images/`:
- ✅ `icon.png` - Exists
- ✅ `favicon.ico` - Exists (need PNG version)
- ✅ `favicon-16x16.png` - Exists
- ✅ `favicon-32x32.png` - Exists
- ✅ `android-chrome-192x192.png` - Exists
- ✅ `android-chrome-512x512.png` - Exists (can use for adaptive-icon)
- ✅ `apple-touch-icon.png` - Exists

## Implementation Plan

### Step 1: Create Directory Structure
```bash
mkdir -p assets/images
```

### Step 2: Copy Existing Assets
```bash
# Copy main icon
cp public/assets/images/icon.png assets/images/icon.png

# Copy favicon (or create from existing)
cp public/assets/images/favicon-32x32.png assets/images/favicon.png

# Copy Android icon for adaptive icon
cp public/assets/images/android-chrome-512x512.png assets/images/adaptive-icon.png
```

### Step 3: Create Splash Icon
```bash
# Use the main icon as splash icon (will be resized by Expo)
cp public/assets/images/icon.png assets/images/splash-icon.png
```

### Step 4: Verify Assets
Check that all required files exist:
- `assets/images/icon.png`
- `assets/images/adaptive-icon.png`
- `assets/images/favicon.png`
- `assets/images/splash-icon.png`

### Step 5: Test Prebuild
```bash
npx expo prebuild --clean
```

## Automation Script

Create `setup-assets.sh` in the project root:

```bash
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

# Copy main icon (1024x1024)
if [ -f "public/assets/images/icon.png" ]; then
    cp public/assets/images/icon.png assets/images/icon.png
    echo "  ✓ icon.png copied"
else
    echo "  ⚠️  Warning: icon.png not found in public/assets/images"
fi

# Copy favicon (use 32x32 version)
if [ -f "public/assets/images/favicon-32x32.png" ]; then
    cp public/assets/images/favicon-32x32.png assets/images/favicon.png
    echo "  ✓ favicon.png copied (from favicon-32x32.png)"
elif [ -f "public/assets/images/favicon.png" ]; then
    cp public/assets/images/favicon.png assets/images/favicon.png
    echo "  ✓ favicon.png copied"
else
    echo "  ⚠️  Warning: favicon not found in public/assets/images"
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

# Copy splash icon (use main icon)
if [ -f "public/assets/images/icon.png" ]; then
    cp public/assets/images/icon.png assets/images/splash-icon.png
    echo "  ✓ splash-icon.png copied (from icon.png)"
else
    echo "  ⚠️  Warning: icon.png not found for splash screen"
fi

echo ""
echo "================================================"
echo "✅ Assets setup completed!"
echo "================================================"
echo ""
echo "📂 Assets created in assets/images/:"
ls -lh assets/images/ 2>/dev/null || echo "  (directory listing failed)"

echo ""
echo "🚀 Next steps:"
echo "  1. Verify assets: ls -la assets/images/"
echo "  2. Run prebuild: npx expo prebuild --clean"
echo "  3. Build Android: eas build -p android --profile preview"
echo "  4. Build iOS: npm run ios:build:produc"
echo ""
```

**Usage:**

```bash
# Make executable
chmod +x setup-assets.sh

# Run the script
./setup-assets.sh
```

**Windows (PowerShell) Alternative:**

Create `setup-assets.ps1`:

```powershell
# Expo Assets Setup Script for Windows
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Expo Assets Setup for xoso66.com" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "app.json")) {
    Write-Host "❌ Error: app.json not found. Please run this script from the project root." -ForegroundColor Red
    exit 1
}

# Check if source directory exists
if (-not (Test-Path "public/assets/images")) {
    Write-Host "❌ Error: public/assets/images directory not found." -ForegroundColor Red
    exit 1
}

Write-Host "📁 Creating assets/images directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "assets/images" | Out-Null

Write-Host ""
Write-Host "📋 Copying assets..." -ForegroundColor Yellow

# Copy main icon
if (Test-Path "public/assets/images/icon.png") {
    Copy-Item "public/assets/images/icon.png" "assets/images/icon.png"
    Write-Host "  ✓ icon.png copied" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Warning: icon.png not found" -ForegroundColor Yellow
}

# Copy favicon
if (Test-Path "public/assets/images/favicon-32x32.png") {
    Copy-Item "public/assets/images/favicon-32x32.png" "assets/images/favicon.png"
    Write-Host "  ✓ favicon.png copied" -ForegroundColor Green
} elseif (Test-Path "public/assets/images/favicon.png") {
    Copy-Item "public/assets/images/favicon.png" "assets/images/favicon.png"
    Write-Host "  ✓ favicon.png copied" -ForegroundColor Green
}

# Copy adaptive icon
if (Test-Path "public/assets/images/android-chrome-512x512.png") {
    Copy-Item "public/assets/images/android-chrome-512x512.png" "assets/images/adaptive-icon.png"
    Write-Host "  ✓ adaptive-icon.png copied" -ForegroundColor Green
} elseif (Test-Path "public/assets/images/icon.png") {
    Copy-Item "public/assets/images/icon.png" "assets/images/adaptive-icon.png"
    Write-Host "  ✓ adaptive-icon.png copied" -ForegroundColor Green
}

# Copy splash icon
if (Test-Path "public/assets/images/icon.png") {
    Copy-Item "public/assets/images/icon.png" "assets/images/splash-icon.png"
    Write-Host "  ✓ splash-icon.png copied" -ForegroundColor Green
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ Assets setup completed!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📂 Assets created:" -ForegroundColor Yellow
Get-ChildItem "assets/images" | Format-Table Name, Length

Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Verify assets: Get-ChildItem assets/images"
Write-Host "  2. Run prebuild: npx expo prebuild --clean"
Write-Host "  3. Build Android: eas build -p android --profile preview"
Write-Host ""
```

**Windows Usage:**

```powershell
# Run the script
.\setup-assets.ps1
```

## Asset Requirements Reference

### Icon Sizes
- **iOS**: 1024x1024 (icon.png)
- **Android**: 512x512 (adaptive-icon.png)
- **Web**: 48x48+ (favicon.png)
- **Splash**: 200px width (splash-icon.png)

### File Formats
- All files should be PNG format
- Transparent background recommended for icons
- RGB color space

## Expected Outcome

After setup:
```
assets/
└── images/
    ├── icon.png (1024x1024)
    ├── adaptive-icon.png (512x512)
    ├── favicon.png (32x32 or larger)
    └── splash-icon.png (200px+ width)
```

## Next Steps After Setup

1. Run prebuild:
   ```bash
   npx expo prebuild --clean
   ```

2. If successful, proceed with builds:
   ```bash
   # Android
   eas build -p android --profile preview

   # iOS
   npm run ios:build:produc

   # Web
   npx expo export --platform web
   ```

## Troubleshooting

### If prebuild still fails:
1. Check file permissions: `ls -la assets/images/`
2. Verify file sizes: `file assets/images/*.png`
3. Check app.json paths are correct
4. Clear Expo cache: `npx expo start -c`

### If images are wrong size:
Use ImageMagick to resize:
```bash
# Resize icon to 1024x1024
convert assets/images/icon.png -resize 1024x1024 assets/images/icon.png

# Resize adaptive icon to 512x512
convert assets/images/adaptive-icon.png -resize 512x512 assets/images/adaptive-icon.png
```

## References

- [Expo App Icons Documentation](https://docs.expo.dev/develop/user-interface/app-icons/)
- [Expo Splash Screen Documentation](https://docs.expo.dev/develop/user-interface/splash-screen/)
- [app.json Configuration](app.json)
