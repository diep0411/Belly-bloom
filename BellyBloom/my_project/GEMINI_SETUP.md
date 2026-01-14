# Hướng dẫn cấu hình Gemini API

## Bước 1: Lấy API Key

1. Truy cập [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Đăng nhập bằng tài khoản Google
3. Click "Create API Key"
4. Copy API key được tạo

## Bước 2: Cấu hình API Key

Mở file `lib/service/gemini_service.dart` và thay thế:

```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY';
```

Thành:

```dart
static const String _apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

## Lưu ý bảo mật

⚠️ **QUAN TRỌNG**: Không commit API key vào Git!

Có thể sử dụng environment variables hoặc file config riêng:

```dart
// Sử dụng từ environment
static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
```

Hoặc tạo file `lib/config/gemini_config.dart`:

```dart
class GeminiConfig {
  static const String apiKey = 'YOUR_API_KEY_HERE';
}
```

## Prompt Template

Hệ thống sử dụng prompt template để nhận diện các intent:

1. **upcoming_appointments**: Lịch hẹn sắp tới
2. **current_week**: Tuần thai hiện tại
3. **exercises**: Bài tập (có thể filter theo tuần)
4. **blogs**: Cẩm nang (có thể filter theo tuần)
5. **general**: Câu hỏi chung về thai kỳ

Prompt được định nghĩa trong `GeminiService._getSystemPrompt()`

