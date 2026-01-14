# Phân Tích Chatbot Hiện Tại

## 📋 Tổng Quan

Chatbot trong ứng dụng "Belly Bloom" là một trợ lý ảo thông minh sử dụng Google Gemini AI để hỗ trợ người dùng trong việc chăm sóc thai kỳ. Chatbot được tích hợp vào ứng dụng thông qua một FloatingActionButton trên màn hình Home.

---

## 🏗️ Kiến Trúc

### 1. **Các Component Chính**

#### **ChatPage** (`lib/screen/chat_page.dart`)

- **Vai trò**: UI layer - Giao diện người dùng cho chatbot
- **Chức năng**:
  - Hiển thị danh sách tin nhắn (chat messages)
  - Input field để người dùng nhập câu hỏi
  - Xử lý gửi tin nhắn và nhận phản hồi
  - Hiển thị loading state khi đang xử lý
  - Quick questions (câu hỏi nhanh) khi chưa có tin nhắn
  - Action buttons để điều hướng đến exercises/blogs

#### **GeminiService** (`lib/service/gemini_service.dart`)

- **Vai trò**: Service layer - Xử lý logic AI và tích hợp với các services khác
- **Chức năng**:
  - Khởi tạo và quản lý Gemini AI model
  - Phân tích intent từ câu hỏi người dùng
  - Xử lý các intent khác nhau và trả về response phù hợp
  - Tích hợp với các services: AppointmentService, BlogService, ExerciseService

---

## 🔄 Luồng Hoạt Động

### **Flow chính:**

```
User Input → ChatPage._sendMessage()
  → GeminiService.analyzeIntent()
  → ChatIntent
  → GeminiService.handleIntent()
  → Response (String)
  → ChatPage hiển thị response
```

### **Chi tiết từng bước:**

1. **User nhập câu hỏi** → `_messageController.text`
2. **ChatPage gọi `_sendMessage()`**:
   - Thêm tin nhắn user vào danh sách
   - Set loading state = true
   - Gọi `GeminiService.analyzeIntent(text)`
3. **GeminiService phân tích intent**:
   - Gửi prompt đến Gemini AI với system prompt
   - Parse JSON response để lấy intent
   - Fallback về phân tích thủ công nếu không parse được JSON
   - Trả về `ChatIntent` object
4. **GeminiService xử lý intent**:
   - Dựa vào intent type, gọi handler tương ứng
   - Tích hợp với các services để lấy dữ liệu
   - Trả về response string
5. **ChatPage nhận response**:
   - Thêm tin nhắn bot vào danh sách
   - Set loading state = false
   - Hiển thị action button nếu cần (exercises/blogs)

---

## 🎯 Intent System

### **Các Intent được hỗ trợ:**

#### 1. **upcoming_appointments**

- **Mục đích**: Lấy lịch hẹn sắp tới
- **Trigger keywords**: "lịch hẹn", "lịch khám", "appointment", "hẹn sắp tới"
- **Handler**: `_handleUpcomingAppointments()`
- **Tích hợp**: `AppointmentService.getUpcomingAppointments()`
- **Response**: Danh sách lịch hẹn trong 7 ngày tới (tối đa 5 items)

#### 2. **current_week**

- **Mục đích**: Hiển thị tuần thai hiện tại
- **Trigger keywords**: "tuần thai", "tuần hiện tại", "đang ở tuần mấy"
- **Handler**: `_handleCurrentWeek()`
- **Tích hợp**: `BaseCommon().userAccount.formCollection`, `UtilsCommon`
- **Response**:
  - Tuần thai hiện tại
  - Ngày thứ trong thai kỳ
  - Ngày dự sinh
  - Số ngày còn lại

#### 3. **exercises**

