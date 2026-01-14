import 'package:babyweb/model/pregnancy_week_model.dart';
import 'package:babyweb/resource/color_manager.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/pregnancy_week_service.dart';
import 'package:flutter/material.dart';

// Dialog for creating/editing pregnancy week
class PregnancyWeekDialog extends StatefulWidget {
  final PregnancyWeekModel? week;
  final VoidCallback onSave;

  const PregnancyWeekDialog({
    super.key,
    this.week,
    required this.onSave,
  });

  @override
  State<PregnancyWeekDialog> createState() => _PregnancyWeekDialogState();
}

class _PregnancyWeekDialogState extends State<PregnancyWeekDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weekNumberController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _babyDevelopmentController = TextEditingController();
  final TextEditingController _motherChangesController = TextEditingController();
  final TextEditingController _tipsController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _recommendationsController = TextEditingController();
  
  List<String> symptoms = [];
  List<String> recommendations = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.week != null) {
      _loadWeekData();
    }
  }

  void _loadWeekData() {
    final week = widget.week!;
    _weekNumberController.text = week.weekNumber.toString();
    _titleController.text = week.title;
    _descriptionController.text = week.description;
    _babyDevelopmentController.text = week.babyDevelopment;
    _motherChangesController.text = week.motherChanges;
    _tipsController.text = week.tips;
    _imageUrlController.text = week.imageUrl;
    symptoms = List.from(week.symptoms);
    recommendations = List.from(week.recommendations);
  }

  void _addSymptom() {
    if (_symptomsController.text.trim().isNotEmpty) {
      setState(() {
        symptoms.add(_symptomsController.text.trim());
        _symptomsController.clear();
      });
    }
  }

  void _removeSymptom(int index) {
    setState(() {
      symptoms.removeAt(index);
    });
  }

  void _addRecommendation() {
    if (_recommendationsController.text.trim().isNotEmpty) {
      setState(() {
        recommendations.add(_recommendationsController.text.trim());
        _recommendationsController.clear();
      });
    }
  }

  void _removeRecommendation(int index) {
    setState(() {
      recommendations.removeAt(index);
    });
  }

  Future<void> _saveWeek() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final weekNumber = int.parse(_weekNumberController.text);
      
      // Check if week number already exists
      bool exists = await PregnancyWeekService.isWeekNumberExists(
        weekNumber,
        excludeId: widget.week?.id,
      );
      
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tuần thai kỳ $weekNumber đã tồn tại'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final now = DateTime.now();
      final pregnancyWeek = PregnancyWeekModel(
        id: widget.week?.id,
        weekNumber: weekNumber,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        babyDevelopment: _babyDevelopmentController.text.trim(),
        motherChanges: _motherChangesController.text.trim(),
        tips: _tipsController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        symptoms: symptoms,
        recommendations: recommendations,
        createdAt: widget.week?.createdAt ?? now,
        updatedAt: now,
      );

      bool success;
      if (widget.week == null) {
        success = await PregnancyWeekService.addPregnancyWeek(pregnancyWeek);
      } else {
        success = await PregnancyWeekService.updatePregnancyWeek(pregnancyWeek);
      }

      if (success) {
        Navigator.of(context).pop();
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.week == null 
                ? 'Đã thêm tuần thai kỳ thành công' 
                : 'Đã cập nhật tuần thai kỳ thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi lưu tuần thai kỳ'),
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
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.1),
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
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.week == null ? Icons.add : Icons.edit,
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
                          widget.week == null ? 'Thêm tuần thai kỳ mới' : 'Chỉnh sửa tuần thai kỳ',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(18, context),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          widget.week == null 
                              ? 'Thêm thông tin chi tiết cho tuần thai kỳ mới'
                              : 'Cập nhật thông tin tuần thai kỳ',
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(UtilsReponsive.width(20, context)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info
                      _buildSectionTitle('Thông tin cơ bản'),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildTextField(
                              controller: _weekNumberController,
                              label: 'Số tuần',
                              hint: 'Nhập số tuần thai kỳ',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập số tuần';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Số tuần phải là số nguyên';
                                }
                                int week = int.parse(value);
                                if (week < 1 || week > 42) {
                                  return 'Số tuần phải từ 1 đến 42';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: UtilsReponsive.width(16, context)),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _titleController,
                              label: 'Tiêu đề',
                              hint: 'Nhập tiêu đề tuần thai kỳ',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập tiêu đề';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Mô tả',
                        hint: 'Nhập mô tả tổng quan về tuần thai kỳ',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mô tả';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildTextField(
                        controller: _imageUrlController,
                        label: 'URL hình ảnh',
                        hint: 'Nhập URL hình ảnh minh họa',
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      // Development Info
                      _buildSectionTitle('Phát triển của bé'),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildTextField(
                        controller: _babyDevelopmentController,
                        label: 'Sự phát triển của bé',
                        hint: 'Mô tả sự phát triển của thai nhi trong tuần này',
                        maxLines: 4,
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      // Mother Changes
                      _buildSectionTitle('Thay đổi của mẹ'),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildTextField(
                        controller: _motherChangesController,
                        label: 'Những thay đổi của mẹ',
                        hint: 'Mô tả những thay đổi về thể chất và tinh thần của mẹ',
                        maxLines: 4,
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      // Tips
                      _buildSectionTitle('Lời khuyên'),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildTextField(
                        controller: _tipsController,
                        label: 'Lời khuyên chung',
                        hint: 'Nhập lời khuyên chung cho tuần thai kỳ này',
                        maxLines: 3,
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      // Symptoms
                      _buildSectionTitle('Triệu chứng'),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildListSection(
                        controller: _symptomsController,
                        label: 'Thêm triệu chứng',
                        hint: 'Nhập triệu chứng mới',
                        items: symptoms,
                        onAdd: _addSymptom,
                        onRemove: _removeSymptom,
                        itemLabel: 'Triệu chứng',
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      // Recommendations
                      _buildSectionTitle('Khuyến nghị'),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildListSection(
                        controller: _recommendationsController,
                        label: 'Thêm khuyến nghị',
                        hint: 'Nhập khuyến nghị mới',
                        items: recommendations,
                        onAdd: _addRecommendation,
                        onRemove: _removeRecommendation,
                        itemLabel: 'Khuyến nghị',
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
                    child: Text('Hủy'),
                  ),
                  SizedBox(width: UtilsReponsive.width(12, context)),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _saveWeek,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: UtilsReponsive.width(24, context),
                        vertical: UtilsReponsive.height(12, context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: isLoading 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            widget.week == null ? Icons.save : Icons.update,
                            size: UtilsReponsive.formatFontSize(16, context),
                          ),
                    label: Text(
                      isLoading 
                          ? 'Đang lưu...'
                          : (widget.week == null ? 'Thêm tuần thai kỳ' : 'Cập nhật'),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: UtilsReponsive.formatFontSize(16, context),
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: UtilsReponsive.formatFontSize(14, context),
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: UtilsReponsive.height(8, context)),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorManager.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: UtilsReponsive.width(12, context),
              vertical: UtilsReponsive.height(12, context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection({
    required TextEditingController controller,
    required String label,
    required String hint,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required String itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: UtilsReponsive.formatFontSize(14, context),
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: UtilsReponsive.height(8, context)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: ColorManager.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: UtilsReponsive.width(12, context),
                    vertical: UtilsReponsive.height(12, context),
                  ),
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            SizedBox(width: UtilsReponsive.width(8, context)),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(Icons.add),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          SizedBox(height: UtilsReponsive.height(12, context)),
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(12, context)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danh sách $itemLabel (${items.length})',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                //['a'] ['b']  => ['a', ...['b]]=> ['a','b'] 
                ...items.asMap().entries.map((entry) {
                  int index = entry.key;
                  String item = entry.value;
                  return Container(
                    margin: EdgeInsets.only(bottom: UtilsReponsive.height(4, context)),
                    padding: EdgeInsets.symmetric(
                      horizontal: UtilsReponsive.width(8, context),
                      vertical: UtilsReponsive.height(4, context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(12, context),
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => onRemove(index),
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red.shade400,
                            size: UtilsReponsive.formatFontSize(16, context),
                          ),
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
