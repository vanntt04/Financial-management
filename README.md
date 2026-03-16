# Financial Management — Merged Project

Dự án hợp nhất từ **minhtri** (Auth + Category) và **viettung** (Transaction + Dashboard).

## Cấu trúc

```
Financial-management/
├── backend/          ← Spring Boot 4, Java 21
├── lib/              ← Flutter/Dart
│   ├── core/         ← TokenStorage, ApiClient, ApiException, ApiConstants
│   ├── models/       ← Data models
│   ├── providers/    ← FinanceProvider (state management)
│   ├── services/     ← AuthService, FinanceService, ApiService
│   └── screens/      ← Tất cả UI screens
└── pubspec.yaml
```

## API Endpoints

### Auth — KHÔNG cần token
| Method | URL | Mô tả |
|--------|-----|-------|
| POST | `/api/auth/register` | Đăng ký → gửi OTP email |
| POST | `/api/auth/verify-otp` | Xác thực OTP → trả JWT |
| POST | `/api/auth/resend-otp` | Gửi lại OTP |
| POST | `/api/auth/login` | Đăng nhập → JWT |
| POST | `/api/auth/forgot-password` | Gửi OTP reset mật khẩu |
| POST | `/api/auth/reset-password` | Đặt lại mật khẩu bằng OTP |
| POST | `/api/auth/refresh-token` | Làm mới access token |
| POST | `/api/auth/logout` | Đăng xuất |

### Finance — CẦN `Authorization: Bearer <token>`
| Method | URL | Mô tả |
|--------|-----|-------|
| GET | `/api/dashboard` | Tổng tài sản, thu/chi tháng, giao dịch gần đây |
| GET | `/api/accounts` | Danh sách hũ/tài khoản |
| GET | `/api/categories` | Danh mục (`?type=INCOME\|EXPENSE`) |
| POST | `/api/categories` | Tạo danh mục |
| PUT | `/api/categories/{id}` | Cập nhật danh mục |
| DELETE | `/api/categories/{id}` | Xóa danh mục |
| GET | `/api/transactions` | Danh sách giao dịch (`?type=ALL\|INCOME\|EXPENSE`) |
| POST | `/api/transactions` | Tạo giao dịch + cập nhật số dư |
| DELETE | `/api/transactions/{id}` | Xóa giao dịch + hoàn số dư |

## Cài đặt

### 1. Cấu hình Backend
Sửa `backend/src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=FinanceDB;encrypt=true;trustServerCertificate=true
spring.datasource.username=YOUR_USERNAME
spring.datasource.password=YOUR_PASSWORD

spring.mail.username=YOUR_GMAIL@gmail.com
spring.mail.password=YOUR_GMAIL_APP_PASSWORD
```

### 2. Chạy Backend
```bash
cd backend
./mvnw spring-boot:run
```

### 3. Chạy Flutter
```bash
flutter pub get
flutter run
```

> **Android emulator:** URL mặc định `http://10.0.2.2:8080/api`  
> **Web / máy thật:** Sửa `kBaseUrl` trong `lib/services/api_service.dart`

## Luồng hoạt động

```
Đăng ký → OTP Email → Verify OTP → JWT Token
                                        ↓
                              MainLayout (bottom nav)
                              ├── Dashboard  (số dư, thu/chi, giao dịch gần đây)
                              ├── Transactions (danh sách, thêm, xóa)
                              ├── Báo cáo
                              └── Cài đặt → Profile → Logout
```
