# iOS PWA Guide - Web App qua VPN

## Tổng Quan

Thay vì build iOS app native (cần App Store), bạn có thể tạo **Progressive Web App (PWA)** để người dùng iOS cài đặt trực tiếp từ Safari.

## Ưu Điểm PWA cho iOS

✅ Không cần App Store review
✅ Không cần Apple Developer Account ($99/năm)
✅ Cập nhật ngay lập tức (không cần submit app mới)
✅ Hoạt động qua VPN
✅ Có icon trên Home Screen như app thật
✅ Chạy fullscreen (không có Safari toolbar)

## Cấu Trúc Hiện Tại

Project đã có sẵn PWA config:

```
app/xoso66.com/
├── public/
│   ├── assets/images/
│   │   ├── android-chrome-192x192.png  # PWA icon
│   │   ├── android-chrome-512x512.png  # PWA icon
│   │   ├── apple-touch-icon.png        # iOS icon
│   │   ├── favicon-32x32.png
│   │   └── site.webmanifest            # PWA manifest
│   ├── index.html                      # Landing page
│   └── ...
```

## Bước 1: Cấu Hình PWA Manifest

File `public/assets/images/site.webmanifest` đã có sẵn, cần update:

```json
{
  "name": "XOSO66",
  "short_name": "XOSO66",
  "description": "XOSO66 - Xổ số trực tuyến",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#1976d2",
  "orientation": "portrait",
  "icons": [
    {
      "src": "/assets/images/android-chrome-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/assets/images/android-chrome-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/assets/images/apple-touch-icon.png",
      "sizes": "180x180",
      "type": "image/png"
    }
  ]
}
```

## Bước 2: Cấu Hình HTML

File `public/index.html` cần có các meta tags cho iOS:

```html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

    <!-- PWA Meta Tags -->
    <meta name="theme-color" content="#1976d2">
    <meta name="description" content="XOSO66 - Xổ số trực tuyến">

    <!-- iOS Meta Tags -->
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="apple-mobile-web-app-title" content="XOSO66">

    <!-- Icons -->
    <link rel="manifest" href="/assets/images/site.webmanifest">
    <link rel="apple-touch-icon" href="/assets/images/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/assets/images/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/assets/images/favicon-16x16.png">

    <title>XOSO66</title>
</head>
<body>
    <!-- Your app content -->
    <div id="app"></div>

    <!-- Service Worker Registration -->
    <script>
        if ('serviceWorker' in navigator) {
            window.addEventListener('load', () => {
                navigator.serviceWorker.register('/sw.js')
                    .then(reg => console.log('Service Worker registered'))
                    .catch(err => console.log('Service Worker registration failed'));
            });
        }
    </script>
</body>
</html>
```

## Bước 3: Tạo Service Worker

Tạo file `public/sw.js`:

```javascript
const CACHE_NAME = 'xoso66-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/assets/images/icon.png',
  '/assets/images/apple-touch-icon.png',
  '/css/index1017.css',
  '/js/index1017.js'
];

// Install Service Worker
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

// Fetch from cache
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});

// Update Service Worker
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
```

## Bước 4: Deploy PWA

### Option 1: Deploy trên Domain chính (Khuyến nghị)

```bash
# Copy PWA files to web root
cp -r /www/wwwroot/okwink6/app/xoso66.com/public/* /www/wwwroot/okwink6/boyue/public/

# Hoặc tạo subdomain riêng
# app.xoso66.com -> /www/wwwroot/okwink6/app/xoso66.com/public
```

### Option 2: Sử dụng Nginx để serve PWA

Cấu hình Nginx (`/www/wwwroot/okwink6/app/xoso66.com/nginx.conf`):

```nginx
server {
    listen 80;
    server_name app.xoso66.com;

    root /www/wwwroot/okwink6/app/xoso66.com/public;
    index index.html;

    # Enable HTTPS (required for PWA)
    # listen 443 ssl http2;
    # ssl_certificate /path/to/cert.pem;
    # ssl_certificate_key /path/to/key.pem;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Service Worker - no cache
    location = /sw.js {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }

    # Manifest
    location = /site.webmanifest {
        add_header Content-Type application/manifest+json;
    }
}
```

## Bước 5: Hướng Dẫn User Cài Đặt PWA trên iOS

### Cho User:

1. **Mở Safari** trên iPhone/iPad
2. **Truy cập**: https://app.xoso66.com (hoặc domain của bạn)
3. **Nhấn nút Share** (biểu tượng mũi tên lên)
4. **Chọn "Add to Home Screen"**
5. **Nhấn "Add"**
6. **Icon XOSO66 xuất hiện trên Home Screen**
7. **Mở app từ Home Screen** - chạy fullscreen như app native!

