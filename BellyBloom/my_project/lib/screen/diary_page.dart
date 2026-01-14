import 'package:flutter/material.dart';
import 'package:my_project/model/diary_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/screen/diary_form_page.dart';
import 'package:my_project/service/diary_service.dart';
import 'package:my_project/widgets/diary_card.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  List<DiaryModel> diaries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedDiaries = await DiaryService.getDiaries();
      setState(() {
        diaries = loadedDiaries;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Có lỗi xảy ra khi tải nhật ký');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _createDiaryForToday() async {
    final today = DateTime.now();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryFormPage(selectedDate: today),
      ),
    );

    if (result == true) {
      _loadDiaries();
    }
  }

  Future<void> _editDiary(DiaryModel diary) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DiaryFormPage(diary: diary)),
    );

    if (result == true) {
      _loadDiaries();
    }
  }

  Future<void> _showDeleteDialog(DiaryModel diary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Xóa nhật ký',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn có chắc chắn muốn xóa nhật ký này?',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 8),
                          Text(
                            diary.formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      if (diary.content.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          diary.content.length > 50
                              ? '${diary.content.substring(0, 50)}...'
                              : diary.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (diary.imageUrls.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${diary.imageUrls.length} ảnh',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Hành động này không thể hoàn tác. Tất cả ảnh liên quan cũng sẽ bị xóa.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteDiary(diary);
    }
  }

  Future<void> _deleteDiary(DiaryModel diary) async {
    if (diary.id == null) {
      _showErrorSnackBar('Không thể xóa nhật ký này');
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Material(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        managerColor.primary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang xóa nhật ký...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    try {
      final success = await DiaryService.deleteDiary(diary.id!);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Đã xóa nhật ký thành công'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        _loadDiaries();
      } else {
        if (mounted) {
          _showErrorSnackBar('Có lỗi xảy ra khi xóa nhật ký');
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar('Có lỗi xảy ra: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Nhật ký thai kỳ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: managerColor.primary,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _createDiaryForToday,
            icon: Icon(Icons.add),
            tooltip: 'Viết nhật ký hôm nay',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  managerColor.primary.withOpacity(0.1),
                  managerColor.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: managerColor.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: managerColor.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.book_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhật ký thai kỳ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Ghi lại những khoảnh khắc đáng nhớ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: managerColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${diaries.length} bài',
                    style: TextStyle(
                      fontSize: 12,
                      color: managerColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createDiaryForToday,
        backgroundColor: managerColor.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.edit),
        label: Text('Viết nhật ký'),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(managerColor.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải nhật ký...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (diaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'Chưa có nhật ký nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy bắt đầu viết nhật ký đầu tiên của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createDiaryForToday,
              style: ElevatedButton.styleFrom(
                backgroundColor: managerColor.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.edit),
              label: Text('Viết nhật ký hôm nay'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDiaries,
      color: managerColor.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: diaries.length,
        itemBuilder: (context, index) {
          final diary = diaries[index];
          return DiaryCard(
            diary: diary,
            onTap: () => _editDiary(diary),
            onDelete: () => _showDeleteDialog(diary),
          );
        },
      ),
    );
  }
}
