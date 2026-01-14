# PHÂN TÍCH PHẦN NHẬT KÝ THAI KỲ

## 📋 TỔNG QUAN

Phần nhật ký thai kỳ cho phép người dùng ghi lại những khoảnh khắc đáng nhớ trong quá trình mang thai, bao gồm nội dung văn bản và hình ảnh.

---

## 🏗️ KIẾN TRÚC

### 1. Cấu trúc Files

```
lib/
├── model/
│   ├── diary_model.dart          # Model chính cho nhật ký
│   └── diary.dart                 # Model phụ (có thể không dùng)
├── screen/
│   ├── diary_page.dart            # Trang danh sách nhật ký
│   ├── diary_form_page.dart       # Trang tạo/chỉnh sửa nhật ký
│   └── Diary_detail.dart          # Trang chi tiết nhật ký
├── service/
│   └── diary_service.dart        # Service xử lý CRUD và upload ảnh
└── widgets/
    └── diary_card.dart            # Widget hiển thị card nhật ký
```

---

## 📦 MODEL - DiaryModel

### Cấu trúc dữ liệu

```dart
class DiaryModel {
  String? id;                    // ID document trong Firestore
  String userId;                 // ID người dùng
  DateTime date;                 // Ngày viết nhật ký
  String content;                // Nội dung văn bản
  List<String> imageUrls;        // Danh sách URL ảnh từ Firebase Storage
  DateTime createdAt;            // Thời gian tạo
  DateTime updatedAt;            // Thời gian cập nhật cuối
}
```

### Helper Methods

1. **`formattedDate`**: Định dạng ngày (dd/MM/yyyy)
2. **`dayOfWeek`**: Thứ trong tuần (CN, T2, T3, ...)
3. **`isToday`**: Kiểm tra có phải hôm nay không
4. **`isYesterday`**: Kiểm tra có phải hôm qua không
5. **`relativeDate`**: Ngày tương đối ("Hôm nay", "Hôm qua", "X ngày trước", ...)

### Firestore Structure

