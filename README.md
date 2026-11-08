# FinNest Mobile

Ứng dụng Flutter cho FinNest. Có thể chạy trên Android hoặc Chrome để xem và chỉnh giao diện mobile.

## Chạy trên Chrome (backend cùng máy)

Giữ backend chạy ở cổng **8081**, rồi chạy trong PowerShell:

```powershell
cd "D:\Nam Cuoi\Frontend-Mobile"
& "C:\Users\ADMIN\Downloads\flutter_windows_3.47.7-stable\flutter\bin\flutter.bat" run -d chrome --dart-define=API_BASE_URL=http://localhost:8081/api/v1
```

Nếu Flutter đã có trong PATH, dùng `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8081/api/v1`.
Khi mở riêng repo mobile bằng VS Code, có thể chọn cấu hình **FinNest Mobile - Chrome (local backend)** trong Run and Debug.

Chrome dùng `localhost:8081`; `10.0.2.2` dành cho máy ảo Android Studio. File `env.json` chứa cấu hình LAN cho APK/thiết bị khác; không dùng file đó khi chạy Chrome trên cùng máy. Địa chỉ LAN có thể đổi khi chuyển Wi-Fi.

`API_BASE_URL` được đọc khi biên dịch. Sau khi đổi địa chỉ API, dừng phiên Flutter cũ và chạy lại lệnh; hot reload không thay đổi giá trị đã biên dịch.

## Chạy trên Android

Máy ảo Android Studio mặc định dùng `http://10.0.2.2:8081/api/v1`. Với LDPlayer hoặc điện thoại, kiểm tra IP máy chạy backend trong `env.json` trước khi chạy/build:

```powershell
flutter run --dart-define-from-file=env.json
flutter build apk --release --dart-define-from-file=env.json
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
