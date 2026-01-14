import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/model/appointment.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';

class AppointmentDialog extends StatefulWidget {
  final Appointment? appointment; // null = thêm mới
  final Function(Appointment)? onSave;

  const AppointmentDialog({super.key, this.appointment, this.onSave});

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: managerColor.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.appointment == null ? Icons.add : Icons.edit,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.appointment == null
                          ? 'Thêm lịch hẹn'
                          : 'Chỉnh sửa lịch hẹn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: UtilsReponsive.formatFontSize(18, context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
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
                      SizedBox(height: 20),

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
                      SizedBox(height: 16),

                      // Thời gian
                      _buildSectionTitle('Thời gian *'),
                      Row(
                        children: [
                          Expanded(child: _buildDateSelector()),
                          SizedBox(width: 12),
                          Expanded(child: _buildTimeSelector()),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Địa điểm
                      _buildSectionTitle('Địa điểm'),
                      _buildTextField(
                        controller: _locationController,
                        hintText: 'Nhập địa điểm (tùy chọn)',
                      ),
                      SizedBox(height: 16),

                      // Bác sĩ (chỉ hiển thị khi chọn khám bệnh)
                      if (_selectedType == AppointmentType.KHAM_BENH) ...[
                        _buildSectionTitle('Bác sĩ'),
                        _buildTextField(
                          controller: _doctorNameController,
                          hintText: 'Tên bác sĩ (tùy chọn)',
                        ),
                        SizedBox(height: 16),
                      ],

                      // Mô tả
                      _buildSectionTitle('Mô tả'),
                      _buildTextField(
                        controller: _descriptionController,
                        hintText: 'Nhập mô tả chi tiết',
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),

                      // Ghi chú
                      _buildSectionTitle('Ghi chú'),
                      _buildTextField(
                        controller: _notesController,
                        hintText: 'Ghi chú thêm (tùy chọn)',
                        maxLines: 2,
                      ),
                      SizedBox(height: 20),

                      // Nhắc nhở
                      _buildSectionTitle('Nhắc nhở'),
                      _buildReminderSettings(),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: managerColor.primary,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        widget.appointment == null ? 'Thêm' : 'Cập nhật',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: UtilsReponsive.formatFontSize(14, context),
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<AppointmentType>(
        value: _selectedType,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items:
            AppointmentType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      size: 20,
                      color: _getTypeColor(type),
                    ),
                    SizedBox(width: 8),
                    Text(_getTypeDisplayName(type)),
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
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: managerColor.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: _selectTime,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(_selectedTime.format(context), style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: _isReminder,
              onChanged: (value) {
                setState(() {
                  _isReminder = value ?? false;
                });
              },
              activeColor: managerColor.primary,
            ),
            Text('Bật nhắc nhở'),
          ],
        ),
        if (_isReminder) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
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
                      child: Text('$minutes phút trước'),
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

  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
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

      if (widget.onSave != null) {
        widget.onSave!(appointment);
      }
      Navigator.of(context).pop();
    }
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
