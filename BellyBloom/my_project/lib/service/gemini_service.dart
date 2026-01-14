import 'dart:convert';
import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:my_project/model/blog_model.dart';
import 'package:my_project/model/exercise_model.dart';
import 'package:my_project/service/appointment_service.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/service/blog_service.dart';
import 'package:my_project/service/exercise_service.dart';
import 'package:my_project/utils/util_common.dart';

class GeminiService {
  static const String _apiKey =
      'AIzaSyA83DTHC_fX0XFiBv_k8oAkif1vbppXxow'; 
  static GenerativeModel? _model;

  static void initialize() {
    _model ??= GenerativeModel(
      model: 'models/gemini-2.0-flash',
      apiKey: _apiKey,
    );
  }

  // System prompt để nhận diện intent và xử lý
  static String _getSystemPrompt() {
    final formCollection = BaseCommon().userAccount.formCollection;
    final currentWeek =
        formCollection != null
            ? UtilsCommon.getCurrentWeekInPregnancy(
              formCollection.createdAt,
              formCollection.week,
            )
            : 0;

    return '''
Bạn là trợ lý ảo thông minh cho ứng dụng chăm sóc thai kỳ "Belly Bloom". 
Nhiệm vụ của bạn là giúp người dùng với các câu hỏi về thai kỳ, lịch hẹn, bài tập và cẩm nang.

THÔNG TIN NGƯỜI DÙNG:
- Tuần thai hiện tại: $currentWeek
- Tên: ${BaseCommon().userAccount.name}

CÁC CHỨC NĂNG BẠN CÓ THỂ XỬ LÝ:

1. **LỊCH HẸN SẮP TỚI** (Intent: upcoming_appointments)
   - Khi người dùng hỏi về: "lịch hẹn", "lịch khám", "appointment", "hẹn sắp tới", "lịch sắp tới"
   - Trả về JSON: {"intent": "upcoming_appointments", "action": "get_upcoming_appointments"}

2. **TUẦN THAI HIỆN TẠI** (Intent: current_week)
   - Khi người dùng hỏi về: "tuần thai", "tuần hiện tại", "đang ở tuần mấy", "current week"
   - Trả về JSON: {"intent": "current_week", "action": "get_current_week"}

3. **BÀI TẬP** (Intent: exercises)
   - Khi người dùng hỏi về: "bài tập", "exercise", "thể dục", "vận động", "yoga"
   - Có thể hỏi theo tuần: "bài tập tuần X", "exercise week X"
   - Trả về JSON: {"intent": "exercises", "action": "get_exercises", "week": X (optional)}

4. **CẨM NANG** (Intent: blogs)
   - Khi người dùng hỏi về: "cẩm nang", "blog", "hướng dẫn", "tips", "lời khuyên"
   - Có thể hỏi theo tuần: "cẩm nang tuần X", "blog week X"
   - Trả về JSON: {"intent": "blogs", "action": "get_blogs", "week": X (optional)}

5. **CÂU HỎI CHUNG** (Intent: general)
   - Các câu hỏi khác về thai kỳ, sức khỏe, dinh dưỡng
   - Trả về JSON: {"intent": "general", "action": "chat"}

QUY TẮC:
- Luôn trả về JSON với format trên
- Nếu không chắc chắn intent, trả về "general"
- Nếu có số tuần trong câu hỏi, extract và thêm vào field "week"
- Trả lời bằng tiếng Việt, thân thiện và chuyên nghiệp
- Nếu là intent cần data (exercises, blogs), chỉ trả về JSON, không cần giải thích dài
''';
  }

