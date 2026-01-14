# PHÂN TÍCH SOURCE CODE - BELLY BLOOM APP

## 📋 TỔNG QUAN DỰ ÁN

**Tên ứng dụng**: Belly Bloom  
**Framework**: Flutter (SDK ^3.7.2)  
**Mục đích**: Ứng dụng hỗ trợ phụ nữ mang thai theo dõi thai kỳ, quản lý lịch hẹn, nhật ký và cẩm nang

---

## 🏗️ KIẾN TRÚC DỰ ÁN

### 1. Cấu trúc thư mục

```
lib/
├── main.dart                    # Entry point
├── model/                       # Data models
│   ├── user_account.dart
│   ├── appointment.dart
│   ├── form_collection.dart
│   ├── diary_model.dart
│   └── ...
├── screen/                      # UI Screens
│   ├── splash.dart
│   ├── login_page.dart
│   ├── Home_page.dart
│   ├── tab/
│   │   └── tab_home_page.dart
│   └── ...
├── service/                     # Business logic & Firebase services
│   ├── appointment_service.dart
│   ├── diary_service.dart
│   └── ...
├── servive/                     # Core services (typo: should be "service")
│   ├── base_common.dart
│   └── account_service.dart
├── utils/                       # Utility functions
│   └── util_common.dart
├── widgets/                     # Reusable widgets
└── resoucre/                    # Resources (typo: should be "resource")
    ├── ColorManager.dart
    ├── image_manager.dart
    └── reponsive_utils.dart
```

### 2. Design Pattern

- **Singleton Pattern**: `BaseCommon` sử dụng singleton để quản lý state toàn cục
- **Service Pattern**: Tách biệt business logic vào các service classes
- **Model-View Pattern**: Tách biệt data models và UI screens

---

## 🔑 CÁC THÀNH PHẦN CHÍNH

### 1. Main Entry Point (`main.dart`)

**Chức năng**:
- Khởi tạo Firebase (Core, Messaging)
- Cấu hình push notifications (FCM)
- Thiết lập local notifications
- Khởi tạo `BaseCommon`
- Đăng ký background message handler

**Điểm nổi bật**:
- Hỗ trợ foreground và background notifications
- Sử dụng `flutter_local_notifications` cho Android
- Cấu hình notification channel với high importance

### 2. BaseCommon (`servive/base_common.dart`)

**Chức năng**:
- Quản lý user session (Singleton)
- Lưu trữ thông tin user trong SharedPreferences
- Auto-login functionality
- Quản lý state toàn cục của ứng dụng

**Cấu trúc**:
```dart
class BaseCommon {
  static final BaseCommon _instance = BaseCommon._internal();
  UserAccount userAccount;
  SharedPreferences prefs;
  
  // Methods:
  - initBaseCommon()
  - saveUserAccount()
  - checkLogin()
  - clearUserAccount()
}
```

### 3. User Account Model (`model/user_account.dart`)

**Cấu trúc dữ liệu**:
```dart
class UserAccount {
  String name;
  String email;
  String? uid;
  FormCollection? formCollection;  // Thông tin thai kỳ
}
```

**FormCollection** chứa:
- `createdAt`: Ngày bắt đầu thai kỳ
- `week`: Tuần thai hiện tại
- `height`: Chiều cao
- `weight`: Cân nặng

### 4. Authentication Flow

**Luồng đăng nhập**:
1. `SplashPage` → Kiểm tra auto-login
2. Nếu có → `HomePage` hoặc `FormCollectionPage`
3. Nếu không → `LoginPage`
4. Sau khi login → Lưu credentials vào SharedPreferences

**Vấn đề bảo mật**:
- ⚠️ **Lưu password dạng plain text** trong SharedPreferences (rất nguy hiểm!)
- Nên sử dụng token-based authentication thay vì lưu password

### 5. Home Page Structure

**Bottom Navigation** với 3 tabs:
1. **Trang chủ** (`TabHomePage`)
2. **Lịch** (`SchedulePage`)
3. **Tài khoản** (`SettingPages`)

