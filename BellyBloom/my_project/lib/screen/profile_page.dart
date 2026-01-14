import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_project/model/form_collection.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/service/account_service.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/utils/util_common.dart';
import 'package:numberpicker/numberpicker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  // FormCollection data
  double _height = 170;
  int _weight = 59;
  int _week = 2; // Tuần thai ban đầu
  DateTime? _createdAt;

  // Tính toán tuần thai hiện tại
  int get _currentWeek {
    if (_createdAt == null) return _week;
    return UtilsCommon.getCurrentWeekInPregnancy(_createdAt!, _week);
  }

  @override
  void initState() {
    super.initState();
    final userAccount = BaseCommon().userAccount;
    _nameController = TextEditingController(text: userAccount.name);
    _emailController = TextEditingController(text: userAccount.email);

    // Load formCollection data if exists
    if (userAccount.formCollection != null) {
      final formCollection = userAccount.formCollection!;
      _height = formCollection.height;
      _weight = formCollection.weight;
      _week = formCollection.week;
      _createdAt = formCollection.createdAt;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values if canceling
        final userAccount = BaseCommon().userAccount;
        _nameController.text = userAccount.name;
        if (userAccount.formCollection != null) {
          final formCollection = userAccount.formCollection!;
          _height = formCollection.height;
          _weight = formCollection.weight;
          _week = formCollection.week;
        }
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userAccount = BaseCommon().userAccount;
      final uid = userAccount.uid;

      if (uid == null || uid.isEmpty) {
        throw Exception('User ID không hợp lệ');
      }

      // Tạo FormCollection mới hoặc cập nhật
      FormCollection formCollection = FormCollection(
        id: userAccount.formCollection?.id ?? 1,
        height: _height,
        weight: _weight,
        week: _week,
        createdAt: _createdAt ?? DateTime.now(),
        lastestUpdate: DateTime.now(),
      );

      // Cập nhật lên Firebase
      await AccountService.updateUserAndFormCollection(
        uid: uid,
        name: _nameController.text.trim(),
        formCollection: formCollection,
      );

      // Cập nhật local state
      final updatedUserAccount = userAccount.copyWith(
        formCollection: formCollection,
      );
      updatedUserAccount.name = _nameController.text.trim();
      await BaseCommon().saveUserAccount(updatedUserAccount);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Cập nhật thông tin thành công!'),
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

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
    } catch (e) {
      log('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Lỗi khi cập nhật: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showHeightPicker() async {
    double tempHeight = _height;
    final double? picked = await showDialog<double>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Chọn chiều cao'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${tempHeight.toStringAsFixed(0)} cm',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: managerColor.primary,
                        ),
                      ),
                      SizedBox(height: 20),
                      NumberPicker(
                        value: tempHeight.toInt(),
                        minValue: 100,
                        maxValue: 250,
                        onChanged: (value) {
                          setDialogState(() {
                            tempHeight = value.toDouble();
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(tempHeight),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: managerColor.primary,
                      ),
                      child: Text('Xác nhận'),
                    ),
                  ],
                ),
          ),
    );

    if (picked != null) {
      setState(() {
        _height = picked;
      });
    }
  }

  Future<void> _showWeightPicker() async {
    int tempWeight = _weight;
    final int? picked = await showDialog<int>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Chọn cân nặng'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$tempWeight kg',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: managerColor.primary,
                        ),
                      ),
                      SizedBox(height: 20),
                      NumberPicker(
                        value: tempWeight,
                        minValue: 30,
                        maxValue: 150,
                        onChanged: (value) {
                          setDialogState(() {
                            tempWeight = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(tempWeight),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: managerColor.primary,
                      ),
                      child: Text('Xác nhận'),
                    ),
                  ],
                ),
          ),
    );

    if (picked != null) {
      setState(() {
        _weight = picked;
      });
    }
  }

  Future<void> _showWeekPicker() async {
    int tempWeek = _week;
    final int? picked = await showDialog<int>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Chọn tuần thai'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tuần $tempWeek',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: managerColor.primary,
                        ),
                      ),
                      SizedBox(height: 20),
                      NumberPicker(
                        value: tempWeek,
                        minValue: 1,
                        maxValue: 40,
                        onChanged: (value) {
                          setDialogState(() {
                            tempWeek = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(tempWeek),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: managerColor.primary,
                      ),
                      child: Text('Xác nhận'),
                    ),
                  ],
                ),
          ),
    );

    if (picked != null) {
      setState(() {
        _week = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAccount = BaseCommon().userAccount;
    final formCollection = userAccount.formCollection;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Thông tin cá nhân'),
        backgroundColor: managerColor.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _toggleEdit,
              tooltip: 'Chỉnh sửa',
            )
          else
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _isLoading ? null : _toggleEdit,
              tooltip: 'Hủy',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),

              SizedBox(height: 30),

              // Basic Information Section
              _buildSectionTitle('Thông tin cơ bản'),
              SizedBox(height: 15),
              _buildInfoCard(
                children: [
                  _buildEditableField(
                    label: 'Họ và tên',
                    icon: Icons.person_outline,
                    controller: _nameController,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      if (value.trim().length < 2) {
                        return 'Họ và tên phải có ít nhất 2 ký tự';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildReadOnlyField(
                    label: 'Email',
                    icon: Icons.email_outlined,
                    value: _emailController.text,
                    subtitle: 'Email không thể thay đổi',
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Pregnancy Information Section
              if (formCollection != null) ...[
                _buildSectionTitle('Thông tin thai kỳ'),
                SizedBox(height: 15),
                _buildInfoCard(
                  children: [
                    _buildEditableInfoItem(
                      label: 'Chiều cao',
                      icon: Icons.height,
                      value: '${_height.toStringAsFixed(0)} cm',
                      onTap: _isEditing ? _showHeightPicker : null,
                    ),
                    SizedBox(height: 20),
                    _buildEditableInfoItem(
                      label: 'Cân nặng',
                      icon: Icons.monitor_weight,
                      value: '$_weight kg',
                      onTap: _isEditing ? _showWeightPicker : null,
                    ),
                    SizedBox(height: 20),
                    _buildReadOnlyField(
                      label: 'Tuần thai hiện tại',
                      icon: Icons.calendar_today,
                      value: 'Tuần $_currentWeek',
                      subtitle: 'Tự động tính toán dựa trên ngày bắt đầu',
                    ),
                    SizedBox(height: 20),
                    if (_isEditing)
                      _buildEditableInfoItem(
                        label: 'Tuần thai ban đầu',
                        icon: Icons.edit_calendar,
                        value: 'Tuần $_week',
                        onTap: _showWeekPicker,
                      ),
                    if (_isEditing) SizedBox(height: 20),
                    _buildReadOnlyField(
                      label: 'Ngày bắt đầu thai kỳ',
                      icon: Icons.event,
                      value:
                          '${formCollection.createdAt.day}/${formCollection.createdAt.month}/${formCollection.createdAt.year}',
                    ),
                    SizedBox(height: 20),
                    _buildReadOnlyField(
                      label: 'Ngày dự sinh',
                      icon: Icons.cake,
                      value: _formatDate(
                        UtilsCommon.calculateDueDate(
                          formCollection.createdAt,
                          _week,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildReadOnlyField(
                      label: 'Ngày hiện tại trong thai kỳ',
                      icon: Icons.today,
                      value:
                          'Ngày thứ ${UtilsCommon.getCurrentDayInPregnancy(formCollection.createdAt, formCollection.week)}',
                    ),
                  ],
                ),
              ] else ...[
                _buildSectionTitle('Thông tin thai kỳ'),
                SizedBox(height: 15),
                _buildInfoCard(
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Chưa có thông tin thai kỳ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Vui lòng cập nhật thông tin thai kỳ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 30),

              // Save Button
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: managerColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child:
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
                            : Text(
                              'Lưu thông tin',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink.shade400, Colors.pink.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade200, Colors.pink.shade300],
                  ),
                ),
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin tài khoản',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  BaseCommon().userAccount.name,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  BaseCommon().userAccount.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildEditableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool enabled,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: managerColor.primary),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: managerColor.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required IconData icon,
    required String value,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInfoItem({
    required String label,
    required IconData icon,
    required String value,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: managerColor.primary),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: onTap != null ? Colors.pink.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border:
                  onTap != null
                      ? Border.all(color: managerColor.primary.withOpacity(0.3))
                      : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: managerColor.primary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
