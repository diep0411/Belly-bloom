import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_project/model/appointment.dart';
import 'package:my_project/service/appointment_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        'launch_background',
      );

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create Android notification channel for appointments
      const appointmentChannel = AndroidNotificationChannel(
        'appointment_channel',
        'Lịch hẹn',
        description: 'Thông báo về lịch hẹn và nhắc nhở',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(appointmentChannel);

      // Request exact alarm permission for Android 12+ (if needed)
      await _requestExactAlarmPermission();

      // Request permissions (iOS)
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _isInitialized = true;
      log('NotificationService initialized');
    } catch (e) {
      log('Error initializing NotificationService: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    log('Notification tapped: ${response.payload}');
    // Có thể navigate đến appointment detail page nếu cần
  }

  // Request exact alarm permission for Android 12+
  static Future<void> _requestExactAlarmPermission() async {
    try {
      final androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // Check if exact alarms are allowed (Android 12+)
      final canScheduleExactAlarms =
          await androidImplementation?.areNotificationsEnabled() ?? false;

      if (!canScheduleExactAlarms) {
        log('Exact alarms permission may not be granted');
      }
    } catch (e) {
      log('Error checking exact alarm permission: $e');
    }
  }

  // Schedule notification for appointment
  static Future<void> scheduleAppointmentNotification(
    Appointment appointment,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Chỉ schedule nếu isReminder = true và appointment chưa qua
    if (!appointment.isReminder || appointment.isPast) {
      return;
    }

    if (appointment.id == null) {
      log('Cannot schedule notification: appointment.id is null');
      return;
    }

    try {
      // Tính thời gian notification (trước appointment X phút)
      final notificationTime = appointment.dateTime.subtract(
        Duration(minutes: appointment.reminderMinutes),
      );

      // Chỉ schedule nếu thời gian notification trong tương lai
      if (notificationTime.isBefore(DateTime.now())) {
        log('Notification time is in the past, skipping');
        return;
      }

      // Tạo notification ID từ appointment ID
      final notificationId = _getNotificationId(appointment.id!);

      // Tạo notification body
      String body =
          appointment.description.isNotEmpty
              ? appointment.description
              : 'Lịch hẹn của bạn sắp bắt đầu';

      if (appointment.location != null && appointment.location!.isNotEmpty) {
        body += '\nĐịa điểm: ${appointment.location}';
      }

      // Schedule notification với fallback nếu exact alarm không được phép
      try {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          appointment.title,
          body,
          tz.TZDateTime.from(notificationTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'appointment_channel',
              'Lịch hẹn',
              channelDescription: 'Thông báo về lịch hẹn và nhắc nhở',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'launch_background',
              color: Color(_getAppointmentTypeColor(appointment.type)),
              enableVibration: true,
              playSound: true,
              ongoing: false,
              autoCancel: true,
              channelShowBadge: true,
              fullScreenIntent: false,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: appointment.id, // Pass appointment ID as payload
          matchDateTimeComponents: DateTimeComponents.time,
        );

        log(
          'Scheduled notification for appointment: ${appointment.id} at $notificationTime',
        );
      } catch (e) {
        // Fallback: thử với inexact mode nếu exact không được phép
        if (e.toString().contains('exact') ||
            e.toString().contains('SCHEDULE_EXACT_ALARM')) {
          log('Exact alarm not permitted, using inexact mode as fallback');
          try {
            await _notificationsPlugin.zonedSchedule(
              notificationId,
              appointment.title,
              body,
              tz.TZDateTime.from(notificationTime, tz.local),
              NotificationDetails(
                android: AndroidNotificationDetails(
                  'appointment_channel',
                  'Lịch hẹn',
                  channelDescription: 'Thông báo về lịch hẹn và nhắc nhở',
                  importance: Importance.high,
                  priority: Priority.high,
                  icon: 'launch_background',
                  color: Color(_getAppointmentTypeColor(appointment.type)),
                  enableVibration: true,
                  playSound: true,
                  ongoing: false,
                  autoCancel: true,
                  channelShowBadge: true,
                ),
                iOS: const DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                  interruptionLevel: InterruptionLevel.timeSensitive,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: appointment.id,
              matchDateTimeComponents: DateTimeComponents.time,
            );
            log(
              'Scheduled notification (inexact mode) for appointment: ${appointment.id} at $notificationTime',
            );
          } catch (e2) {
            log('Error scheduling notification (fallback): $e2');
          }
        } else {
          rethrow;
        }
      }
    } catch (e) {
      log('Error scheduling notification: $e');
    }
  }

  // Cancel notification for appointment
  static Future<void> cancelAppointmentNotification(
    String appointmentId,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notificationId = _getNotificationId(appointmentId);
      await _notificationsPlugin.cancel(notificationId);
      log('Cancelled notification for appointment: $appointmentId');
    } catch (e) {
      log('Error cancelling notification: $e');
    }
  }

  // Cancel all appointment notifications
  static Future<void> cancelAllAppointmentNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _notificationsPlugin.cancelAll();
      log('Cancelled all notifications');
    } catch (e) {
      log('Error cancelling all notifications: $e');
    }
  }

  // Reschedule all upcoming appointments
  static Future<void> rescheduleAllAppointments() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Cancel all existing notifications
      await cancelAllAppointmentNotifications();

      // Get all appointments
      final appointments = await AppointmentService.getAppointments();

      // Schedule notifications for upcoming appointments
      for (final appointment in appointments) {
        if (!appointment.isPast && appointment.isReminder) {
          await scheduleAppointmentNotification(appointment);
        }
      }

      log('Rescheduled notifications for ${appointments.length} appointments');
    } catch (e) {
      log('Error rescheduling appointments: $e');
    }
  }

  // Get notification ID from appointment ID
  static int _getNotificationId(String appointmentId) {
    // Convert appointment ID to int (hash code)
    return appointmentId.hashCode.abs();
  }

  // Get color for appointment type
  static int _getAppointmentTypeColor(AppointmentType type) {
    switch (type) {
      case AppointmentType.KHAM_BENH:
        return 0xFFE53935; // Red
      case AppointmentType.NHAC_NHO:
        return 0xFF1976D2; // Blue
      case AppointmentType.KHAC:
        return 0xFF43A047; // Green
    }
  }

  // Show immediate notification (for testing)
  static Future<void> showTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    await _notificationsPlugin.show(
      999999,
      'Test Notification',
      'Đây là thông báo test',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_channel',
          'Lịch hẹn',
          channelDescription: 'Thông báo về lịch hẹn và nhắc nhở',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'launch_background',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