### 6. Tab Home Page (`screen/tab/tab_home_page.dart`)

**Các thành phần chính**:

#### a. Welcome Section
- Hiển thị tên người dùng
- Avatar/Logo

#### b. Count Days Widget
- Hiển thị ngày thứ X trong thai kỳ
- Hiển thị tuần thai hiện tại
- Tính toán dựa trên `createdAt` và `week` ban đầu

#### c. Thông tin bé
- Chiều cao (cm)
- Cân nặng (kg)
- Ngày còn lại đến ngày dự sinh

#### d. Lịch hẹn sắp tới
- Hiển thị 3 lịch hẹn gần nhất (trong 7 ngày)
- Pull từ Firebase Firestore
- Card design với màu sắc theo loại lịch hẹn

#### e. Tính năng
- **Quá trình**: `ProgressChartPage` (biểu đồ theo dõi)
- **Tất cả lịch**: `AppointmentPage`
- **Cẩm nang**: `GuidePage`
- **Nhật ký**: `DiaryPage`

**Logic tính toán thai kỳ**:
```dart
// Tính ngày hiện tại trong thai kỳ
currentDay = (week * 7) + daysFromCreatedAt

// Tính tuần hiện tại
currentWeek = currentDay ~/ 7

// Tính ngày còn lại
daysLeft = 280 - currentDay  // Thai kỳ = 280 ngày (40 tuần)
```

### 7. Appointment System

**Model** (`model/appointment.dart`):
```dart
class Appointment {
  String? id;
  String title;
  String description;
  DateTime dateTime;
  AppointmentType type;  // KHAM_BENH, NHAC_NHO, KHAC
  bool isReminder;
  int reminderMinutes;
  String? location;
  String? doctorName;
  String? notes;
}
```

**Service** (`service/appointment_service.dart`):
- `getAppointments()`: Lấy tất cả lịch hẹn
- `getUpcomingAppointments()`: Lấy lịch trong 7 ngày tới
- `addAppointment()`: Thêm lịch mới
- `updateAppointment()`: Cập nhật lịch
- `deleteAppointment()`: Xóa lịch
- `searchAppointments()`: Tìm kiếm lịch

**Firebase Collection**: `appointments`
- Filter theo `userId`
- Sort theo `dateTime`

---

## 🔥 FIREBASE INTEGRATION

### 1. Firebase Services Sử dụng

- **Firebase Core**: Khởi tạo Firebase
- **Firebase Auth**: Xác thực người dùng
- **Cloud Firestore**: Database cho appointments, diaries, blogs, etc.
- **Firebase Storage**: Lưu trữ files/images
- **Firebase Messaging**: Push notifications

### 2. Collections trong Firestore

- `users`: Thông tin người dùng
- `appointments`: Lịch hẹn
- `diaries`: Nhật ký
- `blogs`: Bài viết cẩm nang
- `exercises`: Bài tập
- `health_metrics`: Chỉ số sức khỏe

### 3. Push Notifications

**Cấu hình**:
- Android: Notification channel với high importance
- iOS: Foreground presentation options
- Background handler: `_firebaseMessagingBackgroundHandler`

**Vấn đề nghiêm trọng**:
- ⚠️ **Hardcoded OAuth access token** trong `tab_home_page.dart` (dòng 88)
- Token này có thể hết hạn và là lỗ hổng bảo mật lớn
- Nên sử dụng Firebase Admin SDK hoặc server-side để gửi notifications

---

## 📦 DEPENDENCIES

### Core Dependencies
- `firebase_core: ^4.1.1`
- `firebase_auth: ^6.1.0`
- `cloud_firestore: ^6.0.2`
- `firebase_storage: ^13.0.3`
- `firebase_messaging: ^16.0.4`

### UI & Utilities
- `flutter_quill: ^11.5.0` - Rich text editor
- `table_calendar: ^3.1.2` - Calendar widget
- `fl_chart: ^0.69.0` - Charts
- `numberpicker: ^2.1.2` - Number picker
- `file_picker: ^8.0.6` - File selection

