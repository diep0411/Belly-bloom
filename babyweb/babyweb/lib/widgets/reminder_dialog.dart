import 'package:babyweb/model/pregnancy_week_model.dart';
import 'package:babyweb/model/reminder_model.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/pregnancy_week_service.dart';
import 'package:babyweb/service/reminder_service.dart';
import 'package:flutter/material.dart';

class ReminderDialog extends StatefulWidget {
  final ReminderModel? reminder;
  final VoidCallback onSave;

  const ReminderDialog({
    super.key,
    this.reminder,
    required this.onSave,
  });

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<PregnancyWeekModel> availableWeeks = [];
  PregnancyWeekModel? selectedWeek;
  String selectedPriority = 'medium';
  bool isActive = true;
  bool isLoading = false;
  bool isLoadingWeeks = false;

  @override
  void initState() {
    super.initState();
    _loadPregnancyWeeks();
    if (widget.reminder != null) {
      _loadReminderData();
    }
  }

  void _loadPregnancyWeeks() async {
    setState(() {
      isLoadingWeeks = true;
    });
    
    try {
      availableWeeks = await PregnancyWeekService.loadPregnancyWeeks();
      if (widget.reminder != null && availableWeeks.isNotEmpty) {
        // Find the selected week
        selectedWeek = availableWeeks.firstWhere(
          (week) => week.weekNumber == widget.reminder!.weekNumber,
          orElse: () => availableWeeks.first,
        );
      }
    } catch (e) {
      print('Error loading pregnancy weeks: $e');
    } finally {
      setState(() {
        isLoadingWeeks = false;
      });
    }
  }

  void _loadReminderData() {
    final reminder = widget.reminder!;
    _titleController.text = reminder.title;
    _descriptionController.text = reminder.description;
    selectedPriority = reminder.priority;
    isActive = reminder.isActive;
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedWeek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn tuần thai kỳ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final now = DateTime.now();
      final reminder = ReminderModel(
        id: widget.reminder?.id,
        weekNumber: selectedWeek!.weekNumber,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: selectedPriority,
        isActive: isActive,
        createdAt: widget.reminder?.createdAt ?? now,
        updatedAt: now,
      );

      bool success;
      if (widget.reminder == null) {
        success = await ReminderService.addReminder(reminder);
      } else {
        success = await ReminderService.updateReminder(reminder);
      }

      if (success) {
        Navigator.of(context).pop();
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.reminder == null 
                ? 'Đã thêm nhắc hẹn thành công' 
                : 'Đã cập nhật nhắc hẹn thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi lưu nhắc hẹn'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.reminder == null ? Icons.add : Icons.edit,
                      color: Colors.white,
                      size: UtilsReponsive.formatFontSize(20, context),
                    ),
                  ),
                  SizedBox(width: UtilsReponsive.width(12, context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reminder == null ? 'Thêm nhắc hẹn mới' : 'Chỉnh sửa nhắc hẹn',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(18, context),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          widget.reminder == null 
                              ? 'Thêm nhắc hẹn quan trọng cho tuần thai kỳ'
                              : 'Cập nhật thông tin nhắc hẹn',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(12, context),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Week Selection
                      Text(
                        'Tuần thai kỳ *',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(14, context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: UtilsReponsive.height(8, context)),
                      if (isLoadingWeeks)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Đang tải danh sách tuần thai kỳ...',
                                style: TextStyle(
                                  fontSize: UtilsReponsive.formatFontSize(12, context),
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<PregnancyWeekModel>(
                              value: selectedWeek,
                              hint: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: UtilsReponsive.width(16, context),
                                ),
                                child: Text(
                                  'Chọn tuần thai kỳ',
                                  style: TextStyle(
                                    fontSize: UtilsReponsive.formatFontSize(14, context),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              isExpanded: true,
                              items: availableWeeks.map((week) {
                                return DropdownMenuItem<PregnancyWeekModel>(
                                  value: week,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: UtilsReponsive.width(16, context),
                                    ),
                                    child: Text(
                                      'Tuần ${week.weekNumber}: ${week.title}',
                                      style: TextStyle(
                                        fontSize: UtilsReponsive.formatFontSize(14, context),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedWeek = value;
                                });
                              },
                            ),
                          ),
                        ),
                      SizedBox(height: UtilsReponsive.height(20, context)),
                      
                      // Title
                      Text(
                        'Tiêu đề *',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(14, context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: UtilsReponsive.height(8, context)),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tiêu đề nhắc hẹn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: UtilsReponsive.width(16, context),
                            vertical: UtilsReponsive.height(12, context),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: UtilsReponsive.height(20, context)),
                      
                      // Description
                      Text(
                        'Mô tả *',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(14, context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: UtilsReponsive.height(8, context)),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Nhập mô tả chi tiết nhắc hẹn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: UtilsReponsive.width(16, context),
                            vertical: UtilsReponsive.height(12, context),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập mô tả';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: UtilsReponsive.height(20, context)),
                      
                      // Priority
                      Text(
                        'Độ ưu tiên *',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(14, context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: UtilsReponsive.height(8, context)),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPriority,
                            isExpanded: true,
                            padding: EdgeInsets.symmetric(
                              horizontal: UtilsReponsive.width(16, context),
                              vertical: UtilsReponsive.height(12, context),
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'high',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Cao',
                                      style: TextStyle(
                                        fontSize: UtilsReponsive.formatFontSize(14, context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'medium',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Trung bình',
                                      style: TextStyle(
                                        fontSize: UtilsReponsive.formatFontSize(14, context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'low',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Thấp',
                                      style: TextStyle(
                                        fontSize: UtilsReponsive.formatFontSize(14, context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            selectedItemBuilder: (BuildContext context) {
                              return [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Cao',
                                      style: TextStyle(
                                        fontSize: UtilsReponsive.formatFontSize(14, context),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Trung bình',
                                      style: TextStyle(
                                        fontSize: UtilsReponsive.formatFontSize(14, context),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Thấp',
                                      style: TextStyle(
                                        fontSize: UtilsReponsive.formatFontSize(14, context),
                                      ),
                                    ),
                                  ],
                                ),
                              ];
                            },
                            onChanged: (value) {
                              setState(() {
                                selectedPriority = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: UtilsReponsive.height(20, context)),
                      
                      // Active Status
                      Row(
                        children: [
                          Checkbox(
                            value: isActive,
                            onChanged: (value) {
                              setState(() {
                                isActive = value ?? true;
                              });
                            },
                            activeColor: Colors.orange.shade700,
                          ),
                          Text(
                            'Kích hoạt nhắc hẹn',
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(14, context),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(14, context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  SizedBox(width: UtilsReponsive.width(12, context)),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveReminder,
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
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.reminder == null ? 'Thêm' : 'Cập nhật',
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(14, context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

