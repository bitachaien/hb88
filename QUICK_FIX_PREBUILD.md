# Quick Fix for Expo Prebuild Error

## Problem
```
Error: [ios.dangerous]: withIosDangerousBaseMod: ENOENT: no such file or directory, open './assets/images/icon.png'
```

## Quick Solution (Manual)

Run these commands in the project directory:

```bash
# Create directory
mkdir -p assets/images

# Copy required assets
cp public/assets/images/icon.png assets/images/icon.png
cp public/assets/images/favicon-32x32.png assets/images/favicon.png
cp public/assets/images/android-chrome-512x512.png assets/images/adaptive-icon.png
cp public/assets/images/icon.png assets/images/splash-icon.png

# Verify
ls -la assets/images/

# Run prebuild
npx expo prebuild --clean
```

## Quick Solution (Automated)

See [`EXPO_ASSETS_SETUP_PLAN.md`](EXPO_ASSETS_SETUP_PLAN.md) for the complete automation script.

## What This Does

1. Creates `assets/images/` directory at project root
2. Copies required icon files from `public/assets/images/`
3. Sets up all assets needed by Expo prebuild:
   - `icon.png` - Main app icon (1024x1024)
   - `adaptive-icon.png` - Android adaptive icon (512x512)
   - `favicon.png` - Web favicon
   - `splash-icon.png` - Splash screen logo

## Why This Is Needed

- Expo prebuild expects assets in `./assets/images/` (project root)
- Current assets are in `./public/assets/images/` (for web deployment)
- The [`app.json`](app.json) configuration references `./assets/images/` paths
- Both directories are needed: `assets/` for native builds, `public/` for web

## After Setup

You can proceed with:

```bash
# Android APK
eas build -p android --profile preview

# iOS IPA
npm run ios:build:produc

# Web export
npx expo export --platform web
```

## Files Created

```
assets/
└── images/
    ├── icon.png          (1024x1024 - from public/assets/images/icon.png)
    ├── adaptive-icon.png (512x512 - from public/assets/images/android-chrome-512x512.png)
    ├── favicon.png       (32x32 - from public/assets/images/favicon-32x32.png)
    └── splash-icon.png   (200px+ - from public/assets/images/icon.png)
```

## Related Documentation

- Full plan: [`EXPO_ASSETS_SETUP_PLAN.md`](EXPO_ASSETS_SETUP_PLAN.md)
- Build guide: [`BUILD_GUIDE.md`](BUILD_GUIDE.md)
- Deploy steps: [`DEPLOY_STEPS.md`](DEPLOY_STEPS.md)
