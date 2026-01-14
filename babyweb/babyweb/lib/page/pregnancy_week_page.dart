import 'package:babyweb/model/pregnancy_week_model.dart';
import 'package:babyweb/resource/color_manager.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/pregnancy_week_service.dart';
import 'package:babyweb/widgets/blogs_for_week_dialog.dart';
import 'package:babyweb/widgets/exercises_for_week_dialog.dart';
import 'package:babyweb/widgets/pregnancy_week_dialog.dart';
import 'package:flutter/material.dart';

class PregnancyWeekPage extends StatefulWidget {
  const PregnancyWeekPage({super.key});

  @override
  State<PregnancyWeekPage> createState() => _PregnancyWeekPageState();
}

class _PregnancyWeekPageState extends State<PregnancyWeekPage> {
  TextEditingController searchController = TextEditingController();
  List<PregnancyWeekModel> pregnancyWeeks = [];
  List<PregnancyWeekModel> filteredWeeks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadPregnancyWeeks();
  }

  void loadPregnancyWeeks() async {
    setState(() {
      isLoading = true;
    });
    
    pregnancyWeeks = await PregnancyWeekService.loadPregnancyWeeks();
    filteredWeeks = List.from(pregnancyWeeks);
    
    setState(() {
      isLoading = false;
    });
  }

  void _filterWeeks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredWeeks = List.from(pregnancyWeeks);
      } else {
        filteredWeeks = pregnancyWeeks.where((week) {
          return week.title.toLowerCase().contains(query.toLowerCase()) ||
                 week.description.toLowerCase().contains(query.toLowerCase()) ||
                 week.weekNumber.toString().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: UtilsReponsive.padding(context, horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: UtilsReponsive.height(24, context)),
          _buildSearchAndCreateSection(),
          SizedBox(height: UtilsReponsive.height(24, context)),
          Expanded(child: _buildWeeksList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorManager.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.pregnant_woman,
            color: ColorManager.primary,
            size: UtilsReponsive.formatFontSize(24, context),
          ),
        ),
        SizedBox(width: UtilsReponsive.width(16, context)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý tuần thai kỳ',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(28, context),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              'Định nghĩa và quản lý thông tin các tuần thai kỳ',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: UtilsReponsive.width(16, context),
            vertical: UtilsReponsive.height(8, context),
          ),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${pregnancyWeeks.length} tuần',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(12, context),
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndCreateSection() {
    return Container(
      padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: searchController,
                onChanged: _filterWeeks,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tuần, tiêu đề...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(16, context),
                    vertical: UtilsReponsive.height(12, context),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: UtilsReponsive.width(16, context)),
          ElevatedButton.icon(
            onPressed: () {
              _showCreateEditDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: UtilsReponsive.width(20, context),
                vertical: UtilsReponsive.height(12, context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: Icon(Icons.add, size: UtilsReponsive.formatFontSize(18, context)),
            label: Text(
              'Thêm tuần thai kỳ',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeksList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (filteredWeeks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(24, context)),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pregnant_woman_outlined,
                size: UtilsReponsive.formatFontSize(48, context),
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            Text(
              pregnancyWeeks.isEmpty ? 'Chưa có tuần thai kỳ nào' : 'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(18, context),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            Text(
              pregnancyWeeks.isEmpty 
                  ? 'Hãy thêm tuần thai kỳ đầu tiên'
                  : 'Thử thay đổi từ khóa tìm kiếm',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                color: Colors.grey.shade500,
              ),
            ),
            if (pregnancyWeeks.isEmpty) ...[
              SizedBox(height: UtilsReponsive.height(24, context)),
              ElevatedButton.icon(
                onPressed: () {
                  _showCreateEditDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(24, context),
                    vertical: UtilsReponsive.height(12, context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.add),
                label: Text('Thêm tuần thai kỳ đầu tiên'),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: ColorManager.primary,
                  size: UtilsReponsive.formatFontSize(20, context),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                Text(
                  'Danh sách tuần thai kỳ',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(16, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Spacer(),
                Text(
                  '${filteredWeeks.length} tuần',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              itemCount: filteredWeeks.length,
              itemBuilder: (context, index) {
                final week = filteredWeeks[index];
                return _buildWeekCard(week);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(PregnancyWeekModel week) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showCreateEditDialog(week: week);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            child: Row(
              children: [
                // Week Number Badge
                Container(
                  width: UtilsReponsive.width(60, context),
                  height: UtilsReponsive.height(60, context),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorManager.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tuần',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(10, context),
                          color: ColorManager.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${week.weekNumber}',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(18, context),
                          color: ColorManager.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(16, context)),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        week.title,
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(16, context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: UtilsReponsive.height(4, context)),
                      Text(
                        week.description,
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(14, context),
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: UtilsReponsive.height(8, context)),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${week.symptoms.length} triệu chứng',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(10, context),
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: UtilsReponsive.width(8, context)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${week.recommendations.length} lời khuyên',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(10, context),
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showExercisesForWeek(week);
                      },
                      icon: Icon(
                        Icons.fitness_center_outlined,
                        color: Colors.orange.shade600,
                      ),
                      tooltip: 'Xem bài tập',
                    ),
                    IconButton(
                      onPressed: () {
                        _showBlogsForWeek(week);
                      },
                      icon: Icon(
                        Icons.article_outlined,
                        color: Colors.blue.shade600,
                      ),
                      tooltip: 'Xem blog',
                    ),
                    IconButton(
                      onPressed: () {
                        _showCreateEditDialog(week: week);
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: ColorManager.primary,
                      ),
                      tooltip: 'Chỉnh sửa',
                    ),
                    IconButton(
                      onPressed: () {
                        _showDeleteDialog(week);
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                      tooltip: 'Xóa',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateEditDialog({PregnancyWeekModel? week}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PregnancyWeekDialog(
        week: week,
        onSave: () {
          loadPregnancyWeeks();
        },
      ),
    );
  }

  void _showExercisesForWeek(PregnancyWeekModel week) {
    showDialog(
      context: context,
      builder: (context) => ExercisesForWeekDialog(
        week: week,
      ),
    );
  }

  void _showBlogsForWeek(PregnancyWeekModel week) {
    showDialog(
      context: context,
      builder: (context) => BlogsForWeekDialog(
        week: week,
      ),
    );
  }

  void _showDeleteDialog(PregnancyWeekModel week) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Xác nhận xóa'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có chắc chắn muốn xóa tuần thai kỳ này?'),
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
                    Text(
                      'Tuần ${week.weekNumber}: ${week.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      week.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Hành động này không thể hoàn tác!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteWeek(week);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteWeek(PregnancyWeekModel week) async {
    if (week.id == null) return;
    
    try {
      bool success = await PregnancyWeekService.deletePregnancyWeek(week.id!);
      if (success) {
        loadPregnancyWeeks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa tuần thai kỳ thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi xóa tuần thai kỳ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi xóa tuần thai kỳ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
