import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/model/reminder_model.dart';

class ReminderService {
  static const String collection = 'reminders';

  // Get all active reminders
  static Future<List<ReminderModel>> loadReminders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('Error loading reminders: $e');
      return [];
    }
  }

  // Get reminders by week number
  static Future<List<ReminderModel>> loadRemindersByWeek(int weekNumber) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('weekNumber', isEqualTo: weekNumber)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('Error loading reminders by week: $e');
      return [];
    }
  }
}

