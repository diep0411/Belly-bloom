import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/model/health_metric_model.dart';

class HealthMetricService {
  static const String collection = 'health_metrics';

  // Add or update health metric
  static Future<bool> saveHealthMetric(HealthMetricModel metric) async {
    try {
      if (metric.id == null) {
        // Create new
        await FirebaseFirestore.instance
            .collection(collection)
            .add(metric.toJson());
      } else {
        // Update existing
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(metric.id)
            .update(metric.toJson());
      }
      return true;
    } catch (e) {
      log('Error saving health metric: $e');
      return false;
    }
  }

  // Get health metrics for a user
  static Future<List<HealthMetricModel>> getHealthMetrics(String userId) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userId)
              // .orderBy('date', descending: false)
              .get();
      // Sort thủ công theo date
      final healthMetrics =
          snapshot.docs
              .map((doc) => HealthMetricModel.fromJson(doc.data(), doc.id))
              .toList();
      //ngược lại
      healthMetrics.sort((a, b) => a.date.compareTo(b.date));
      return healthMetrics;

      // return snapshot.docs
      //     .map((doc) => HealthMetricModel.fromJson(doc.data(), doc.id))
      //     .toList();
    } catch (e) {
      log('Error loading health metrics: $e');
      return [];
    }
  }

  // Get health metric for a specific date
  static Future<HealthMetricModel?> getHealthMetricForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      // Normalize date to start of day for comparison
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final snapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('date', isLessThan: Timestamp.fromDate(endOfDay))
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return HealthMetricModel.fromJson(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      log('Error getting health metric for date: $e');
      return null;
    }
  }

  // Delete health metric
  static Future<bool> deleteHealthMetric(String id) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(id).delete();
      return true;
    } catch (e) {
      log('Error deleting health metric: $e');
      return false;
    }
  }
}
