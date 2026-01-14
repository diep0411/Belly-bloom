# PHÂN TÍCH GUIDE_PAGE.DART - LOAD CẨM NANG

## 📋 TỔNG QUAN

`GuidePage` là màn hình hiển thị cẩm nang thai kỳ và bài tập cho người dùng trong ứng dụng mobile (`my_project`). Trang này có 2 tabs:
- **Tab 1: Cẩm nang** - Hiển thị các bài viết blog
- **Tab 2: Bài tập** - Hiển thị các bài tập thể dục

---

## 🔍 PHÂN TÍCH CHI TIẾT

### 1. **Cấu trúc dữ liệu**

#### **BlogModel** (`my_project/lib/model/blog_model.dart`)
```dart
class BlogModel {
  String? id;
  String title;
  String subtitle;
  String content;        // Lưu dưới dạng JSON Delta (từ Flutter Quill)
  String imageUrl;
  DateTime createdAt;    // ⚠️ babyweb KHÔNG lưu field này
  DateTime updatedAt;    // ⚠️ babyweb KHÔNG lưu field này
}
```

#### **BlogModel** (`babyweb/lib/model/blog_model.dart`)
```dart
class BlogModel {
  String? id;
  String title;
  String subtitle;
  String content;        // JSON Delta từ Flutter Quill
  String imageUrl;
  // ❌ THIẾU: createdAt, updatedAt
  // ❌ THIẾU: targetWeeks (field để link với tuần thai kỳ)
}
```

---

### 2. **Cách load cẩm nang**

#### **Flow trong GuidePage:**

```dart
// 1. Lấy tuần thai kỳ hiện tại của user
currentWeek = BaseCommon().userAccount.formCollection?.week ?? 0;

// 2. Load blogs theo logic:
if (isFilteringByWeek && selectedWeek > 0) {
  blogs = await BlogService.loadBlogsForWeek(selectedWeek);
} else if (currentWeek > 0) {
  blogs = await BlogService.loadBlogsForWeek(currentWeek);
} else {
  blogs = await BlogService.loadBlogs(); // Load tất cả
}
```

#### **BlogService.loadBlogsForWeek():**
```dart
static Future<List<BlogModel>> loadBlogsForWeek(int weekNumber) async {
  final allBlogs = await loadBlogs();
  return allBlogs.where((blog) => blog.isForWeek(weekNumber)).toList();
}
```

#### **BlogModel.isForWeek():**
```dart
bool isForWeek(int weekNumber) {
  String weekStr = weekNumber.toString();
  return title.toLowerCase().contains('tuần $weekStr') ||
         title.toLowerCase().contains('week $weekStr') ||
         subtitle.toLowerCase().contains('tuần $weekStr') ||
         subtitle.toLowerCase().contains('week $weekStr') ||
         content.toLowerCase().contains('tuần $weekStr') ||
         content.toLowerCase().contains('week $weekStr');
}
```

---

### 3. **VẤN ĐỀ PHÁT HIỆN**

#### ⚠️ **Vấn đề 1: Model không tương thích**

| Field | babyweb | my_project | Vấn đề |
|-------|---------|------------|--------|
| `createdAt` | ❌ Không có | ✅ Có | my_project sẽ lỗi khi parse |
| `updatedAt` | ❌ Không có | ✅ Có | my_project sẽ lỗi khi parse |
| `targetWeeks` | ❌ Không có | ❌ Không có | Không có cách chính xác để link blog với tuần |

**Hậu quả:**
- Khi `my_project` load blog từ Firestore, nó sẽ cố parse `createdAt` và `updatedAt`
- Nếu babyweb không lưu 2 field này → **CRASH** hoặc parse sai

#### ⚠️ **Vấn đề 2: Filter theo tuần không chính xác**

