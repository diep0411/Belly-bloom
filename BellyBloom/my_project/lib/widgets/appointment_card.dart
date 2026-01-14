import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/model/appointment.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: UtilsReponsive.height(15, context),
        vertical: UtilsReponsive.height(8, context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _getAppointmentColor().withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getAppointmentColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(UtilsReponsive.height(15, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với icon và type
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getAppointmentColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAppointmentIcon(),
                        color: _getAppointmentColor(),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.title,
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(
                                16,
                                context,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            appointment.typeDisplayName,
                            style: TextStyle(
                              fontSize: UtilsReponsive.formatFontSize(
                                12,
                                context,
                              ),
                              color: _getAppointmentColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action buttons
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit' && onEdit != null) {
                            onEdit!();
                          } else if (value == 'delete' && onDelete != null) {
                            onDelete!();
                          }
                        },
                        itemBuilder:
                            (context) => [
                              if (onEdit != null)
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Chỉnh sửa'),
                                    ],
                                  ),
                                ),
                              if (onDelete != null)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Xóa'),
                                    ],
                                  ),
                                ),
                            ],
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 12),

                // Thời gian
                _buildInfoRow(
                  icon: Icons.access_time,
                  text: DateFormat(
                    'dd/MM/yyyy - HH:mm',
                  ).format(appointment.dateTime),
                  color: Colors.blue.shade600,
                ),

                // Địa điểm (nếu có)
                if (appointment.location != null &&
                    appointment.location!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.location_on,
                    text: appointment.location!,
                    color: Colors.green.shade600,
                  ),

                // Bác sĩ (nếu có)
                if (appointment.doctorName != null &&
                    appointment.doctorName!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.person,
                    text: appointment.doctorName!,
                    color: Colors.orange.shade600,
                  ),

                // Mô tả
                if (appointment.description.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      appointment.description,
                      style: TextStyle(
                        fontSize: UtilsReponsive.formatFontSize(14, context),
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Status indicator
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: UtilsReponsive.formatFontSize(11, context),
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Spacer(),
                    // Reminder indicator
                    if (appointment.isReminder)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications,
                              size: 12,
                              color: Colors.amber.shade700,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${appointment.reminderMinutes}p',
                              style: TextStyle(
                                fontSize: UtilsReponsive.formatFontSize(
                                  11,
                                  context,
                                ),
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAppointmentColor() {
    switch (appointment.type) {
      case AppointmentType.KHAM_BENH:
        return Colors.red.shade600;
      case AppointmentType.NHAC_NHO:
        return Colors.blue.shade600;
      case AppointmentType.KHAC:
        return Colors.green.shade600;
    }
  }

  IconData _getAppointmentIcon() {
    switch (appointment.type) {
      case AppointmentType.KHAM_BENH:
        return Icons.medical_services;
      case AppointmentType.NHAC_NHO:
        return Icons.notifications;
      case AppointmentType.KHAC:
        return Icons.event;
    }
  }

  Color _getStatusColor() {
    if (appointment.isPast) {
      return Colors.grey.shade600;
    } else if (appointment.isToday) {
      return Colors.orange.shade600;
    } else {
      return Colors.green.shade600;
    }
  }

  String _getStatusText() {
    if (appointment.isPast) {
      return 'Đã qua';
    } else if (appointment.isToday) {
      return 'Hôm nay';
    } else {
      return 'Sắp tới';
    }
  }
}
