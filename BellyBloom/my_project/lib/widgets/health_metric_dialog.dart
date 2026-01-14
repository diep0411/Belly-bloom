import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/model/health_metric_model.dart';
import 'package:my_project/resoucre/ColorManager.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/service/health_metric_service.dart';

class HealthMetricDialog extends StatefulWidget {
  final HealthMetricModel? metric;

  const HealthMetricDialog({super.key, this.metric});

  @override
  State<HealthMetricDialog> createState() => _HealthMetricDialogState();
}

class _HealthMetricDialogState extends State<HealthMetricDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bloodPressureSystolicController =
      TextEditingController();
  final TextEditingController _bloodPressureDiastolicController =
      TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.metric != null) {
      _loadMetricData();
    }
  }

  void _loadMetricData() {
    final metric = widget.metric!;
    _selectedDate = metric.date;
    _weightController.text = metric.weight?.toString() ?? '';
    _heightController.text = metric.height?.toString() ?? '';
    _bloodPressureSystolicController.text =
        metric.bloodPressureSystolic?.toString() ?? '';
    _bloodPressureDiastolicController.text =
        metric.bloodPressureDiastolic?.toString() ?? '';
    _heartRateController.text = metric.heartRate?.toString() ?? '';
    _notesController.text = metric.notes ?? '';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMetric() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = BaseCommon().userAccount.uid;
      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng đăng nhập'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final now = DateTime.now();
      final metric = HealthMetricModel(
        id: widget.metric?.id,
        userId: userId,
        date: _selectedDate,
        weight:
            _weightController.text.isNotEmpty
                ? double.tryParse(_weightController.text)
                : null,
        height:
            _heightController.text.isNotEmpty
                ? double.tryParse(_heightController.text)
                : null,
        bloodPressureSystolic:
            _bloodPressureSystolicController.text.isNotEmpty
                ? double.tryParse(_bloodPressureSystolicController.text)
                : null,
        bloodPressureDiastolic:
            _bloodPressureDiastolicController.text.isNotEmpty
                ? double.tryParse(_bloodPressureDiastolicController.text)
                : null,
        heartRate:
            _heartRateController.text.isNotEmpty
                ? int.tryParse(_heartRateController.text)
                : null,
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
        createdAt: widget.metric?.createdAt ?? now,
        updatedAt: now,
      );

      final success = await HealthMetricService.saveHealthMetric(metric);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.metric == null
                  ? 'Đã thêm thông số thành công'
                  : 'Đã cập nhật thông số thành công',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi lưu'),
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
                color: managerColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.analytics, color: managerColor.primary, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.metric == null
                          ? 'Thêm thông số'
                          : 'Chỉnh sửa thông số',
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(18, context),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
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
                      // Date picker
                      Text(
                        'Ngày *',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(14, context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 12),
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: TextStyle(
                                  fontSize: UtilsReponsive.formatFontSize(
                                    14,
                                    context,
                                  ),
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Weight
                      _buildTextField(
                        label: 'Cân nặng (kg)',
                        controller: _weightController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        icon: Icons.monitor_weight,
                      ),
                      SizedBox(height: 20),

                      // Height
                      _buildTextField(
                        label: 'Chiều cao (cm)',
                        controller: _heightController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        icon: Icons.height,
                      ),
                      SizedBox(height: 20),

                      // Blood Pressure
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Huyết áp tâm thu',
                              controller: _bloodPressureSystolicController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              icon: Icons.favorite,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              label: 'Huyết áp tâm trương',
                              controller: _bloodPressureDiastolicController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              icon: Icons.favorite,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Heart Rate
                      _buildTextField(
                        label: 'Nhịp tim (bpm)',
                        controller: _heartRateController,
                        keyboardType: TextInputType.number,
                        icon: Icons.favorite_border,
                      ),
                      SizedBox(height: 20),

                      // Notes
                      Text(
                        'Ghi chú',
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(14, context),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Nhập ghi chú (tùy chọn)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: managerColor.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Hủy'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveMetric,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: managerColor.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                            : Text(widget.metric == null ? 'Thêm' : 'Cập nhật'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: UtilsReponsive.formatFontSize(14, context),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: managerColor.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final num =
                  keyboardType == TextInputType.number
                      ? int.tryParse(value)
                      : double.tryParse(value);
              if (num == null) {
                return 'Vui lòng nhập số hợp lệ';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