**Cách hiện tại:**
- Tìm kiếm text "tuần X" hoặc "week X" trong title/subtitle/content
- **Vấn đề:**
  - Không chính xác (có thể match nhầm)
  - Phụ thuộc vào cách admin đặt tên
  - Không thể filter chính xác nếu blog không chứa text "tuần X"

**Ví dụ:**
- Blog title: "Dinh dưỡng cho mẹ bầu" → Không match với bất kỳ tuần nào
- Blog title: "Tuần 12: Phát triển của thai nhi" → Match với tuần 12
- Blog title: "Chăm sóc tuần 12-15" → Match với tuần 12, 13, 14, 15 (sai)

#### ⚠️ **Vấn đề 3: Content format**

- **babyweb** lưu content dưới dạng **JSON Delta** (từ Flutter Quill)
- **my_project** hiển thị content như plain text
- **BlogCard** có method `_getContentPreview()` để remove HTML tags, nhưng JSON Delta không phải HTML

---

### 4. **SO SÁNH VỚI BABYWEB**

#### **Cách babyweb filter blog cho tuần:**

Trong `blogs_for_week_dialog.dart`:
```dart
List<BlogModel> allBlogs = await BlogService.loadBlog();
blogs = allBlogs.where((blog) {
  String weekNumber = widget.week.weekNumber.toString();
  return blog.title.toLowerCase().contains('tuần $weekNumber') ||
         blog.title.toLowerCase().contains('week $weekNumber') ||
         blog.subtitle.toLowerCase().contains('tuần $weekNumber') ||
         blog.subtitle.toLowerCase().contains('week $weekNumber') ||
         blog.content.toLowerCase().contains('tuần $weekNumber') ||
         blog.content.toLowerCase().contains('week $weekNumber');
}).toList();
```

**→ Cùng logic với my_project!** Nhưng vẫn có vấn đề về độ chính xác.

---

## 🔧 GIẢI PHÁP ĐỀ XUẤT

### **Giải pháp 1: Cập nhật BlogModel trong babyweb**

Thêm các field cần thiết:

```dart
class BlogModel {
  String? id;
  String title;
  String subtitle;
  String content;
  String imageUrl;
  List<int> targetWeeks;  // ✅ THÊM: Danh sách tuần thai kỳ
  DateTime createdAt;      // ✅ THÊM
  DateTime updatedAt;      // ✅ THÊM
}
```

**Cập nhật BlogService trong babyweb:**
```dart
static Future<bool> addBlog(BlogModel blog) async {
  try {
    final data = blog.toJson();
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await FirebaseFirestore.instance.collection(blogCollection).add(data);
    return true;
  } catch (e) {
    return false;
  }
}
```

### **Giải pháp 2: Cập nhật BlogModel trong my_project**

Thêm field `targetWeeks` và cập nhật method `isForWeek()`:

```dart
class BlogModel {
  // ... existing fields
  List<int> targetWeeks;  // ✅ THÊM
  
  bool isForWeek(int weekNumber) {
    // Ưu tiên check targetWeeks trước
    if (targetWeeks.isNotEmpty) {
      return targetWeeks.contains(weekNumber);
    }
    // Fallback về text search (backward compatible)
    String weekStr = weekNumber.toString();
    return title.toLowerCase().contains('tuần $weekStr') ||
           // ... existing logic
  }
}
```

### **Giải pháp 3: Cập nhật ContentPage trong babyweb**

Thêm UI để chọn tuần thai kỳ khi tạo blog:

```dart
// Trong dialog tạo blog
MultiSelectChip(
  label: 'Tuần thai kỳ phù hợp',
  options: List.generate(40, (i) => i + 1),
  selectedValues: targetWeeks,
  onSelectionChanged: (values) {
    setState(() {
      targetWeeks = values;
    });
  },
)
```

### **Giải pháp 4: Parse JSON Delta content**

Cập nhật `BlogCard` trong my_project để parse JSON Delta:

