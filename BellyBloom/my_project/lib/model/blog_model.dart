class BlogModel {
  String? id;
  String title;
  String subtitle;
  String content;
  String imageUrl;
  DateTime createdAt;
  DateTime updatedAt;
  List<int> targetWeeks; // Các tuần thai kỳ phù hợp với blog này

  BlogModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.targetWeeks = const [],
  });

  factory BlogModel.fromJson(Map<String, dynamic> json, String id) {
    // Handle createdAt - backward compatible với babyweb
    DateTime createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt']);
      } catch (e) {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    // Handle updatedAt - backward compatible với babyweb
    DateTime updatedAt;
    if (json['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(json['updatedAt']);
      } catch (e) {
        updatedAt = DateTime.now();
      }
    } else {
      updatedAt = DateTime.now();
    }

    // Handle targetWeeks - backward compatible
    List<int> targetWeeks = [];
    if (json['targetWeeks'] != null) {
      if (json['targetWeeks'] is List) {
        targetWeeks = (json['targetWeeks'] as List)
            .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
            .where((e) => e > 0)
            .toList();
      }
    }

    return BlogModel(
      id: id,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      targetWeeks: targetWeeks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'targetWeeks': targetWeeks,
    };
  }

  // Helper method to check if blog is for specific week
  bool isForWeek(int weekNumber) {
    // Ưu tiên check targetWeeks nếu có
    if (targetWeeks.isNotEmpty) {
      return targetWeeks.contains(weekNumber);
    }

    // Fallback về text search (backward compatible)
    String weekStr = weekNumber.toString();
    String lowerTitle = title.toLowerCase();
    String lowerSubtitle = subtitle.toLowerCase();
    String lowerContent = content.toLowerCase();

    return lowerTitle.contains('tuần $weekStr') ||
        lowerTitle.contains('week $weekStr') ||
        lowerSubtitle.contains('tuần $weekStr') ||
        lowerSubtitle.contains('week $weekStr') ||
        lowerContent.contains('tuần $weekStr') ||
        lowerContent.contains('week $weekStr');
  }
}