  // Phân tích intent từ câu hỏi
  static Future<ChatIntent> analyzeIntent(String userMessage) async {
    try {
      initialize();
      if (_model == null) {
        return ChatIntent(intent: 'general', action: 'chat', week: null);
      }

      final prompt = '''
${_getSystemPrompt()}

NGƯỜI DÙNG HỎI: "$userMessage"

Hãy phân tích và trả về JSON theo format đã định nghĩa. CHỈ TRẢ VỀ JSON, KHÔNG CÓ TEXT KHÁC.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final text = response.text ?? '';

      log('Gemini response: $text');

      // Parse JSON từ response
      try {
        // Tìm JSON trong response (có thể có text thêm)
        final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(text);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;

          return ChatIntent(
            intent: json['intent'] as String? ?? 'general',
            action: json['action'] as String? ?? 'chat',
            week:
                json['week'] != null
                    ? int.tryParse(json['week'].toString())
                    : null,
          );
        }
      } catch (e) {
        log('Error parsing JSON: $e');
      }

      // Fallback: Phân tích thủ công nếu không parse được JSON
      return _fallbackIntentAnalysis(userMessage);
    } catch (e) {
      log('Error analyzing intent: $e');
      return _fallbackIntentAnalysis(userMessage);
    }
  }

  // Fallback: Phân tích intent thủ công
  static ChatIntent _fallbackIntentAnalysis(String message) {
    final lowerMessage = message.toLowerCase();

    // Lịch hẹn
    if (lowerMessage.contains('lịch hẹn') ||
        lowerMessage.contains('lịch khám') ||
        lowerMessage.contains('appointment') ||
        lowerMessage.contains('hẹn sắp tới')) {
      return ChatIntent(
        intent: 'upcoming_appointments',
        action: 'get_upcoming_appointments',
      );
    }

    // Tuần thai
    if (lowerMessage.contains('tuần thai') ||
        lowerMessage.contains('tuần hiện tại') ||
        lowerMessage.contains('đang ở tuần')) {
      return ChatIntent(intent: 'current_week', action: 'get_current_week');
    }

    // Bài tập
    if (lowerMessage.contains('bài tập') ||
        lowerMessage.contains('exercise') ||
        lowerMessage.contains('thể dục') ||
        lowerMessage.contains('yoga')) {
      final weekMatch = RegExp(r'tuần\s*(\d+)').firstMatch(lowerMessage);
      final week = weekMatch != null ? int.tryParse(weekMatch.group(1)!) : null;
      return ChatIntent(
        intent: 'exercises',
        action: 'get_exercises',
        week: week,
      );
    }

    // Cẩm nang
    if (lowerMessage.contains('cẩm nang') ||
        lowerMessage.contains('blog') ||
        lowerMessage.contains('hướng dẫn') ||
        lowerMessage.contains('tips')) {
      final weekMatch = RegExp(r'tuần\s*(\d+)').firstMatch(lowerMessage);
      final week = weekMatch != null ? int.tryParse(weekMatch.group(1)!) : null;
      return ChatIntent(intent: 'blogs', action: 'get_blogs', week: week);
    }

    return ChatIntent(intent: 'general', action: 'chat');
  }

  // Xử lý intent và trả về response
  static Future<String> handleIntent(
    ChatIntent intent,
    String originalMessage,
  ) async {
    try {
      switch (intent.intent) {
        case 'upcoming_appointments':
          return await _handleUpcomingAppointments();

        case 'current_week':
          return await _handleCurrentWeek();

        case 'exercises':
          return await _handleExercises(intent.week);

        case 'blogs':
          return await _handleBlogs(intent.week);

        case 'general':
        default:
          return await _handleGeneralChat(originalMessage);
      }
    } catch (e) {
      log('Error handling intent: $e');
      return 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại sau.';
    }
  }

  // Xử lý lịch hẹn sắp tới
  static Future<String> _handleUpcomingAppointments() async {
    try {
      final appointments = await AppointmentService.getUpcomingAppointments();

      if (appointments.isEmpty) {
        return 'Bạn chưa có lịch hẹn nào trong 7 ngày tới. Hãy tạo lịch hẹn mới trong phần "Tất cả lịch" nhé!';
      }

      final buffer = StringBuffer();
      buffer.writeln('📅 Bạn có ${appointments.length} lịch hẹn sắp tới:\n');

      for (var i = 0; i < appointments.length && i < 5; i++) {
        final apt = appointments[i];
        final dateStr =
            '${apt.dateTime.day}/${apt.dateTime.month}/${apt.dateTime.year}';
        final timeStr =
            '${apt.dateTime.hour.toString().padLeft(2, '0')}:${apt.dateTime.minute.toString().padLeft(2, '0')}';

        buffer.writeln('${i + 1}. **${apt.title}**');
        buffer.writeln('   📆 $dateStr lúc $timeStr');
        if (apt.location != null && apt.location!.isNotEmpty) {
          buffer.writeln('   📍 ${apt.location}');
        }
        buffer.writeln('');
      }

      if (appointments.length > 5) {
        buffer.writeln('... và ${appointments.length - 5} lịch hẹn khác.');
      }

      return buffer.toString();
    } catch (e) {
      log('Error getting appointments: $e');
      return 'Không thể tải lịch hẹn. Vui lòng thử lại sau.';
    }
  }

  // Xử lý tuần thai hiện tại
  static Future<String> _handleCurrentWeek() async {
    try {
      final formCollection = BaseCommon().userAccount.formCollection;
      if (formCollection == null) {
        return 'Bạn chưa cập nhật thông tin thai kỳ. Vui lòng cập nhật trong phần "Thông tin cá nhân".';
      }

      final currentWeek = UtilsCommon.getCurrentWeekInPregnancy(
        formCollection.createdAt,
        formCollection.week,
      );

      final currentDay = UtilsCommon.getCurrentDayInPregnancy(
        formCollection.createdAt,
        formCollection.week,
      );

      final dueDate = UtilsCommon.calculateDueDate(DateTime.now(), currentWeek);
      final daysLeft = UtilsCommon.getPregnancyDay(
        formCollection.createdAt,
        formCollection.week,
      );

      return '''
📊 **Thông tin thai kỳ của bạn:**

👶 Tuần thai hiện tại: **Tuần $currentWeek**
📅 Ngày thứ: **$currentDay** (trong tổng 280 ngày)
🎯 Ngày dự sinh: **${dueDate.day}/${dueDate.month}/${dueDate.year}**
⏰ Còn lại: **$daysLeft ngày**

Chúc bạn có một thai kỳ khỏe mạnh! 💕
''';
    } catch (e) {
      log('Error getting current week: $e');
      return 'Không thể lấy thông tin tuần thai. Vui lòng thử lại sau.';
    }
  }

  // Xử lý bài tập
  static Future<String> _handleExercises(int? week) async {
    try {
      final formCollection = BaseCommon().userAccount.formCollection;
      final targetWeek =
          week ??
          (formCollection != null
              ? UtilsCommon.getCurrentWeekInPregnancy(
                formCollection.createdAt,
                formCollection.week,
              )
              : null);

      List<ExerciseModel> exercises;
      if (targetWeek != null) {
        exercises = await ExerciseService.loadExercisesForWeek(targetWeek);
      } else {
        exercises = await ExerciseService.loadExercises();
      }

      if (exercises.isEmpty) {
        return 'Không tìm thấy bài tập nào${targetWeek != null ? " cho tuần $targetWeek" : ""}.';
      }

      final buffer = StringBuffer();
      buffer.writeln(
        '💪 ${exercises.length} bài tập${targetWeek != null ? " cho tuần $targetWeek" : ""}:\n',
      );

      for (var i = 0; i < exercises.length && i < 5; i++) {
        final ex = exercises[i];
        buffer.writeln('${i + 1}. **${ex.title}**');
        buffer.writeln('   📝 ${ex.description}');
        buffer.writeln('   ⏱️ ${ex.duration} phút | 🎯 ${ex.difficulty}');
        buffer.writeln('');
      }

      if (exercises.length > 5) {
        buffer.writeln('... và ${exercises.length - 5} bài tập khác.');
      }

      buffer.writeln('\n💡 Xem chi tiết trong phần "Cẩm nang" > "Bài tập"');

      return buffer.toString();
    } catch (e) {
      log('Error getting exercises: $e');
      return 'Không thể tải bài tập. Vui lòng thử lại sau.';
    }
  }

  // Xử lý cẩm nang
  static Future<String> _handleBlogs(int? week) async {
    try {
      final formCollection = BaseCommon().userAccount.formCollection;
      final targetWeek =
          week ??
          (formCollection != null
              ? UtilsCommon.getCurrentWeekInPregnancy(
                formCollection.createdAt,
                formCollection.week,
              )
              : null);

      List<BlogModel> blogs;
      if (targetWeek != null) {
        blogs = await BlogService.loadBlogsForWeek(targetWeek);
      } else {
        blogs = await BlogService.loadBlogs();
      }

      if (blogs.isEmpty) {
        return 'Không tìm thấy cẩm nang nào${targetWeek != null ? " cho tuần $targetWeek" : ""}.';
      }

      final buffer = StringBuffer();
      buffer.writeln(
        '📚 ${blogs.length} cẩm nang${targetWeek != null ? " cho tuần $targetWeek" : ""}:\n',
      );

      for (var i = 0; i < blogs.length && i < 5; i++) {
        final blog = blogs[i];
        buffer.writeln('${i + 1}. **${blog.title}**');
        buffer.writeln('   ${blog.subtitle}');
        buffer.writeln('');
      }

      if (blogs.length > 5) {
        buffer.writeln('... và ${blogs.length - 5} cẩm nang khác.');
      }

      buffer.writeln('\n💡 Xem chi tiết trong phần "Cẩm nang" > "Cẩm nang"');

      return buffer.toString();
    } catch (e) {
      log('Error getting blogs: $e');
      return 'Không thể tải cẩm nang. Vui lòng thử lại sau.';
    }
  }

  // Xử lý câu hỏi chung - Khi không có data trong hệ thống, gửi lên Gemini
  static Future<String> _handleGeneralChat(String message) async {
    try {
      initialize();
      if (_model == null) {
        log('Gemini model is null, cannot process general chat');
        return 'Xin lỗi, tôi chưa thể trả lời câu hỏi này. Vui lòng thử lại sau.';
      }

      log('Processing general chat - sending to Gemini: $message');

      // Lấy thông tin người dùng để cung cấp context cho Gemini
      final formCollection = BaseCommon().userAccount.formCollection;
      final currentWeek =
          formCollection != null
              ? UtilsCommon.getCurrentWeekInPregnancy(
                formCollection.createdAt,
                formCollection.week,
              )
              : 0;

      final prompt = '''
Bạn là trợ lý ảo thông minh cho ứng dụng chăm sóc thai kỳ "Belly Bloom". 
Bạn chuyên về tư vấn thai kỳ, sức khỏe, dinh dưỡng và các vấn đề liên quan đến thai kỳ.

THÔNG TIN NGƯỜI DÙNG:
- Tuần thai hiện tại: $currentWeek
- Tên: ${BaseCommon().userAccount.name}

Hãy trả lời câu hỏi của người dùng một cách:
- Thân thiện, chuyên nghiệp và hữu ích
- Dựa trên kiến thức y khoa về thai kỳ
- Phù hợp với tuần thai hiện tại của người dùng (tuần $currentWeek)
- Ngắn gọn, dễ hiểu
- Bằng tiếng Việt

Câu hỏi của người dùng: "$message"

Hãy trả lời trực tiếp câu hỏi, không cần format JSON hay giải thích thêm.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final responseText =
          response.text ?? 'Xin lỗi, tôi không thể trả lời câu hỏi này.';

      log(
        'Gemini response received: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...',
      );

      return responseText;
    } catch (e) {
      log('Error in general chat: $e');
      return 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại sau.';
    }
  }
}

// Model để lưu intent
class ChatIntent {
  final String intent;
  final String action;
  final int? week;

  ChatIntent({required this.intent, required this.action, this.week});
}
