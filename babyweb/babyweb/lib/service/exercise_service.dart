import 'package:babyweb/model/exercise_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseService {
  static String collection = 'exercises';

  // Create new exercise
  static Future<bool> addExercise(ExerciseModel exercise) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .add(exercise.toJson());
      return true;
    } catch (e) {
      print('Error adding exercise: $e');
      return false;
    }
  }

  // Get all exercises
  static Future<List<ExerciseModel>> loadExercises() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading exercises: $e');
      return [];
    }
  }

  // Get active exercises only
  static Future<List<ExerciseModel>> loadActiveExercises() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading active exercises: $e');
      return [];
    }
  }

  // Get exercise by ID
  static Future<ExerciseModel?> getExerciseById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return ExerciseModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting exercise: $e');
      return null;
    }
  }

  // Update exercise
  static Future<bool> updateExercise(ExerciseModel exercise) async {
    try {
      if (exercise.id == null) return false;
      
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(exercise.id)
          .update(exercise.toJson());
      return true;
    } catch (e) {
      print('Error updating exercise: $e');
      return false;
    }
  }

  // Delete exercise
  static Future<bool> deleteExercise(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting exercise: $e');
      return false;
    }
  }

  // Get exercises by category
  static Future<List<ExerciseModel>> getExercisesByCategory(String category) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading exercises by category: $e');
      return [];
    }
  }

  // Get exercises by difficulty
  static Future<List<ExerciseModel>> getExercisesByDifficulty(String difficulty) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('difficulty', isEqualTo: difficulty)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading exercises by difficulty: $e');
      return [];
    }
  }

  // Get exercises by target weeks
  static Future<List<ExerciseModel>> getExercisesByTargetWeeks(List<String> weeks) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .where((exercise) {
            return exercise.targetWeeks.any((week) => weeks.contains(week));
          })
          .toList();
    } catch (e) {
      print('Error loading exercises by target weeks: $e');
      return [];
    }
  }

  // Get exercises by duration range
  static Future<List<ExerciseModel>> getExercisesByDurationRange(int minDuration, int maxDuration) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('duration', isGreaterThanOrEqualTo: minDuration)
          .where('duration', isLessThanOrEqualTo: maxDuration)
          .where('isActive', isEqualTo: true)
          .orderBy('duration')
          .get();
      
      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading exercises by duration range: $e');
      return [];
    }
  }

  // Toggle exercise active status
  static Future<bool> toggleExerciseStatus(String id, bool isActive) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error toggling exercise status: $e');
      return false;
    }
  }

  // Get all categories
  static Future<List<String>> getAllCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('isActive', isEqualTo: true)
          .get();
      
      Set<String> categories = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['category'] != null) {
          categories.add(data['category']);
        }
      }
      
      return categories.toList()..sort();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Search exercises
  static Future<List<ExerciseModel>> searchExercises(String query) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ExerciseModel.fromJson(doc.data(), doc.id))
          .where((exercise) {
            return exercise.title.toLowerCase().contains(query.toLowerCase()) ||
                   exercise.description.toLowerCase().contains(query.toLowerCase()) ||
                   exercise.category.toLowerCase().contains(query.toLowerCase());
          })
          .toList();
    } catch (e) {
      print('Error searching exercises: $e');
      return [];
    }
  }
}