### State & Storage
- `provider: ^6.1.1` - State management
- `shared_preferences: ^2.5.3` - Local storage

### Notifications
- `flutter_local_notifications: ^18.0.0` - Local notifications

---

## 🎨 UI/UX FEATURES

### 1. Responsive Design
- Sử dụng `UtilsReponsive` để tính toán kích thước responsive
- Hỗ trợ nhiều kích thước màn hình

### 2. Color Management
- `ColorManager` để quản lý màu sắc tập trung
- Primary color: Pink accent

### 3. Localization
- Hỗ trợ tiếng Việt
- Sử dụng `flutter_localizations`
- `FlutterQuillLocalizations` cho rich text editor

---

## ⚠️ VẤN ĐỀ VÀ CẢI THIỆN

### 1. Bảo mật (CRITICAL)

#### a. Lưu password dạng plain text
```dart
// ❌ KHÔNG AN TOÀN
await prefs.setString('password', password);
```
**Giải pháp**: 
- Sử dụng token-based authentication
- Lưu refresh token thay vì password
- Hoặc sử dụng biometric authentication

#### b. Hardcoded OAuth token
```dart
// ❌ RẤT NGUY HIỂM - Token trong source code
'Authorization': 'Bearer ya29.c.c0ASRK0GZGUZ8dOB0AI8OjaaaoIcRm9WhydmiB1gFqS_-OskA1-GeAXbn2RISecRMHCe8VSEGnHVXhZ2AsFgwqrHoE2AECprmWeACNacBy3jN82kLdENUFdLVnVUOwk18K9koW2_H-t9wy06fUwOwgR3L6ptrPjnn_NqsFU8PqJu5fmkw4tLU08Rc6hnNMLh4pFLb8U2EAI2lu6gBtlNfBrMS_RJo9Sbp9ipnMUgk8H3Wtbt7cZdBnkhU0LEZc_CLJSLDa6u3dOFzB3jA4OCH9Gwo-yBCGmlw1Iddzf2_UCvu5lYkCepruIEgMDcFV5bcn_GHDy-4RR5oJfWVTMNEJuD92cQeerirbqY7V-X6OAYvQkvJft0pr6PsvWQL387P4Vu8UlUJSX80y4Yi1uuearme8is7zjn943cmg6sZgko7f-8pJWerpjjysdpO6VqlpXV5pehbOhZp0lsUoonRlxa3-3wOSh-6zmddJj-Rg5QBqzeSy6Zicl2rfkj59Fyytllcok64gw9quseiWU3M49VF47X7u-kgFr2a-hmk53o0hvjOXJQYu_Q9Y8FZguus8cF13uewgWSbmYfM9znfOZj13r5203oIidib9jUo0vciOdonXO2SgOg0-edJUjFqqo0Qkrws33WJn0OX1RSk4htI9kizl6Ml4c6kk-MSebRfa_f1cWu3v8zz1Wsz4slW5z5Xb57YoV7xuRZbBF_SfpYwVXVRIprje2h165kuJq1MYvg8rWWRQtwFuzI0rjI9F2p6ZoaOydoS62UuMf91RnJ_yS1Zv121wjz1pvtzY-lrlvzcqhgngfaRW6iJx0yIWgedn9Y176X1bY4b3XQUtgRg2kVu3tyq5wQXSUJ4cfO7pJedxIcsqtYkrgWWw8u__tQyd3XxBeM5k8zrsQY4q1noh78wf_8xptIn5ebqey0bbu6dagZWQjjJIe-b7-O6bxe8ar8f_J9g-6JOzF6w7UQSwVOhhkjFqj4bkIuM0pV1txwysa_7uh-f'
```
**Giải pháp**:
- Xóa token khỏi source code
- Sử dụng Firebase Admin SDK trên server
- Hoặc sử dụng Firebase Cloud Functions để gửi notifications

### 2. Code Quality

#### a. Typo trong tên thư mục
- `servive/` → nên là `service/`
- `resoucre/` → nên là `resource/`

