import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentType {
  KHAM_BENH, // Lịch khám bệnh
  NHAC_NHO, // Nhắc nhở cá nhân
  KHAC, // Lịch khác
}

class Appointment {
  String? id;
  String title;
  String description;
  DateTime dateTime;
  String? location;
  AppointmentType type;
  bool isReminder;
  int reminderMinutes; // 15, 30, 60 phút trước
  String? doctorName;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  Appointment({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.location,
    required this.type,
    this.isReminder = true,
    this.reminderMinutes = 30,
    this.doctorName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(String id, Map<String, dynamic> json) {
    return Appointment(
      id: id,
      title: json['title'],
      description: json['description'],
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      location: json['location'],
      type: AppointmentType.values.firstWhere(
        (e) => e.toString() == 'AppointmentType.${json['type']}',
        orElse: () => AppointmentType.KHAC,
      ),
      isReminder: json['isReminder'] ?? true,
      reminderMinutes: json['reminderMinutes'] ?? 30,
      doctorName: json['doctorName'],
      notes: json['notes'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'type': type.toString().split('.').last,
      'isReminder': isReminder,
      'reminderMinutes': reminderMinutes,
      'doctorName': doctorName,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper methods
  String get typeDisplayName {
    switch (type) {
      case AppointmentType.KHAM_BENH:
        return 'Khám bệnh';
      case AppointmentType.NHAC_NHO:
        return 'Nhắc nhở';
      case AppointmentType.KHAC:
        return 'Khác';
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  bool get isPast {
    return dateTime.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    return dateTime.isAfter(DateTime.now()) && !isToday;
  }
}