- **Mục đích**: Lấy danh sách bài tập
- **Trigger keywords**: "bài tập", "exercise", "thể dục", "yoga"
- **Handler**: `_handleExercises(int? week)`
- **Tích hợp**: `ExerciseService.loadExercisesForWeek()` hoặc `loadExercises()`
- **Response**: Danh sách bài tập (có thể filter theo tuần)
- **Action**: Button "Xem bài tập" → Navigate đến `GuidePage` với tab exercises

#### 4. **blogs**

- **Mục đích**: Lấy danh sách cẩm nang
- **Trigger keywords**: "cẩm nang", "blog", "hướng dẫn", "tips"
- **Handler**: `_handleBlogs(int? week)`
- **Tích hợp**: `BlogService.loadBlogsForWeek()` hoặc `loadBlogs()`
- **Response**: Danh sách cẩm nang (có thể filter theo tuần)
- **Action**: Button "Xem cẩm nang" → Navigate đến `GuidePage` với tab blogs

#### 5. **general**

- **Mục đích**: Câu hỏi chung về thai kỳ
- **Trigger**: Tất cả các câu hỏi không thuộc các intent trên
- **Handler**: `_handleGeneralChat(String message)`
- **Tích hợp**: Gemini AI trực tiếp
- **Response**: Câu trả lời từ Gemini AI về thai kỳ

---

## 🔧 Các Tính Năng

### **1. Intent Analysis (Phân tích ý định)**

#### **Phương pháp chính:**

- Sử dụng Gemini AI với system prompt chi tiết
- Prompt yêu cầu AI trả về JSON với format cụ thể
- Parse JSON từ response để lấy intent

#### **Fallback mechanism:**

- Nếu không parse được JSON từ AI response
- Sử dụng `_fallbackIntentAnalysis()` với pattern matching
- Regex để extract tuần thai nếu có trong câu hỏi

#### **System Prompt:**

- Chứa thông tin người dùng (tên, tuần thai hiện tại)
- Định nghĩa rõ ràng các intent và cách nhận diện
- Hướng dẫn format JSON response

### **2. Context Awareness (Nhận thức ngữ cảnh)**

- **Tuần thai hiện tại**: Tự động lấy từ `BaseCommon().userAccount.formCollection`
- **Tên người dùng**: Hiển thị trong system prompt
- **Filter theo tuần**: Có thể extract tuần từ câu hỏi hoặc dùng tuần hiện tại

### **3. Integration với Services**

- **AppointmentService**: Lấy lịch hẹn sắp tới
- **BlogService**: Lấy cẩm nang theo tuần
- **ExerciseService**: Lấy bài tập theo tuần
- **BaseCommon**: Lấy thông tin user account

### **4. UI Features**

#### **Empty State:**

- Hiển thị khi chưa có tin nhắn
- Quick questions: "Tuần thai hiện tại?", "Lịch khám sắp tới?", "Dinh dưỡng thai kỳ", "Các triệu chứng"

#### **Message Bubbles:**

- User messages: Màu primary, align right
- Bot messages: Màu trắng, align left
- Avatar icons cho user và bot
- Timestamp cho mỗi tin nhắn

#### **Loading State:**

- Hiển thị "Đang suy nghĩ..." khi đang xử lý
- Disable input và send button khi loading

#### **Action Buttons:**

- Hiển thị khi response có `actionType` (exercises/blogs)
- Navigate đến `GuidePage` với tab và tuần tương ứng

---

## 📊 Data Models

### **ChatMessage**

```dart
class ChatMessage {
  final String text;           // Nội dung tin nhắn
  final bool isUser;           // true = user, false = bot
  final DateTime timestamp;    // Thời gian gửi
  final String? actionType;     // 'exercises' hoặc 'blogs'
  final int? actionWeek;        // Tuần nếu có
}
```

### **ChatIntent**

```dart
class ChatIntent {
  final String intent;         // Loại intent
  final String action;         // Hành động cần thực hiện
  final int? week;             // Tuần thai (optional)
}
```

---

## 🔐 Bảo Mật

