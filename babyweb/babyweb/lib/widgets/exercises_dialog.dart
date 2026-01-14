// Dialog for creating/editing exercise
import 'package:babyweb/model/exercise_model.dart';
import 'package:babyweb/model/pregnancy_week_model.dart';
import 'package:babyweb/resource/color_manager.dart';
import 'package:babyweb/resource/reponsive_utils.dart';
import 'package:babyweb/service/exercise_service.dart';
import 'package:babyweb/service/pregnancy_week_service.dart';
import 'package:flutter/material.dart';

class ExerciseDialog extends StatefulWidget {
  final ExerciseModel? exercise;
  final VoidCallback onSave;

  const ExerciseDialog({
    super.key,
    this.exercise,
    required this.onSave,
  });

  @override
  State<ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<ExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _precautionsController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  
  String selectedCategory = 'yoga';
  String selectedDifficulty = 'beginner';
  bool isActive = true;
  bool isLoading = false;
  
  List<String> benefits = [];
  List<String> precautions = [];
  List<String> equipment = [];
  List<String> instructions = [];
  List<String> targetWeeks = [];
  List<PregnancyWeekModel> availableWeeks = [];
  bool isLoadingWeeks = false;

  final List<String> categories = [
    'yoga',
    'cardio',
    'strength',
    'breathing',
    'stretching',
    'pelvic',
  ];

  final List<String> difficulties = [
    'beginner',
    'intermediate',
    'advanced',
  ];

  @override
  void initState() {
    super.initState();
    _loadPregnancyWeeks();
    if (widget.exercise != null) {
      _loadExerciseData();
    }
  }

  void _loadPregnancyWeeks() async {
    setState(() {
      isLoadingWeeks = true;
    });
    
    try {
      availableWeeks = await PregnancyWeekService.loadPregnancyWeeks();
    } catch (e) {
      print('Error loading pregnancy weeks: $e');
    } finally {
      setState(() {
        isLoadingWeeks = false;
      });
    }
  }

  void _loadExerciseData() {
    final exercise = widget.exercise!;
    _titleController.text = exercise.title;
    _descriptionController.text = exercise.description;
    _contentController.text = exercise.content;
    _imageUrlController.text = exercise.imageUrl;
    _durationController.text = exercise.duration.toString();
    selectedCategory = exercise.category;
    selectedDifficulty = exercise.difficulty;
    isActive = exercise.isActive;
    benefits = List.from(exercise.benefits);
    precautions = List.from(exercise.precautions);
    equipment = List.from(exercise.equipment);
    instructions = List.from(exercise.instructions);
    targetWeeks = List.from(exercise.targetWeeks);
  }