#### b. Naming Convention
- Một số file không tuân thủ naming: `Home_page.dart` → nên là `home_page.dart`
- `Sigin_page.dart` → nên là `signin_page.dart`

#### c. Code Organization
- Có thể tách logic tính toán thai kỳ vào service riêng
- Tách UI components thành widgets riêng để tái sử dụng

### 3. Performance

#### a. Rebuild không cần thiết
```dart
// Trong build() method
_calculatePregnancyInfo();  // Tính toán mỗi lần build
```
**Giải pháp**: Sử dụng `didChangeDependencies()` hoặc `initState()` thay vì tính trong `build()`

#### b. Firebase Queries
- Một số query có thể được optimize với indexes
- Nên sử dụng `limit()` cho queries lớn

### 4. Error Handling

- Một số service methods chỉ `print()` error thay vì throw exception
- Nên có error handling nhất quán trong toàn bộ app

---

## ✅ ĐIỂM MẠNH

1. **Cấu trúc rõ ràng**: Tách biệt models, services, screens
2. **Firebase Integration**: Sử dụng đầy đủ các Firebase services
3. **UI/UX**: Giao diện đẹp, responsive
4. **Tính năng đầy đủ**: Quản lý thai kỳ, lịch hẹn, nhật ký, cẩm nang
5. **Localization**: Hỗ trợ tiếng Việt

---

## 📝 KHUYẾN NGHỊ

### Ưu tiên cao (Security)
1. ✅ Xóa hardcoded OAuth token
2. ✅ Thay đổi cách lưu password (sử dụng token)
3. ✅ Implement proper error handling

### Ưu tiên trung bình (Code Quality)
1. ✅ Sửa typo trong tên thư mục
2. ✅ Chuẩn hóa naming convention
3. ✅ Tối ưu performance (tránh rebuild không cần thiết)
4. ✅ Thêm unit tests

### Ưu tiên thấp (Enhancement)
1. ✅ Thêm dark mode
2. ✅ Thêm offline support
3. ✅ Cải thiện animation/transitions
4. ✅ Thêm analytics

---

## 🔍 FLOW DIAGRAM

### Authentication Flow
```
SplashPage
  ↓
Check Auto-login (SharedPreferences)
  ↓
┌─────────────────┬─────────────────┐
│  Có credentials │  Không có       │
│       ↓         │       ↓         │
│  Login Firebase │  LoginPage      │
│       ↓         │       ↓         │
│  Get UserData   │  Register/Login │
│       ↓         │       ↓         │
│  Check FormCollection
│       ↓
│  ┌──────────────┴──────────────┐
│  │  Có formCollection          │
│  │       ↓                     │
│  │  HomePage                   │
│  │                             │
│  │  Chưa có                    │
│  │       ↓                     │
│  │  FormCollectionPage         │
│  └─────────────────────────────┘
```

### Home Page Flow
```
HomePage (Bottom Navigation)
  ├── TabHomePage
  │     ├── Welcome Section
  │     ├── Count Days Widget
  │     ├── Baby Info
  │     ├── Upcoming Appointments
  │     └── Features (Progress, Appointments, Guide, Diary)
  │
  ├── SchedulePage
  │     └── Calendar View
  │
  └── SettingPages
        └── Account Settings
```

---

## 📊 STATISTICS

- **Total Files**: ~50+ Dart files
- **Models**: 12 models
- **Screens**: 26 screens
- **Services**: 6 services
- **Widgets**: 6 reusable widgets
- **Dependencies**: 15+ packages

---

## 🎯 KẾT LUẬN

Đây là một ứng dụng Flutter được xây dựng khá tốt với cấu trúc rõ ràng và tính năng đầy đủ. Tuy nhiên, có một số vấn đề bảo mật nghiêm trọng cần được xử lý ngay lập tức, đặc biệt là việc lưu password dạng plain text và hardcoded OAuth token.

Sau khi sửa các vấn đề bảo mật, ứng dụng sẽ sẵn sàng cho production với một số cải thiện về code quality và performance.

---

*Phân tích được tạo vào: ${DateTime.now().toString()}*

