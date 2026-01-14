import 'package:babyweb/model/reminder_model.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/reminder_service.dart';
import 'package:babyweb/widgets/reminder_dialog.dart';
import 'package:flutter/material.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  TextEditingController searchController = TextEditingController();
  List<ReminderModel> reminders = [];
  List<ReminderModel> filteredReminders = [];
  bool isLoading = false;
  String? selectedPriority;
  int? selectedWeek;

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  void loadReminders() async {
    setState(() {
      isLoading = true;
    });
    
    reminders = await ReminderService.loadReminders();
    filteredReminders = List.from(reminders);
    
    setState(() {
      isLoading = false;
    });
  }

  void _filterReminders(String query) {
    setState(() {
      if (query.isEmpty && selectedPriority == null && selectedWeek == null) {
        filteredReminders = List.from(reminders);
      } else {
        filteredReminders = reminders.where((reminder) {
          bool matchesQuery = query.isEmpty || 
              reminder.title.toLowerCase().contains(query.toLowerCase()) ||
              reminder.description.toLowerCase().contains(query.toLowerCase()) ||
              reminder.weekNumber.toString().contains(query);
          
          bool matchesPriority = selectedPriority == null || 
              reminder.priority == selectedPriority;
          
          bool matchesWeek = selectedWeek == null || 
              reminder.weekNumber == selectedWeek;
          
          return matchesQuery && matchesPriority && matchesWeek;
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
          Expanded(child: _buildRemindersList()),
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
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.notifications_active,
            color: Colors.orange.shade700,
            size: UtilsReponsive.formatFontSize(24, context),
          ),
        ),
        SizedBox(width: UtilsReponsive.width(16, context)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhắc hẹn quan trọng',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(28, context),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              'Quản lý các nhắc hẹn quan trọng cho từng tuần thai kỳ',
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
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${reminders.length} nhắc hẹn',
                style: TextStyle(
                  fontSize: UtilsReponsive.formatFontSize(12, context),
                  color: Colors.orange.shade700,
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
      child: Column(
        children: [
          Row(
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
                    onChanged: (value) => _filterReminders(value),
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
              SizedBox(width: UtilsReponsive.width(12, context)),
              // Priority filter
              Flexible(
                child: Container(
                  width: UtilsReponsive.width(180, context),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPriority,
                      isExpanded: true,
                      hint: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(12, context),
                        ),
                        child: Text(
                          'Tất cả',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(14, context),
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(12, context),
                            ),
                            child: Text(
                              'Tất cả',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(14, context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'high',
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(12, context),
                            ),
                            child: Text(
                              'Cao',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(14, context),
                              ),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(12, context),
                            ),
                            child: Text(
                              'Trung bình',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(14, context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'low',
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(12, context),
                            ),
                            child: Text(
                              'Thấp',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(14, context),
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value;
                        });
                        _filterReminders(searchController.text);
                      },
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(12, context),
                        vertical: UtilsReponsive.height(4, context),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: UtilsReponsive.width(12, context)),
              ElevatedButton.icon(
                onPressed: () {
                  _showCreateEditDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
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
                  'Thêm nhắc hẹn',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(14, context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
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

    if (filteredReminders.isEmpty) {
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
                Icons.notifications_none,
                size: UtilsReponsive.formatFontSize(48, context),
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(16, context)),
            Text(
              reminders.isEmpty ? 'Chưa có nhắc hẹn nào' : 'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(18, context),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: UtilsReponsive.height(8, context)),
            Text(
              reminders.isEmpty 
                  ? 'Hãy thêm nhắc hẹn đầu tiên'
                  : 'Thử thay đổi từ khóa tìm kiếm',
              style: TextStyle(
                fontSize: UtilsReponsive.formatFontSize(14, context),
                color: Colors.grey.shade500,
              ),
            ),
            if (reminders.isEmpty) ...[
              SizedBox(height: UtilsReponsive.height(24, context)),
              ElevatedButton.icon(
                onPressed: () {
                  _showCreateEditDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
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
                label: Text('Thêm nhắc hẹn đầu tiên'),
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
                  Icons.list,
                  color: Colors.orange.shade700,
                  size: UtilsReponsive.formatFontSize(20, context),
                ),
                SizedBox(width: UtilsReponsive.width(8, context)),
                Text(
                  'Danh sách nhắc hẹn',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(16, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Spacer(),
                Text(
                  '${filteredReminders.length} nhắc hẹn',
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
              itemCount: filteredReminders.length,
              itemBuilder: (context, index) {
                final reminder = filteredReminders[index];
                return _buildReminderCard(reminder);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: UtilsReponsive.height(16, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reminder.priorityColor.withOpacity(0.3),
          width: 2,
        ),
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
            _showCreateEditDialog(reminder: reminder);
          },
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Priority indicator
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: reminder.priorityColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                SizedBox(width: UtilsReponsive.width(16, context)),
                
                // Week Number Badge
                Container(
                  width: UtilsReponsive.width(60, context),
                  height: UtilsReponsive.height(60, context),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tuần',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(10, context),
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${reminder.weekNumber}',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(18, context),
                          color: Colors.orange.shade700,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminder.title,
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(16, context),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(8, context),
                              vertical: UtilsReponsive.height(4, context),
                            ),
                            decoration: BoxDecoration(
                              color: reminder.priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              reminder.priorityDisplayName,
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(10, context),
                                color: reminder.priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: UtilsReponsive.height(4, context)),
                      Text(
                        reminder.description,
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
                              color: reminder.isActive 
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: reminder.isActive 
                                        ? Colors.green
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  reminder.isActive ? 'Hoạt động' : 'Tạm dừng',
                                  style: TextStyle(
                                    fontSize: UtilsReponsive.formatFontSize(10, context),
                                    color: reminder.isActive 
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        _showCreateEditDialog(reminder: reminder);
                      },
                      icon: Icon(Icons.edit, color: Colors.blue.shade700),
                      tooltip: 'Chỉnh sửa',
                    ),
                    IconButton(
                      onPressed: () {
                        _deleteReminder(reminder);
                      },
                      icon: Icon(Icons.delete, color: Colors.red.shade700),
                      tooltip: 'Xóa',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  void _showCreateEditDialog({ReminderModel? reminder}) {
    showDialog(
      context: context,
      builder: (context) => ReminderDialog(
        reminder: reminder,
        onSave: () {
          loadReminders();
        },
      ),
    );
  }

  void _deleteReminder(ReminderModel reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa nhắc hẹn'),
        content: Text('Bạn có chắc chắn muốn xóa nhắc hẹn "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ReminderService.deleteReminder(reminder.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa nhắc hẹn thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
                loadReminders();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Có lỗi xảy ra khi xóa nhắc hẹn'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

