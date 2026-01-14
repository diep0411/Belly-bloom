class ExerciseModel {
  String? id;
  String title;
  String description;
  String content;
  String imageUrl;
  String category; // Loại bài tập: yoga, cardio, strength, breathing, etc.
  String difficulty; // Độ khó: beginner, intermediate, advanced
  int duration; // Thời gian thực hiện (phút)
  List<String> benefits; // Lợi ích của bài tập
  List<String> precautions; // Lưu ý khi thực hiện
  List<String> equipment; // Dụng cụ cần thiết
  List<String> instructions; // Hướng dẫn thực hiện
  List<String> targetWeeks; // Các tuần thai kỳ phù hợp
  bool isActive; // Trạng thái hoạt động
  DateTime createdAt;
  DateTime updatedAt;

  ExerciseModel({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.benefits,
    required this.precautions,
    required this.equipment,
    required this.instructions,
    required this.targetWeeks,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json, String id) {
    return ExerciseModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'beginner',
      duration: json['duration'] ?? 0,
      benefits: List<String>.from(json['benefits'] ?? []),
      precautions: List<String>.from(json['precautions'] ?? []),
      equipment: List<String>.from(json['equipment'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      targetWeeks: List<String>.from(json['targetWeeks'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
      'difficulty': difficulty,
      'duration': duration,
      'benefits': benefits,
      'precautions': precautions,
      'equipment': equipment,
      'instructions': instructions,
      'targetWeeks': targetWeeks,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ExerciseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    String? category,
    String? difficulty,
    int? duration,
    List<String>? benefits,
    List<String>? precautions,
    List<String>? equipment,
    List<String>? instructions,
    List<String>? targetWeeks,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      benefits: benefits ?? this.benefits,
      precautions: precautions ?? this.precautions,
      equipment: equipment ?? this.equipment,
      instructions: instructions ?? this.instructions,
      targetWeeks: targetWeeks ?? this.targetWeeks,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String get difficultyText {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Cơ bản';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      default:
        return 'Cơ bản';
    }
  }

  String get categoryText {
    switch (category.toLowerCase()) {
      case 'yoga':
        return 'Yoga';
      case 'cardio':
        return 'Cardio';
      case 'strength':
        return 'Tăng cường sức mạnh';
      case 'breathing':
        return 'Thở';
      case 'stretching':
        return 'Kéo giãn';
      case 'pelvic':
        return 'Sàn chậu';
      default:
        return category;
    }
  }

  String get durationText {
    if (duration < 60) {
      return '${duration} phút';
    } else {
      int hours = duration ~/ 60;
      int minutes = duration % 60;
      if (minutes == 0) {
        return '${hours} giờ';
      } else {
        return '${hours}h ${minutes}p';
      }
    }
  }
}
