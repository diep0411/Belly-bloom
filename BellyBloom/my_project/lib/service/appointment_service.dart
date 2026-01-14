import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/model/appointment.dart';
import 'package:my_project/service/base_common.dart';
import 'package:my_project/service/notification_service.dart';

class AppointmentService {
  static const String collection = 'appointments';

  // Lấy tất cả lịch hẹn của user
  static Future<List<Appointment>> getAppointments() async {
    try {
      final userUid = BaseCommon().userAccount.uid;
      if (userUid == null) return [];

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userUid)
              .get();

      final appointments =
          querySnapshot.docs
              .map((doc) => Appointment.fromJson(doc.id, doc.data()))
              .toList();

      // Sort thủ công theo dateTime
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return appointments;
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  // Lấy lịch hẹn theo loại
  static Future<List<Appointment>> getAppointmentsByType(
    AppointmentType type,
  ) async {
    try {
      final userUid = BaseCommon().userAccount.uid;
      if (userUid == null) return [];

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userUid)
              .where('type', isEqualTo: type.toString().split('.').last)
              .get();

      final appointments =
          querySnapshot.docs
              .map((doc) => Appointment.fromJson(doc.id, doc.data()))
              .toList();

      // Sort thủ công theo dateTime
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return appointments;
    } catch (e) {
      print('Error getting appointments by type: $e');
      return [];
    }
  }

  // Thêm lịch hẹn mới
  static Future<String?> addAppointment(Appointment appointment) async {
    try {
      final userUid = BaseCommon().userAccount.uid;
      if (userUid == null) return null;

      final docRef = await FirebaseFirestore.instance
          .collection(collection)
          .add({...appointment.toJson(), 'userId': userUid});

      final appointmentId = docRef.id;

      // Schedule notification nếu có reminder
      if (appointment.isReminder && !appointment.isPast) {
        final appointmentWithId = Appointment(
          id: appointmentId,
          title: appointment.title,
          description: appointment.description,
          dateTime: appointment.dateTime,
          location: appointment.location,
          type: appointment.type,
          isReminder: appointment.isReminder,
          reminderMinutes: appointment.reminderMinutes,
          doctorName: appointment.doctorName,
          notes: appointment.notes,
          createdAt: appointment.createdAt,
          updatedAt: appointment.updatedAt,
        );
        await NotificationService.scheduleAppointmentNotification(
          appointmentWithId,
        );
      }

      return appointmentId;
    } catch (e) {
      print('Error adding appointment: $e');
      return null;
    }
  }

  // Cập nhật lịch hẹn
  static Future<bool> updateAppointment(Appointment appointment) async {
    log('updateAppointment: ${appointment.toJson()}');
    try {
      if (appointment.id == null) return false;

      // Cancel existing notification
      await NotificationService.cancelAppointmentNotification(appointment.id!);

      await FirebaseFirestore.instance
          .collection(collection)
          .doc(appointment.id)
          .update(appointment.toJson());

      // Schedule new notification nếu có reminder
      if (appointment.isReminder && !appointment.isPast) {
        await NotificationService.scheduleAppointmentNotification(appointment);
      }

      return true;
    } catch (e) {
      print('Error updating appointment: $e');
      return false;
    }
  }

  // Xóa lịch hẹn
  static Future<bool> deleteAppointment(String appointmentId) async {
    try {
      // Cancel notification trước khi xóa
      await NotificationService.cancelAppointmentNotification(appointmentId);

      await FirebaseFirestore.instance
          .collection(collection)
          .doc(appointmentId)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting appointment: $e');
      return false;
    }
  }

  // Lấy lịch hẹn sắp tới (trong 7 ngày tới)
  static Future<List<Appointment>> getUpcomingAppointments() async {
    try {
      final userUid = BaseCommon().userAccount.uid;
      if (userUid == null) return [];

      final now = DateTime.now();
      final nextWeek = now.add(Duration(days: 7));

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userUid)
              .get();

      final allAppointments =
          querySnapshot.docs
              .map((doc) => Appointment.fromJson(doc.id, doc.data()))
              .toList();

      // Filter và sort thủ công
      final upcomingAppointments =
          allAppointments
              .where(
                (appointment) =>
                    appointment.dateTime.isAfter(now) &&
                    appointment.dateTime.isBefore(nextWeek),
              )
              .toList();

      // Sort theo dateTime
      upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return upcomingAppointments;
    } catch (e) {
      print('Error getting upcoming appointments: $e');
      return [];
    }
  }

  // Tìm kiếm lịch hẹn
  static Future<List<Appointment>> searchAppointments(String query) async {
    try {
      final userUid = BaseCommon().userAccount.uid;
      if (userUid == null) return [];

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userUid)
              .get();

      final allAppointments =
          querySnapshot.docs
              .map((doc) => Appointment.fromJson(doc.id, doc.data()))
              .toList();

      // Filter by search query
      final filteredAppointments =
          allAppointments.where((appointment) {
            return appointment.title.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                appointment.description.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                (appointment.location?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false) ||
                (appointment.doctorName?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false);
          }).toList();

      // Sort thủ công theo dateTime
      filteredAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return filteredAppointments;
    } catch (e) {
      print('Error searching appointments: $e');
      return [];
    }
  }
}
