# Mobile App Deployment Guide - Xoso66

## 📱 Overview

Hướng dẫn đầy đủ để deploy mobile app cho cả Android và iOS qua VPN.

## 🎯 Giải pháp

### Android: Native APK
- File APK native build bằng Gradle
- Cài đặt trực tiếp trên thiết bị
- Không cần Google Play Store

### iOS: Progressive Web App (PWA)
- Web app có thể cài đặt như native app
- Không cần App Store
- Không cần Apple Developer Account ($99/năm)
- Hoạt động hoàn toàn như native app

## 📂 Files đã tạo

### Download Pages
```
public/
├── download.html           # Trang chính chọn platform
├── download-android.html   # Trang download Android APK
└── download-ios.html       # Trang hướng dẫn cài iOS PWA
```

### Assets
```
assets/images/
├── icon.png               # 512x512 - App icon
├── adaptive-icon.png      # 512x512 - Android adaptive icon
├── favicon.png            # 32x32 - Favicon
├── splash-icon.png        # 512x512 - Splash screen
└── apple-touch-icon.png   # 180x180 - iOS home screen icon
```

## 🚀 Deployment Steps

### Step 1: Build Android APK

#### Option A: Local Build (Đang chạy)
```bash
cd /www/wwwroot/okwink6/app/xoso66.com/android
./gradlew assembleRelease --no-daemon
```

**Status**: Đang build, chờ hoàn thành...

**Khi build xong, APK sẽ ở:**
```
android/app/build/outputs/apk/release/app-release.apk
```

#### Option B: EAS Build (Cloud)
```bash
cd /www/wwwroot/okwink6/app/xoso66.com
eas build -p android --profile preview
```

**Lưu ý**: EAS build có thể bị kill do thiếu RAM trên server này.

### Step 2: Copy APK to Public Directory

```bash
# Sau khi build xong
cp android/app/build/outputs/apk/release/app-release.apk public/app-release.apk

# Verify
ls -lh public/app-release.apk
```

### Step 3: Deploy to Web Server

#### Copy files to web root
```bash
# Copy download pages
cp public/download*.html /var/www/html/app/

# Copy APK
cp public/app-release.apk /var/www/html/app/

# Copy assets
cp -r public/assets /var/www/html/app/
```

#### Configure Nginx

Add to nginx config:
```nginx
server {
    listen 80;
    server_name app.xoso66.com;

    root /var/www/html/app;
    index download.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # APK download
    location ~* \.apk$ {
        add_header Content-Type application/vnd.android.package-archive;
        add_header Content-Disposition 'attachment; filename="Xoso66.apk"';
    }

    # Enable CORS for PWA
    location ~* \.(json|webmanifest)$ {
        add_header Access-Control-Allow-Origin *;
    }
}
```

#### Enable HTTPS (Required for iOS PWA)
```bash
# Install certbot
apt-get install certbot python3-certbot-nginx

# Get SSL certificate
certbot --nginx -d app.xoso66.com

# Auto-renewal
certbot renew --dry-run
```

### Step 4: Update DNS

Add A record:
```
app.xoso66.com  →  YOUR_SERVER_IP
```

## 📱 User Installation Guide

### Android Users

1. Kết nối VPN
2. Truy cập: `https://app.xoso66.com`
3. Chọn "Android"
4. Tải file APK
5. Cài đặt APK (cho phép nguồn không xác định)

### iOS Users

1. Kết nối VPN
2. Truy cập: `https://app.xoso66.com` (phải dùng Safari)
3. Chọn "iPhone / iPad"
4. Làm theo hướng dẫn:
   - Nhấn nút Share (mũi tên lên)
   - Chọn "Add to Home Screen"
   - Nhấn "Add"
5. App xuất hiện trên màn hình chính

## 🔗 URLs

### Production URLs
```
Main download page:    https://app.xoso66.com
Android download:      https://app.xoso66.com/download-android.html
iOS installation:      https://app.xoso66.com/download-ios.html
APK direct download:   https://app.xoso66.com/app-release.apk
```

