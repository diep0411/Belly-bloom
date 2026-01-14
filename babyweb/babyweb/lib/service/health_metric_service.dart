import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:babyweb/model/health_metric_model.dart';

class HealthMetricService {
  static const String collection = 'health_metrics';

  // Get health metrics for a user
  static Future<List<HealthMetricModel>> getHealthMetrics(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .get();
      
      // Sort manually by date
      final healthMetrics = snapshot.docs
          .map((doc) => HealthMetricModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Sort by date ascending
      healthMetrics.sort((a, b) => a.date.compareTo(b.date));
      return healthMetrics;
    } catch (e) {
      log('Error loading health metrics: $e');
      return [];
    }
  }
}

