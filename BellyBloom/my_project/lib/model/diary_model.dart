import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  String? id;
  String userId;
  DateTime date;
  String content;
  List<String> imageUrls;
  DateTime createdAt;
  DateTime updatedAt;

  DiaryModel({
    this.id,
    required this.userId,
    required this.date,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiaryModel.fromJson(Map<String, dynamic> json, String id) {
    return DiaryModel(
      id: id,
      userId: json['userId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      content: json['content'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper methods
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get dayOfWeek {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[date.weekday % 7];
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String get relativeDate {
    if (isToday) return 'Hôm nay';
    if (isYesterday) return 'Hôm qua';

    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference < 7) {
      return '$difference ngày trước';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks tuần trước';
    } else {
      return formattedDate;
    }
  }
}
