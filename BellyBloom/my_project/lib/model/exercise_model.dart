class ExerciseModel {
  String? id;
  String title;
  String description;
  String content;
  String imageUrl;
  String category;
  String difficulty;
  int duration; // in minutes
  List<String> benefits;
  List<String> precautions;
  List<String> equipment;
  List<String> instructions;
  List<String> targetWeeks;
  bool isActive;
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
    this.isActive = true,
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
      category: json['category'] ?? 'yoga',
      difficulty: json['difficulty'] ?? 'beginner',
      duration: json['duration'] ?? 15,
      benefits: List<String>.from(json['benefits'] ?? []),
      precautions: List<String>.from(json['precautions'] ?? []),
      equipment: List<String>.from(json['equipment'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      targetWeeks: List<String>.from(json['targetWeeks'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
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

  // Helper methods
  String get categoryDisplayName {
    switch (category) {
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

  String get difficultyDisplayName {
    switch (difficulty) {
      case 'beginner':
        return 'Cơ bản';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      default:
        return difficulty;
    }
  }

  // Check if exercise is suitable for specific week
  bool isSuitableForWeek(int weekNumber) {
    return targetWeeks.contains(weekNumber.toString());
  }
}
