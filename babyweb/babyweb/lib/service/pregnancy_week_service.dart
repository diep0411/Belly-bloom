import 'package:babyweb/model/pregnancy_week_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PregnancyWeekService {
  static String collection = 'pregnancy_weeks';

  // Create new pregnancy week
  static Future<bool> addPregnancyWeek(PregnancyWeekModel pregnancyWeek) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .add(pregnancyWeek.toJson());
      return true;
    } catch (e) {
      print('Error adding pregnancy week: $e');
      return false;
    }
  }

  // Get all pregnancy weeks
  static Future<List<PregnancyWeekModel>> loadPregnancyWeeks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .orderBy('weekNumber')
          .get();
      
      return snapshot.docs
          .map((doc) => PregnancyWeekModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading pregnancy weeks: $e');
      return [];
    }
  }

  // Get pregnancy week by ID
  static Future<PregnancyWeekModel?> getPregnancyWeekById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return PregnancyWeekModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting pregnancy week: $e');
      return null;
    }
  }

  // Update pregnancy week
  static Future<bool> updatePregnancyWeek(PregnancyWeekModel pregnancyWeek) async {
    try {
      if (pregnancyWeek.id == null) return false;
      
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(pregnancyWeek.id)
          .update(pregnancyWeek.toJson());
      return true;
    } catch (e) {
      print('Error updating pregnancy week: $e');
      return false;
    }
  }

  // Delete pregnancy week
  static Future<bool> deletePregnancyWeek(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting pregnancy week: $e');
      return false;
    }
  }

  // Get pregnancy weeks by week range
  static Future<List<PregnancyWeekModel>> getPregnancyWeeksByRange(
      int startWeek, int endWeek) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('weekNumber', isGreaterThanOrEqualTo: startWeek)
          .where('weekNumber', isLessThanOrEqualTo: endWeek)
          .orderBy('weekNumber')
          .get();
      
      return snapshot.docs
          .map((doc) => PregnancyWeekModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading pregnancy weeks by range: $e');
      return [];
    }
  }

  // Check if week number already exists
  static Future<bool> isWeekNumberExists(int weekNumber, {String? excludeId}) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection(collection)
          .where('weekNumber', isEqualTo: weekNumber);
      
      if (excludeId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: excludeId);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking week number: $e');
      return false;
    }
  }
}
