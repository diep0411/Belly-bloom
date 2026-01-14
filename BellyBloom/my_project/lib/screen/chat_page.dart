import 'package:flutter/material.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';
import 'package:my_project/screen/guide_page.dart';
import 'package:my_project/service/gemini_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    GeminiService.initialize();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Thêm tin nhắn user
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Phân tích intent
      final intent = await GeminiService.analyzeIntent(text);

      // Log intent để debug
      print('Intent detected: ${intent.intent}, action: ${intent.action}');

      // Xử lý intent và lấy response
      // Nếu intent là "general", hệ thống sẽ gửi câu hỏi lên Gemini và trả về response
      final response = await GeminiService.handleIntent(intent, text);

      // Log response để debug (chỉ log một phần để không quá dài)
      print(
        'Response received: ${response.length > 100 ? "${response.substring(0, 100)}..." : response}',
      );

      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
              actionType:
                  intent.intent == 'exercises'
                      ? 'exercises'
                      : intent.intent == 'blogs'
                      ? 'blogs'
                      : null,
              actionWeek: intent.week,
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại sau.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: managerColor.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý ảo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: UtilsReponsive.formatFontSize(18, context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Đang hoạt động',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Menu options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child:
                _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.height(16, context),
                        vertical: UtilsReponsive.height(12, context),
                      ),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isLoading) {
                          return _buildLoadingIndicator();
                        }
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: managerColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy, size: 50, color: managerColor.primary),
          ),
          SizedBox(height: 24),
          Text(
            'Xin chào! 👋',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(24, context),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tôi là trợ lý ảo của bạn',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(16, context),
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Hãy hỏi tôi bất cứ điều gì về thai kỳ!',
            style: TextStyle(
              fontSize: UtilsReponsive.formatFontSize(14, context),
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickQuestion('Tuần thai hiện tại?'),
              _buildQuickQuestion('Lịch khám sắp tới?'),
              _buildQuickQuestion('Dinh dưỡng thai kỳ'),
              _buildQuickQuestion('Các triệu chứng'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestion(String text) {
    return InkWell(
      onTap: () {
        _messageController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: managerColor.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: UtilsReponsive.formatFontSize(12, context),
            color: managerColor.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: managerColor.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                size: 18,
                color: managerColor.primary,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.height(16, context),
                vertical: UtilsReponsive.height(12, context),
              ),
              decoration: BoxDecoration(
                color: isUser ? managerColor.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(14, context),
                      color: isUser ? Colors.white : Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                  // Action button cho exercises hoặc blogs
                  if (!isUser && message.actionType != null) ...[
                    SizedBox(height: 12),
                    _buildActionButton(message),
                  ],
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(10, context),
                      color:
                          isUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: managerColor.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 18, color: managerColor.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: UtilsReponsive.height(12, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: managerColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy, size: 18, color: managerColor.primary),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: UtilsReponsive.height(16, context),
              vertical: UtilsReponsive.height(12, context),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      managerColor.primary,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Đang suy nghĩ...',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.height(16, context),
        vertical: UtilsReponsive.height(12, context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          // Attachment functionality
                        },
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(width: 8),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: _isLoading ? 'Đang xử lý...' : 'Nhập tin nhắn...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: UtilsReponsive.formatFontSize(14, context),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.height(16, context),
                      vertical: UtilsReponsive.height(12, context),
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _isLoading ? null : (_) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 8),

            // Send button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isLoading ? Colors.grey.shade300 : managerColor.primary,
                shape: BoxShape.circle,
                boxShadow:
                    _isLoading
                        ? []
                        : [
                          BoxShadow(
                            color: managerColor.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
              ),
              child: IconButton(
                icon:
                    _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _isLoading ? null : _sendMessage,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(ChatMessage message) {
    if (message.actionType == null) return SizedBox.shrink();

    final isExercises = message.actionType == 'exercises';
    final buttonText = isExercises ? 'Xem bài tập' : 'Xem cẩm nang';
    final icon = isExercises ? Icons.fitness_center : Icons.menu_book;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => GuidePage(
                    initialTab: isExercises ? 1 : 0, // 0 = blogs, 1 = exercises
                    initialWeek: message.actionWeek,
                  ),
            ),
          );
        },
        icon: Icon(icon, size: 18),
        label: Text(buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: managerColor.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.height(16, context),
            vertical: UtilsReponsive.height(10, context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? actionType; // 'exercises' hoặc 'blogs'
  final int? actionWeek; // Tuần nếu có

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionType,
    this.actionWeek,
  });
}
