import 'package:cloud_firestore/cloud_firestore.dart';

class HealthMetricModel {
  String? id;
  String userId;
  DateTime date; // Ngày ghi nhận
  double? weight; // Cân nặng (kg)
  double? height; // Chiều cao (cm) - thường không đổi nhưng có thể cập nhật
  double? bloodPressureSystolic; // Huyết áp tâm thu
  double? bloodPressureDiastolic; // Huyết áp tâm trương
  int? heartRate; // Nhịp tim
  String? notes; // Ghi chú
  DateTime createdAt;
  DateTime updatedAt;

  HealthMetricModel({
    this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.height,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthMetricModel.fromJson(Map<String, dynamic> json, String id) {
    return HealthMetricModel(
      id: id,
      userId: json['userId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      bloodPressureSystolic: json['bloodPressureSystolic']?.toDouble(),
      bloodPressureDiastolic: json['bloodPressureDiastolic']?.toDouble(),
      heartRate: json['heartRate'] is int ? json['heartRate'] : json['heartRate']?.toInt(),
      notes: json['notes'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'height': height,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'heartRate': heartRate,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  HealthMetricModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? weight,
    double? height,
    double? bloodPressureSystolic,
    double? bloodPressureDiastolic,
    int? heartRate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthMetricModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodPressureSystolic: bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      heartRate: heartRate ?? this.heartRate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

