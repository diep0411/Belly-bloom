import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/model/exercise_model.dart';

class ExerciseService {
  static const String collection = 'exercises';

  // Load all active exercises
  static Future<List<ExerciseModel>> loadExercises() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('isActive', isEqualTo: true)
              .get();

      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('Error loading exercises: $e');
      return [];
    }
  }

  // Load exercises for specific week
  static Future<List<ExerciseModel>> loadExercisesForWeek(
    int weekNumber,
  ) async {
    try {
      final allExercises = await loadExercises();
      return allExercises
          .where((exercise) => exercise.isSuitableForWeek(weekNumber))
          .toList();
    } catch (e) {
      log('Error loading exercises for week: $e');
      return [];
    }
  }

  // Load exercises by category
  static Future<List<ExerciseModel>> loadExercisesByCategory(
    String category,
  ) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('isActive', isEqualTo: true)
              .where('category', isEqualTo: category)
              .get();

      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('Error loading exercises by category: $e');
      return [];
    }
  }

  // Load exercises by difficulty
  static Future<List<ExerciseModel>> loadExercisesByDifficulty(
    String difficulty,
  ) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('isActive', isEqualTo: true)
              .where('difficulty', isEqualTo: difficulty)
              .get();

      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('Error loading exercises by difficulty: $e');
      return [];
    }
  }

  // Search exercises
  static Future<List<ExerciseModel>> searchExercises(String query) async {
    try {
      final allExercises = await loadExercises();
      return allExercises.where((exercise) {
        return exercise.title.toLowerCase().contains(query.toLowerCase()) ||
            exercise.description.toLowerCase().contains(query.toLowerCase()) ||
            exercise.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      log('Error searching exercises: $e');
      return [];
    }
  }
}