  void _addToList(List<String> list, TextEditingController controller, String label) {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        list.add(controller.text.trim());
        controller.clear();
      });
    }
  }

  void _removeFromList(List<String> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final duration = int.parse(_durationController.text);
      final now = DateTime.now();
      
      final exercise = ExerciseModel(
        id: widget.exercise?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        category: selectedCategory,
        difficulty: selectedDifficulty,
        duration: duration,
        benefits: benefits,
        precautions: precautions,
        equipment: equipment,
        instructions: instructions,
        targetWeeks: targetWeeks,
        isActive: isActive,
        createdAt: widget.exercise?.createdAt ?? now,
        updatedAt: now,
      );

      bool success;
      if (widget.exercise == null) {
        success = await ExerciseService.addExercise(exercise);
      } else {
        success = await ExerciseService.updateExercise(exercise);
      }

      if (success) {
        Navigator.of(context).pop();
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.exercise == null 
                ? 'Đã thêm bài tập thành công' 
                : 'Đã cập nhật bài tập thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi lưu bài tập'),
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
                      widget.exercise == null ? Icons.add : Icons.edit,
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
                          widget.exercise == null ? 'Thêm bài tập mới' : 'Chỉnh sửa bài tập',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(18, context),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          widget.exercise == null 
                              ? 'Thêm bài tập mới cho bà bầu'
                              : 'Cập nhật thông tin bài tập',
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
                      
                      _buildTextField(
                        controller: _titleController,
                        label: 'Tên bài tập',
                        hint: 'Nhập tên bài tập',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên bài tập';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Mô tả',
                        hint: 'Nhập mô tả ngắn về bài tập',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mô tả';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Loại bài tập',
                              value: selectedCategory,
                              items: categories,
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: UtilsReponsive.width(16, context)),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Độ khó',
                              value: selectedDifficulty,
                              items: difficulties,
                              onChanged: (value) {
                                setState(() {
                                  selectedDifficulty = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _durationController,
                              label: 'Thời gian (phút)',
                              hint: 'Nhập thời gian thực hiện',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập thời gian';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Thời gian phải là số';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: UtilsReponsive.width(16, context)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trạng thái',
                                  style: TextStyle(
                                    fontSize: UtilsReponsive.formatFontSize(14, context),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: UtilsReponsive.height(8, context)),
                                SwitchListTile(
                                  value: isActive,
                                  onChanged: (value) {
                                    setState(() {
                                      isActive = value;
                                    });
                                  },
                                  title: Text(
                                    isActive ? 'Hoạt động' : 'Tạm dừng',
                                    style: TextStyle(fontSize: UtilsReponsive.formatFontSize(12, context)),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildTextField(
                        controller: _imageUrlController,
                        label: 'URL hình ảnh',
                        hint: 'Nhập URL hình ảnh minh họa',
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      // Content
                      _buildSectionTitle('Nội dung chi tiết'),
                      SizedBox(height: UtilsReponsive.height(16, context)),
                      
                      _buildTextField(
                        controller: _contentController,
                        label: 'Nội dung bài tập',
                        hint: 'Nhập nội dung chi tiết về bài tập',
                        maxLines: 5,
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      // Lists
                      _buildListSection(
                        controller: _benefitsController,
                        label: 'Lợi ích',
                        hint: 'Nhập lợi ích của bài tập',
                        items: benefits,
                        onAdd: () => _addToList(benefits, _benefitsController, 'Lợi ích'),
                        onRemove: (index) => _removeFromList(benefits, index),
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      _buildListSection(
                        controller: _precautionsController,
                        label: 'Lưu ý',
                        hint: 'Nhập lưu ý khi thực hiện',
                        items: precautions,
                        onAdd: () => _addToList(precautions, _precautionsController, 'Lưu ý'),
                        onRemove: (index) => _removeFromList(precautions, index),
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      _buildListSection(
                        controller: _equipmentController,
                        label: 'Dụng cụ',
                        hint: 'Nhập dụng cụ cần thiết',
                        items: equipment,
                        onAdd: () => _addToList(equipment, _equipmentController, 'Dụng cụ'),
                        onRemove: (index) => _removeFromList(equipment, index),
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      _buildListSection(
                        controller: _instructionsController,
                        label: 'Hướng dẫn',
                        hint: 'Nhập hướng dẫn thực hiện',
                        items: instructions,
                        onAdd: () => _addToList(instructions, _instructionsController, 'Hướng dẫn'),
                        onRemove: (index) => _removeFromList(instructions, index),
                      ),
                      SizedBox(height: UtilsReponsive.height(24, context)),
                      
                      _buildTargetWeeksSection(),
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
                    onPressed: isLoading ? null : _saveExercise,
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
                            widget.exercise == null ? Icons.save : Icons.update,
                            size: UtilsReponsive.formatFontSize(16, context),
                          ),
                    label: Text(
                      isLoading 
                          ? 'Đang lưu...'
                          : (widget.exercise == null ? 'Thêm bài tập' : 'Cập nhật'),
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
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
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                _getDisplayText(item),
                style: TextStyle(fontSize: UtilsReponsive.formatFontSize(12, context)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _getDisplayText(String value) {
    switch (value) {
      case 'yoga':
        return 'Yoga';
      case 'cardio':
        return 'Cardio';
      case 'strength':
        return 'Tăng cường sức mạnh';
      case 'breathing':
        return 'Thở';
      case 'stretching':
        return 'Kéo giãn';
      case 'pelvic':
        return 'Sàn chậu';
      case 'beginner':
        return 'Cơ bản';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      default:
        return value;
    }
  }

  Widget _buildTargetWeeksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tuần thai kỳ phù hợp',
          style: TextStyle(
            fontSize: UtilsReponsive.formatFontSize(14, context),
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: UtilsReponsive.height(8, context)),
        
        if (isLoadingWeeks) ...[
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
                  ),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Text(
                  'Đang tải danh sách tuần thai kỳ...',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ] else if (availableWeeks.isEmpty) ...[
          Container(
            padding: EdgeInsets.all(UtilsReponsive.width(16, context)),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: Colors.orange.shade600,
                  size: UtilsReponsive.formatFontSize(16, context),
                ),
                SizedBox(width: UtilsReponsive.width(12, context)),
                Expanded(
                  child: Text(
                    'Chưa có tuần thai kỳ nào. Vui lòng thêm tuần thai kỳ trước.',
                    style: TextStyle(
                      fontSize: UtilsReponsive.formatFontSize(12, context),
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
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
                Row(
                  children: [
                    Text(
                      'Chọn tuần thai kỳ phù hợp (${targetWeeks.length} đã chọn)',
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(12, context),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Spacer(),
                    if (targetWeeks.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            targetWeeks.clear();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: UtilsReponsive.width(8, context),
                            vertical: UtilsReponsive.height(4, context),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Bỏ chọn tất cả',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(10, context),
                            color: Colors.red.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
                Wrap(
                  spacing: UtilsReponsive.width(8, context),
                  runSpacing: UtilsReponsive.height(8, context),
                  children: availableWeeks.map((week) {
                    bool isSelected = targetWeeks.contains(week.weekNumber.toString());
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            targetWeeks.remove(week.weekNumber.toString());
                          } else {
                            targetWeeks.add(week.weekNumber.toString());
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UtilsReponsive.width(12, context),
                          vertical: UtilsReponsive.height(6, context),
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? ColorManager.primary.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? ColorManager.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: UtilsReponsive.width(20, context),
                              height: UtilsReponsive.height(20, context),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? ColorManager.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected 
                                      ? ColorManager.primary
                                      : Colors.grey.shade400,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: UtilsReponsive.formatFontSize(12, context),
                                    )
                                  : null,
                            ),
                            SizedBox(width: UtilsReponsive.width(6, context)),
                            Text(
                              'Tuần ${week.weekNumber}',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(12, context),
                                color: isSelected 
                                    ? ColorManager.primary
                                    : Colors.grey.shade700,
                                fontWeight: isSelected 
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (targetWeeks.isNotEmpty) ...[
                  SizedBox(height: UtilsReponsive.height(12, context)),
                  Container(
                    padding: EdgeInsets.all(UtilsReponsive.width(8, context)),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đã chọn:',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(10, context),
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: UtilsReponsive.height(4, context)),
                        Text(
                          targetWeeks.map((week) => 'Tuần $week').join(', '),
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(10, context),
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
                  'Danh sách $label (${items.length})',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(12, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: UtilsReponsive.height(8, context)),
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