### Hình Ảnh Hướng Dẫn

Tạo file `public/images/ios-install-guide.png` với screenshots:
- Bước 1: Safari với nút Share
- Bước 2: Menu "Add to Home Screen"
- Bước 3: Icon trên Home Screen
- Bước 4: App chạy fullscreen

## Bước 6: Tạo Landing Page với Hướng Dẫn

Update `public/index.html` với hướng dẫn cài đặt:

```html
<div class="install-guide" id="installGuide">
    <h2>Cài Đặt App XOSO66 trên iOS</h2>
    <ol>
        <li>Nhấn nút <img src="/images/share-icon.svg" alt="Share"> ở dưới cùng</li>
        <li>Chọn "Add to Home Screen"</li>
        <li>Nhấn "Add"</li>
        <li>Mở app từ Home Screen</li>
    </ol>
    <button onclick="hideGuide()">Đã hiểu</button>
</div>

<script>
// Detect if running as PWA
if (window.matchMedia('(display-mode: standalone)').matches) {
    // Running as PWA - hide install guide
    document.getElementById('installGuide').style.display = 'none';
}

// Detect iOS
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
if (!isIOS) {
    document.getElementById('installGuide').style.display = 'none';
}
</script>
```

## Bước 7: Test PWA

### Test trên iOS:

1. **Mở Safari** trên iPhone
2. **Truy cập domain**
3. **Kiểm tra**:
   - ✅ Icon hiển thị đúng
   - ✅ Có thể "Add to Home Screen"
   - ✅ Chạy fullscreen (không có Safari toolbar)
   - ✅ Hoạt động offline (nếu có Service Worker)
   - ✅ Hoạt động qua VPN

### Test PWA Features:

```bash
# Test manifest
curl https://app.xoso66.com/assets/images/site.webmanifest

# Test service worker
curl https://app.xoso66.com/sw.js

# Test icons
curl -I https://app.xoso66.com/assets/images/apple-touch-icon.png
```

## Bước 8: Tối Ưu PWA

### 1. Enable HTTPS (Bắt buộc cho PWA)

```bash
# Cài SSL certificate (Let's Encrypt)
certbot --nginx -d app.xoso66.com
```

### 2. Optimize Images

```bash
# Compress icons
cd /www/wwwroot/okwink6/app/xoso66.com/public/assets/images
optipng -o7 *.png
```

### 3. Add Offline Support

Update `sw.js` để cache API responses:

```javascript
// Cache API responses
self.addEventListener('fetch', event => {
  if (event.request.url.includes('/api/')) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, responseClone);
          });
          return response;
        })
        .catch(() => caches.match(event.request))
    );
  }
});
```

## So Sánh: Native App vs PWA

| Feature | Native iOS App | PWA |
|---------|---------------|-----|
| App Store | ✅ Cần | ❌ Không cần |
| Developer Account | ✅ $99/năm | ❌ Free |
| Review Process | ✅ 1-7 ngày | ❌ Instant |
| Update | ✅ Submit mới | ✅ Instant |
| VPN Support | ✅ Yes | ✅ Yes |
| Offline | ✅ Yes | ✅ Yes (với SW) |
| Push Notifications | ✅ Yes | ⚠️ Limited |
| Home Screen Icon | ✅ Yes | ✅ Yes |
| Fullscreen | ✅ Yes | ✅ Yes |
| File Access | ✅ Full | ⚠️ Limited |

## Kết Luận

**Khuyến nghị**: Sử dụng PWA cho iOS vì:
- ✅ Không cần App Store
- ✅ Deploy nhanh
- ✅ Update instant
- ✅ Hoạt động tốt qua VPN
- ✅ Chi phí $0

**Native iOS App** chỉ cần khi:
- Cần Push Notifications đầy đủ
- Cần truy cập hardware (camera, GPS, etc.)
- Muốn có mặt trên App Store

## Quick Commands

```bash
# Deploy PWA
cd /www/wwwroot/okwink6/app/xoso66.com
npm run build  # if using build process

# Copy to web root
cp -r public/* /var/www/html/

# Test PWA
curl https://app.xoso66.com
curl https://app.xoso66.com/site.webmanifest
curl https://app.xoso66.com/sw.js

# Check HTTPS
curl -I https://app.xoso66.com
```

## Support

PWA hoạt động tốt trên:
- ✅ iOS 11.3+ (Safari)
- ✅ Android (Chrome, Firefox)
- ✅ Desktop (Chrome, Edge, Firefox)

Không cần build native app! 🎉
