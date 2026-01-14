class BlogModel {
  String? id;
  String title;
  String subtitle;
  String content;
  String imageUrl;
  List<int> targetWeeks; // Các tuần thai kỳ phù hợp với blog này
  DateTime? createdAt;
  DateTime? updatedAt;

  BlogModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.imageUrl,
    this.targetWeeks = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json, String id) {
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

    // Handle createdAt - backward compatible
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt']);
      } catch (e) {
        createdAt = null;
      }
    }

    // Handle updatedAt - backward compatible
    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(json['updatedAt']);
      } catch (e) {
        updatedAt = null;
      }
    }

    return BlogModel(
      id: id,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      targetWeeks: targetWeeks,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'content': content,
    'imageUrl': imageUrl,
    'targetWeeks': targetWeeks,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}