### **Vấn đề hiện tại:**

- ⚠️ **API Key hardcoded** trong `GeminiService._apiKey`
- API key đang được commit vào Git (không an toàn)

### **Khuyến nghị:**

1. Sử dụng environment variables
2. Hoặc tạo file config riêng và thêm vào `.gitignore`
3. Sử dụng secure storage cho production

---

## 🎨 UI/UX

### **Điểm mạnh:**

- ✅ Giao diện đẹp, hiện đại
- ✅ Responsive với `UtilsReponsive`
- ✅ Loading states rõ ràng
- ✅ Empty state với quick questions
- ✅ Action buttons để điều hướng
- ✅ Auto-scroll khi có tin nhắn mới

### **Có thể cải thiện:**

- 🔄 Thêm typing indicator
- 🔄 Thêm khả năng xóa tin nhắn
- 🔄 Thêm lịch sử chat (lưu vào local storage/Firestore)
- 🔄 Thêm khả năng gửi hình ảnh
- 🔄 Thêm voice input
- 🔄 Thêm suggested replies

---

## 🐛 Error Handling

### **Hiện tại:**

- Try-catch trong các async methods
- Fallback về phân tích intent thủ công nếu AI fail
- Hiển thị message lỗi generic cho user
- Log errors để debug

### **Có thể cải thiện:**

- Error messages cụ thể hơn
- Retry mechanism
- Offline mode với cached responses
- Rate limiting để tránh spam API

---

## 📈 Performance

### **Hiện tại:**

- Model được khởi tạo một lần (singleton pattern)
- Không có caching cho responses
- Mỗi request gọi API mới

### **Có thể tối ưu:**

- Cache responses cho các câu hỏi thường gặp
- Debounce cho input
- Preload data cho quick questions
- Lazy loading cho message history

---

## 🔗 Tích Hợp

### **Với HomePage:**

- FloatingActionButton với icon `smart_toy`
- Chỉ hiển thị khi `currentIndex == 0` (tab Home)
- Navigate đến `ChatPage` khi click

### **Với GuidePage:**

- Action buttons từ chatbot navigate đến `GuidePage`
- Truyền `initialTab` (0 = blogs, 1 = exercises)
- Truyền `initialWeek` nếu có

---

## 📝 Code Quality

### **Điểm tốt:**

- ✅ Code được tổ chức rõ ràng
- ✅ Separation of concerns (UI vs Service)
- ✅ Comments và documentation
- ✅ Error handling cơ bản

### **Cần cải thiện:**

- 🔄 API key nên được quản lý tốt hơn
- 🔄 Có thể tách `ChatIntent` và `ChatMessage` ra file riêng
- 🔄 Thêm unit tests
- 🔄 Thêm integration tests

---

## 🚀 Hướng Phát Triển

### **Ngắn hạn:**

1. Fix bảo mật API key
2. Thêm lịch sử chat
3. Cải thiện error messages
4. Thêm typing indicator

### **Dài hạn:**

1. Voice input/output
2. Image recognition (upload ảnh siêu âm, hỏi về thai nhi)
3. Multi-turn conversations (nhớ context)
4. Personalized recommendations
5. Integration với health metrics
6. Chat history sync với Firestore

---

## 📚 Tài Liệu Tham Khảo

- `GEMINI_SETUP.md`: Hướng dẫn setup Gemini API
- `CLASS_DIAGRAM.md`: Sơ đồ class của ứng dụng
- Google Gemini AI Documentation

---

## 🎯 Kết Luận

Chatbot hiện tại là một implementation tốt với:

- ✅ Kiến trúc rõ ràng
- ✅ Tích hợp tốt với các services
- ✅ UI/UX đẹp
- ✅ Intent system linh hoạt

Cần cải thiện:

- 🔐 Bảo mật API key
- 📱 Thêm nhiều tính năng UX
- 🧪 Testing
- ⚡ Performance optimization

