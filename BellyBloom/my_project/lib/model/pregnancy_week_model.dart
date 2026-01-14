class PregnancyWeekModel {
  String? id;
  int weekNumber;
  String title;
  String description;
  String babyDevelopment;
  String motherChanges;
  String tips;
  String imageUrl;
  List<String> symptoms;
  List<String> recommendations;
  DateTime createdAt;
  DateTime updatedAt;

  PregnancyWeekModel({
    this.id,
    required this.weekNumber,
    required this.title,
    required this.description,
    required this.babyDevelopment,
    required this.motherChanges,
    required this.tips,
    required this.imageUrl,
    required this.symptoms,
    required this.recommendations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PregnancyWeekModel.fromJson(Map<String, dynamic> json, String id) {
    // Handle createdAt - backward compatible
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

    // Handle updatedAt - backward compatible
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

    // Handle symptoms
    List<String> symptoms = [];
    if (json['symptoms'] != null) {
      if (json['symptoms'] is List) {
        symptoms = (json['symptoms'] as List)
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    // Handle recommendations
    List<String> recommendations = [];
    if (json['recommendations'] != null) {
      if (json['recommendations'] is List) {
        recommendations = (json['recommendations'] as List)
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return PregnancyWeekModel(
      id: id,
      weekNumber: json['weekNumber'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      babyDevelopment: json['babyDevelopment'] ?? '',
      motherChanges: json['motherChanges'] ?? '',
      tips: json['tips'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      symptoms: symptoms,
      recommendations: recommendations,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekNumber': weekNumber,
      'title': title,
      'description': description,
      'babyDevelopment': babyDevelopment,
      'motherChanges': motherChanges,
      'tips': tips,
      'imageUrl': imageUrl,
      'symptoms': symptoms,
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PregnancyWeekModel copyWith({
    String? id,
    int? weekNumber,
    String? title,
    String? description,
    String? babyDevelopment,
    String? motherChanges,
    String? tips,
    String? imageUrl,
    List<String>? symptoms,
    List<String>? recommendations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PregnancyWeekModel(
      id: id ?? this.id,
      weekNumber: weekNumber ?? this.weekNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      babyDevelopment: babyDevelopment ?? this.babyDevelopment,
      motherChanges: motherChanges ?? this.motherChanges,
      tips: tips ?? this.tips,
      imageUrl: imageUrl ?? this.imageUrl,
      symptoms: symptoms ?? this.symptoms,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

