import 'package:babyweb/model/reminder_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderService {
  static String collection = 'reminders';

  // Create new reminder
  static Future<bool> addReminder(ReminderModel reminder) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .add(reminder.toJson());
      return true;
    } catch (e) {
      print('Error adding reminder: $e');
      return false;
    }
  }

  // Get all reminders
  static Future<List<ReminderModel>> loadReminders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          // .orderBy('weekNumber')
          // .orderBy('priority')
          .get();
      
      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading reminders: $e');
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
          // .orderBy('priority')
          .get();
      
      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading reminders by week: $e');
      return [];
    }
  }

  // Get reminder by ID
  static Future<ReminderModel?> getReminderById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return ReminderModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting reminder: $e');
      return null;
    }
  }

  // Update reminder
  static Future<bool> updateReminder(ReminderModel reminder) async {
    try {
      if (reminder.id == null) return false;
      
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(reminder.id)
          .update(reminder.toJson());
      return true;
    } catch (e) {
      print('Error updating reminder: $e');
      return false;
    }
  }

  // Delete reminder
  static Future<bool> deleteReminder(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting reminder: $e');
      return false;
    }
  }

  // Get reminders by priority
  static Future<List<ReminderModel>> loadRemindersByPriority(String priority) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('priority', isEqualTo: priority)
          .where('isActive', isEqualTo: true)
          // .orderBy('weekNumber')
          .get();
      
      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading reminders by priority: $e');
      return [];
    }
  }
}