```json
{
  "userId": "user_uid",
  "date": Timestamp,
  "content": "Nội dung nhật ký...",
  "imageUrls": ["url1", "url2", ...],
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

---

## 🔧 SERVICE - DiaryService

### Chức năng chính

#### 1. **getDiaries()**
- Lấy tất cả nhật ký của user hiện tại
- Filter theo `userId`
- Sort theo `date` (mới nhất trước)
- **Lưu ý**: Sort thủ công vì Firestore query không có `orderBy` (đã comment)

#### 2. **getDiaryForDate(DateTime date)**
- Lấy nhật ký cho một ngày cụ thể
- Sử dụng date range query (startOfDay đến endOfDay)
- Trả về `DiaryModel?` (null nếu không tìm thấy)

#### 3. **uploadImage(File imageFile, String diaryId)**
- Upload 1 ảnh lên Firebase Storage
- Path: `diaries/{userId}/{diaryId}/{timestamp}_filename`
- Trả về download URL

#### 4. **uploadImages(List<File> imageFiles, String diaryId)**
- Upload nhiều ảnh cùng lúc
- Sử dụng `uploadImage()` trong loop
- Trả về danh sách URLs

#### 5. **deleteImage(String imageUrl)**
- Xóa ảnh từ Firebase Storage
- Sử dụng `refFromURL()` để lấy reference

#### 6. **addDiary(DiaryModel diary)**
- Thêm nhật ký mới vào Firestore
- Trả về document ID

#### 7. **updateDiary(DiaryModel diary)**
- Cập nhật nhật ký hiện có
- Yêu cầu `diary.id` không null

#### 8. **deleteDiary(String diaryId)**
- Xóa nhật ký và tất cả ảnh liên quan
- Xóa ảnh từ Storage trước, sau đó xóa document

#### 9. **saveDiary()** ⭐ (Method chính)
- Tạo mới hoặc cập nhật nhật ký
- Xử lý upload ảnh tự động
- Logic:
  1. Nếu có `existingDiary` → update, ngược lại → create
  2. Upload ảnh mới (nếu có)
  3. Merge URLs ảnh cũ và mới
  4. Update document với content và imageUrls

#### 10. **removeImageFromDiary(String diaryId, String imageUrl)**
- Xóa 1 ảnh khỏi nhật ký
- Xóa URL khỏi list và xóa file từ Storage

---

## 🖥️ SCREEN - DiaryPage

### Chức năng

**Trang danh sách nhật ký** - Hiển thị tất cả nhật ký của user

### UI Components

1. **AppBar**
   - Title: "Nhật ký thai kỳ"
   - Action: IconButton "+" để tạo nhật ký hôm nay

2. **Header Info Card**
   - Icon book
   - Title và subtitle
   - Badge hiển thị số lượng nhật ký

3. **Content Area**
   - **Loading**: CircularProgressIndicator với text
   - **Empty State**: Icon, text, và button "Viết nhật ký hôm nay"
   - **List View**: 
     - RefreshIndicator (pull to refresh)
     - ListView.builder với DiaryCard
     - Sort mới nhất trước

4. **FloatingActionButton**
   - "Viết nhật ký" - Navigate đến DiaryFormPage

### State Management

```dart
List<DiaryModel> diaries = [];
bool isLoading = true;
```

### Methods

- `_loadDiaries()`: Load danh sách từ Firestore
- `_createDiaryForToday()`: Tạo nhật ký cho hôm nay
- `_editDiary(DiaryModel)`: Chỉnh sửa nhật ký
- `_showErrorSnackBar()`: Hiển thị lỗi

---

## ✏️ SCREEN - DiaryFormPage

### Chức năng

**Trang tạo/chỉnh sửa nhật ký** - Form để viết nhật ký

### Props

```dart
final DiaryModel? diary;        // null = tạo mới, có = chỉnh sửa
final DateTime? selectedDate;   // Ngày được chọn (mặc định: hôm nay)
```

### State

```dart
TextEditingController _contentController;
DateTime _selectedDate;
List<File> _selectedImages;        // Ảnh mới chọn
List<String> _existingImageUrls;  // Ảnh đã lưu
bool _isLoading;
bool _isUploading;
```

### UI Components

1. **AppBar**
   - Title: "Viết nhật ký" hoặc "Chỉnh sửa nhật ký"
   - Action: Button "Lưu" (hoặc loading indicator)

2. **Date Selector**
   - Icon calendar
   - Hiển thị ngày đã chọn
   - Tap để mở DatePicker

3. **Content Field**
   - TextField đa dòng (maxLines: 10)
   - Placeholder: "Viết về ngày hôm nay của bạn..."

4. **Images Section**
   - **Empty State**: Icon + text hướng dẫn
   - **Image Grid**: 
     - GridView 3 cột
     - Hiển thị ảnh đã lưu và ảnh mới chọn
     - Nút X để xóa từng ảnh
     - Loading overlay khi đang xóa ảnh

5. **FloatingActionButton**
   - Icon add_photo_alternate
   - Mở FilePicker để chọn ảnh

### Methods

- `_pickImages()`: Mở FilePicker (multiple images)
- `_removeSelectedImage()`: Xóa ảnh mới chọn (chưa upload)
- `_removeExistingImage()`: Xóa ảnh đã lưu (có upload và xóa từ Storage)
- `_selectDate()`: Mở DatePicker
- `_saveDiary()`: Lưu nhật ký (tạo mới hoặc update)

### Validation

- Yêu cầu: Có ít nhất content HOẶC ảnh
- Nếu cả 2 đều trống → hiển thị lỗi

---

## 🎴 WIDGET - DiaryCard

### Chức năng

**Card hiển thị nhật ký** trong danh sách

### Props

```dart
final DiaryModel diary;
final VoidCallback? onTap;
```

### UI Structure

1. **Header Section**
   - Background: primary color với opacity
   - **Date Circle**: 
     - Thứ trong tuần (CN, T2, ...)
     - Ngày (số)
   - **Date Info**:
     - formattedDate (dd/MM/yyyy)
     - relativeDate ("Hôm nay", "Hôm qua", ...)
   - **Badge "Hôm nay"**: Nếu `diary.isToday`

2. **Content Section**
   - **Text Content**: 
     - Hiển thị nếu có
     - Max 3 dòng, ellipsis
   - **Image Preview**:
     - Horizontal ListView
     - Hiển thị tối đa 3 ảnh đầu
     - Ảnh thứ 4+ hiển thị overlay "+X"
   - **Footer**:
     - Icon book + "Nhật ký"
     - Icon photo + số lượng ảnh (nếu có)
     - Arrow forward icon

### Image Preview Logic

```dart
// Chỉ hiển thị 3 ảnh đầu
itemCount: diary.imageUrls.length > 3 ? 3 : diary.imageUrls.length

// Ảnh thứ 3 hiển thị overlay "+X" nếu có nhiều hơn 3 ảnh
if (index == 2 && diary.imageUrls.length > 3)
  // Show overlay with "+X"
```

---

## 🔥 FIREBASE INTEGRATION

### Firestore Collection: `diaries`

**Structure**:
```
diaries/
  {diaryId}/
    userId: string
    date: Timestamp
    content: string
    imageUrls: string[]
    createdAt: Timestamp
    updatedAt: Timestamp
```

**Queries**:
- Filter: `where('userId', isEqualTo: userUid)`
- Date range: `where('date', isGreaterThanOrEqualTo: start)`
- Sort: Thủ công trong code (không dùng Firestore orderBy)

### Firebase Storage: `diaries/{userId}/{diaryId}/{filename}`

**Path Structure**:
```
diaries/
  {userId}/
    {diaryId}/
      {timestamp}_{originalFilename}
```

**Operations**:
- Upload: `putFile()`
- Delete: `refFromURL().delete()`
- Get URL: `getDownloadURL()`

---

## 📊 FLOW DIAGRAM

### Tạo nhật ký mới

```
User clicks "Viết nhật ký"
  ↓