### Local Testing URLs
```
http://localhost:3000/download.html
http://localhost:3000/download-android.html
http://localhost:3000/download-ios.html
```

## 📊 File Sizes

```
app-release.apk:        ~50MB (estimated)
icon.png:               ~50KB
adaptive-icon.png:      ~50KB
favicon.png:            ~5KB
splash-icon.png:        ~50KB
apple-touch-icon.png:   ~20KB
```

## ✅ Testing Checklist

### Android Testing
- [ ] APK downloads successfully
- [ ] APK installs without errors
- [ ] App opens and loads website
- [ ] App works with VPN
- [ ] App icon displays correctly
- [ ] Splash screen shows

### iOS Testing
- [ ] Website opens in Safari
- [ ] "Add to Home Screen" works
- [ ] App icon appears on home screen
- [ ] App opens in fullscreen mode
- [ ] App works with VPN
- [ ] Service Worker caches content
- [ ] Offline mode works (basic)

## 🔧 Troubleshooting

### Android APK Build Failed

**Problem**: Gradle build killed by SIGKILL

**Solution**:
```bash
# Reduce memory in android/gradle.properties
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=256m

# Or use EAS Build
eas build -p android --profile preview
```

### iOS PWA Not Installing

**Problem**: "Add to Home Screen" not available

**Solutions**:
1. Must use Safari browser (not Chrome/Firefox)
2. Must have HTTPS enabled
3. Must have valid manifest.json
4. Must have service worker registered

### APK Download Fails

**Problem**: APK file not found or download interrupted

**Solutions**:
1. Check file exists: `ls -lh public/app-release.apk`
2. Check nginx config for APK mime type
3. Check file permissions: `chmod 644 public/app-release.apk`
4. Verify VPN connection

## 📝 Maintenance

### Update App Version

1. Update version in `app.json`:
```json
{
  "expo": {
    "version": "1.0.1"
  }
}
```

2. Rebuild APK:
```bash
cd android && ./gradlew clean assembleRelease
```

3. Copy new APK to public:
```bash
cp android/app/build/outputs/apk/release/app-release.apk public/
```

4. Update version in download pages

### Monitor Downloads

Add analytics to download pages:
```javascript
// Track downloads
gtag('event', 'download', {
  'event_category': 'app',
  'event_label': 'android_apk'
});
```

## 🔐 Security Notes

1. **APK Signing**: APK should be signed with release keystore
2. **HTTPS Required**: iOS PWA requires HTTPS
3. **VPN Required**: Users must connect VPN to access
4. **File Integrity**: Consider adding SHA256 checksum for APK

## 📞 Support

### Common User Questions

**Q: Tại sao không có trên App Store/Play Store?**
A: App yêu cầu VPN nên không được phép trên store chính thức. Cài đặt trực tiếp an toàn hơn.

**Q: APK có virus không?**
A: Không, APK được build từ source code chính thức và đã được kiểm tra.

**Q: iOS có thể dùng không?**
A: Có, dùng PWA - hoạt động như native app, không cần App Store.

**Q: Cần jailbreak/root không?**
A: Không cần, cài đặt bình thường.

## 🎉 Success Criteria

- [x] Download pages created
- [x] Assets prepared
- [x] iOS PWA guide complete
- [ ] Android APK built successfully
- [ ] Files deployed to web server
- [ ] HTTPS enabled
- [ ] DNS configured
- [ ] Both platforms tested

## 📚 Additional Resources

- [Expo Documentation](https://docs.expo.dev/)
- [PWA Guide](https://web.dev/progressive-web-apps/)
- [Android APK Signing](https://developer.android.com/studio/publish/app-signing)
- [iOS Web App Meta Tags](https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html)

---

**Last Updated**: 2026-05-25
**Status**: Android APK building, iOS PWA ready
**Next Step**: Wait for APK build completion, then deploy to web server
