import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/model/appointment.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';
import 'package:my_project/service/appointment_service.dart';

class AppointmentFormPage extends StatefulWidget {
  final Appointment? appointment; // null = thêm mới

  const AppointmentFormPage({super.key, this.appointment});

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  AppointmentType _selectedType = AppointmentType.KHAM_BENH;
  bool _isReminder = true;
  int _reminderMinutes = 30;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.appointment != null) {
      final appointment = widget.appointment!;
      _titleController.text = appointment.title;
      _descriptionController.text = appointment.description;
      _locationController.text = appointment.location ?? '';
      _doctorNameController.text = appointment.doctorName ?? '';
      _notesController.text = appointment.notes ?? '';
      _selectedDate = appointment.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(appointment.dateTime);
      _selectedType = appointment.type;
      _isReminder = appointment.isReminder;
      _reminderMinutes = appointment.reminderMinutes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _doctorNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Loại lịch hẹn
                      _buildSectionTitle('Loại lịch hẹn'),
                      _buildTypeSelector(),
                      SizedBox(height: 24),

                      // Tiêu đề
                      _buildSectionTitle('Tiêu đề *'),
                      _buildTextField(
                        controller: _titleController,
                        hintText: 'Nhập tiêu đề lịch hẹn',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Thời gian
                      _buildSectionTitle('Thời gian *'),
                      SizedBox(height: 20),
                      _buildDateSelector(),
                      SizedBox(height: 20),

                      _buildTimeSelector(),
                      SizedBox(height: 20),

                      // Địa điểm
                      _buildSectionTitle('Địa điểm'),
                      _buildTextField(
                        controller: _locationController,
                        hintText: 'Nhập địa điểm (tùy chọn)',
                      ),
                      SizedBox(height: 20),

                      // Bác sĩ (chỉ hiển thị khi chọn khám bệnh)
                      if (_selectedType == AppointmentType.KHAM_BENH) ...[
                        _buildSectionTitle('Bác sĩ'),
                        _buildTextField(
                          controller: _doctorNameController,
                          hintText: 'Tên bác sĩ (tùy chọn)',
                        ),
                        SizedBox(height: 20),
                      ],

                      // Mô tả
                      _buildSectionTitle('Mô tả'),
                      _buildTextField(
                        controller: _descriptionController,
                        hintText: 'Nhập mô tả chi tiết',
                        maxLines: 4,
                      ),
                      SizedBox(height: 20),

                      // Ghi chú
                      _buildSectionTitle('Ghi chú'),
                      _buildTextField(
                        controller: _notesController,
                        hintText: 'Ghi chú thêm (tùy chọn)',
                        maxLines: 3,
                      ),
                      SizedBox(height: 24),

                      // Nhắc nhở
                      _buildSectionTitle('Nhắc nhở'),
                      _buildReminderSettings(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: managerColor.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appointment == null
                      ? 'Thêm lịch hẹn'
                      : 'Chỉnh sửa lịch hẹn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: UtilsReponsive.formatFontSize(20, context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Điền thông tin chi tiết cho lịch hẹn',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: UtilsReponsive.formatFontSize(14, context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.appointment == null ? Icons.add : Icons.edit,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: UtilsReponsive.formatFontSize(16, context),
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<AppointmentType>(
        value: _selectedType,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items:
            AppointmentType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        size: 20,
                        color: _getTypeColor(type),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      _getTypeDisplayName(type),
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(16, context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedType = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: managerColor.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.blue.shade600,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngày',
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(12, context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(16, context),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _selectTime,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  size: 20,
                  color: Colors.green.shade600,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giờ',
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(12, context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _selectedTime.format(context),
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(16, context),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications,
                  size: 20,
                  color: Colors.amber.shade600,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bật nhắc nhở',
                  style: TextStyle(
                    fontSize: UtilsReponsive.formatFontSize(16, context),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Switch(
                value: _isReminder,
                onChanged: (value) {
                  setState(() {
                    _isReminder = value;
                  });
                },
                activeColor: managerColor.primary,
              ),
            ],
          ),
          if (_isReminder) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonFormField<int>(
                value: _reminderMinutes,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                items:
                    [15, 30, 60, 120, 240].map((minutes) {
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text(
                          '$minutes phút trước',
                          style: TextStyle(
                            fontSize: UtilsReponsive.formatFontSize(
                              14,
                              context,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _reminderMinutes = value;
                    });
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: UtilsReponsive.formatFontSize(16, context),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: managerColor.primary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        widget.appointment == null
                            ? 'Thêm lịch hẹn'
                            : 'Cập nhật',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: UtilsReponsive.formatFontSize(16, context),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final appointment = Appointment(
          id: widget.appointment?.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: dateTime,
          location:
              _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
          type: _selectedType,
          isReminder: _isReminder,
          reminderMinutes: _reminderMinutes,
          doctorName:
              _doctorNameController.text.trim().isEmpty
                  ? null
                  : _doctorNameController.text.trim(),
          notes:
              _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
          createdAt: widget.appointment?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        bool success;
        if (widget.appointment == null) {
          final id = await AppointmentService.addAppointment(appointment);
          success = id != null;
        } else {
          success = await AppointmentService.updateAppointment(appointment);
        }

        if (success) {
          // Quay lại trang trước và reload dữ liệu
          Navigator.of(context).pop(true);
        } else {
          _showErrorSnackBar('Có lỗi xảy ra khi lưu lịch hẹn');
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  IconData _getTypeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.KHAM_BENH:
        return Icons.medical_services;
      case AppointmentType.NHAC_NHO:
        return Icons.notifications;
      case AppointmentType.KHAC:
        return Icons.event;
    }
  }

  Color _getTypeColor(AppointmentType type) {
    switch (type) {
      case AppointmentType.KHAM_BENH:
        return Colors.red.shade600;
      case AppointmentType.NHAC_NHO:
        return Colors.blue.shade600;
      case AppointmentType.KHAC:
        return Colors.green.shade600;
    }
  }

  String _getTypeDisplayName(AppointmentType type) {
    switch (type) {
      case AppointmentType.KHAM_BENH:
        return 'Khám bệnh';
      case AppointmentType.NHAC_NHO:
        return 'Nhắc nhở';
      case AppointmentType.KHAC:
        return 'Khác';
    }
  }
}