DiaryFormPage (diary = null)
  ↓
User enters content / selects images / picks date
  ↓
Click "Lưu"
  ↓
DiaryService.saveDiary()
  ↓
Create document in Firestore (get diaryId)
  ↓
Upload images to Storage (if any)
  ↓
Update document with content + imageUrls
  ↓
Return to DiaryPage
  ↓
Refresh list (_loadDiaries)
```

### Chỉnh sửa nhật ký

```
User taps DiaryCard
  ↓
DiaryFormPage (diary = existing)
  ↓
Load existing content, images, date
  ↓
User modifies
  ↓
Click "Lưu"
  ↓
DiaryService.saveDiary(existingDiary)
  ↓
Upload new images (if any)
  ↓
Merge old + new imageUrls
  ↓
Update document
  ↓
Return to DiaryPage
  ↓
Refresh list
```

### Xóa ảnh

```
User clicks X on existing image
  ↓
DiaryService.removeImageFromDiary()
  ↓
Remove URL from imageUrls array
  ↓
Delete file from Storage
  ↓
Update document
  ↓
Update UI (remove from _existingImageUrls)
```

---

## ⚠️ VẤN ĐỀ VÀ CẢI THIỆN

### 1. Performance

#### a. Image Loading
- **Vấn đề**: Load tất cả ảnh cùng lúc trong grid
- **Giải pháp**: 
  - Sử dụng lazy loading
  - Thumbnail cho preview
  - Full image khi tap

#### b. List Pagination
- **Vấn đề**: Load tất cả nhật ký cùng lúc
- **Giải pháp**: 
  - Implement pagination (limit + startAfter)
  - Infinite scroll

### 2. Code Quality

#### a. Duplicate Code
- Có 2 model: `diary_model.dart` và `diary.dart`
- Nên kiểm tra và xóa model không dùng

#### b. Error Handling
- Một số methods chỉ log error, không throw
- Nên có error handling nhất quán

#### c. Firestore Query
- Sort thủ công thay vì dùng `orderBy`
- **Giải pháp**: 
  - Thêm Firestore index cho `date`
  - Sử dụng `orderBy('date', descending: true)`

### 3. UX Improvements

#### a. Image Upload Progress
- Không có progress indicator khi upload
- **Giải pháp**: 
  - Hiển thị progress bar
  - Upload từng ảnh với progress

#### b. Offline Support
- Không có offline caching
- **Giải pháp**: 
  - Sử dụng Firestore offline persistence
  - Cache images locally

#### c. Image Compression
- Upload ảnh gốc (có thể lớn)
- **Giải pháp**: 
  - Compress ảnh trước khi upload
  - Resize ảnh nếu quá lớn

### 4. Security

#### a. Storage Rules
- Cần kiểm tra Firebase Storage rules
- Đảm bảo chỉ user sở hữu mới có thể upload/xóa

#### b. Content Validation
- Không có validation cho content length
- **Giải pháp**: 
  - Giới hạn độ dài content
  - Sanitize input

---

## ✅ ĐIỂM MẠNH

1. **Cấu trúc rõ ràng**: Tách biệt model, service, screen, widget
2. **Tính năng đầy đủ**: CRUD + upload ảnh
3. **UI/UX tốt**: Card design đẹp, empty state, loading state
4. **Helper methods**: Relative date, formatted date rất hữu ích
5. **Image management**: Upload, delete, preview đầy đủ

---

## 📝 KHUYẾN NGHỊ

### Ưu tiên cao

1. ✅ Thêm Firestore index cho `date` field
2. ✅ Implement image compression trước khi upload
3. ✅ Thêm progress indicator cho upload
4. ✅ Kiểm tra và xóa model `diary.dart` nếu không dùng

### Ưu tiên trung bình

1. ✅ Implement pagination cho danh sách
2. ✅ Thêm offline support
3. ✅ Cải thiện error handling
4. ✅ Thêm validation cho content

### Ưu tiên thấp

1. ✅ Thêm tính năng tìm kiếm nhật ký
2. ✅ Thêm filter theo tháng/năm
3. ✅ Export nhật ký (PDF, text)
4. ✅ Thêm tags/categories cho nhật ký

---

## 🔍 STATISTICS

- **Total Files**: 7 files
- **Models**: 2 (1 chính, 1 có thể không dùng)
- **Screens**: 3 screens
- **Services**: 1 service với 10 methods
- **Widgets**: 1 reusable widget
- **Firebase Collections**: 1 (diaries)
- **Storage Paths**: `diaries/{userId}/{diaryId}/`

---

## 🎯 KẾT LUẬN

Phần nhật ký thai kỳ được xây dựng khá tốt với đầy đủ tính năng CRUD và quản lý ảnh. Code structure rõ ràng, UI/UX đẹp. Tuy nhiên, cần cải thiện về performance (pagination, image compression) và error handling để ứng dụng hoàn thiện hơn.

---

*Phân tích được tạo vào: ${DateTime.now().toString()}*