```dart
String _getContentPreview(String content) {
  try {
    // Try to parse as JSON Delta
    final json = jsonDecode(content);
    if (json is Map && json.containsKey('ops')) {
      // Extract plain text from Delta operations
      String plainText = '';
      for (var op in json['ops']) {
        if (op['insert'] is String) {
          plainText += op['insert'];
        }
      }
      if (plainText.length > 150) {
        return '${plainText.substring(0, 150)}...';
      }
      return plainText;
    }
  } catch (e) {
    // Fallback to existing HTML removal logic
  }
  
  // Existing logic for HTML/plain text
  String plainText = content
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  
  if (plainText.length > 150) {
    return '${plainText.substring(0, 150)}...';
  }
  return plainText;
}
```

---

## 📊 SƠ ĐỒ DATA FLOW

```
┌─────────────────┐
│   babyweb       │
│  (Admin Panel)  │
└────────┬────────┘
         │
         │ Tạo blog với:
         │ - title, subtitle, content (JSON Delta)
         │ - imageUrl
         │ - ❌ Thiếu createdAt, updatedAt
         │ - ❌ Thiếu targetWeeks
         │
         ▼
┌─────────────────┐
│  Cloud Firestore│
│   Collection:   │
│     "blogs"     │
└────────┬────────┘
         │
         │ Load blogs
         │
         ▼
┌─────────────────┐
│   my_project    │
│  (Mobile App)   │
└────────┬────────┘
         │
         │ Parse BlogModel:
         │ - ✅ title, subtitle, content, imageUrl
         │ - ❌ createdAt → CRASH (null/undefined)
         │ - ❌ updatedAt → CRASH (null/undefined)
         │
         │ Filter by week:
         │ - Text search "tuần X" trong title/subtitle/content
         │ - ❌ Không chính xác
         │
         ▼
┌─────────────────┐
│   GuidePage     │
│  - Tab Cẩm nang │
│  - Tab Bài tập  │
└─────────────────┘
```

---

## 🎯 KẾT LUẬN

### **Tình trạng hiện tại:**
1. ✅ **Cơ bản hoạt động**: my_project có thể load và hiển thị blogs từ babyweb
2. ⚠️ **Có lỗi tiềm ẩn**: Thiếu `createdAt`/`updatedAt` có thể gây crash
3. ⚠️ **Filter không chính xác**: Dựa vào text search, không reliable
4. ⚠️ **Content format**: JSON Delta chưa được parse đúng

### **Khuyến nghị:**
1. **Ưu tiên cao**: Cập nhật babyweb để lưu `createdAt`, `updatedAt`, `targetWeeks`
2. **Ưu tiên trung bình**: Cập nhật my_project để parse JSON Delta
3. **Ưu tiên thấp**: Cải thiện UI để admin chọn tuần khi tạo blog

---

## 📝 CHECKLIST CẦN LÀM

### **babyweb:**
- [ ] Thêm field `targetWeeks: List<int>` vào BlogModel
- [ ] Thêm field `createdAt: DateTime` vào BlogModel
- [ ] Thêm field `updatedAt: DateTime` vào BlogModel
- [ ] Cập nhật `BlogService.addBlog()` để tự động set createdAt/updatedAt
- [ ] Cập nhật `BlogService.updateBlog()` để tự động set updatedAt
- [ ] Thêm UI trong ContentPage để chọn tuần thai kỳ
- [ ] Cập nhật `toJson()` và `fromJson()` methods

### **my_project:**
- [ ] Cập nhật BlogModel để có `targetWeeks` (optional, backward compatible)
- [ ] Cập nhật `isForWeek()` để ưu tiên check `targetWeeks`
- [ ] Cập nhật `fromJson()` để handle missing `createdAt`/`updatedAt` (fallback)
- [ ] Cập nhật `BlogCard._getContentPreview()` để parse JSON Delta
- [ ] Test với data từ babyweb

---

*Phân tích được tạo vào: $(date)*

