import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/model/pregnancy_week_model.dart';

class PregnancyWeekService {
  static const String collection = 'pregnancy_weeks';

  // Get pregnancy week by week number
  static Future<PregnancyWeekModel?> getPregnancyWeek(int weekNumber) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('weekNumber', isEqualTo: weekNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return PregnancyWeekModel.fromJson(
          doc.data(),
          doc.id,
        );
      }
      return null;
    } catch (e) {
      log('Error getting pregnancy week $weekNumber: $e');
      return null;
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
          .map((doc) {
            try {
              return PregnancyWeekModel.fromJson(
                doc.data(),
                doc.id,
              );
            } catch (e) {
              log('Error parsing pregnancy week ${doc.id}: $e');
              return null;
            }
          })
          .where((week) => week != null)
          .cast<PregnancyWeekModel>()
          .toList();
    } catch (e) {
      log('Error loading pregnancy weeks: $e');
      return [];
    }
  }

  // Get pregnancy weeks by range
  static Future<List<PregnancyWeekModel>> getPregnancyWeeksByRange(
    int startWeek,
    int endWeek,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('weekNumber', isGreaterThanOrEqualTo: startWeek)
          .where('weekNumber', isLessThanOrEqualTo: endWeek)
          .orderBy('weekNumber')
          .get();

      return snapshot.docs
          .map((doc) {
            try {
              return PregnancyWeekModel.fromJson(
                doc.data(),
                doc.id,
              );
            } catch (e) {
              log('Error parsing pregnancy week ${doc.id}: $e');
              return null;
            }
          })
          .where((week) => week != null)
          .cast<PregnancyWeekModel>()
          .toList();
    } catch (e) {
      log('Error loading pregnancy weeks by range: $e');
      return [];
    }
  }
}

