import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:logging/logging.dart';

import '../constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final _logger = Logger('NotificationService');
  final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await _createNotificationChannels();
      
      _logger.info('NotificationService initialized');
    } catch (e) {
      _logger.severe('Failed to initialize NotificationService: $e');
    }
  }

  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // Handle iOS foreground notifications
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      // Navigate to appropriate screen based on payload
      // This would typically be handled by a router or navigation service
    }
  }

  Future<void> _createNotificationChannels() async {
    // Medication reminders channel
    const medicationChannel = AndroidNotificationChannel(
      AppConstants.medicationReminderChannel,
      'Medication Reminders',
      description: 'Notifications for medication reminders',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('medication_reminder'),
    );

    // Blood pressure measurement channel
    const bpChannel = AndroidNotificationChannel(
      AppConstants.bpMeasurementChannel,
      'Blood Pressure Reminders',
      description: 'Notifications for blood pressure measurements',
      importance: Importance.defaultImportance,
    );

    // Urgent alerts channel
    const urgentChannel = AndroidNotificationChannel(
      AppConstants.urgentAlertChannel,
      'Urgent Health Alerts',
      description: 'Critical health alerts requiring immediate attention',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(medicationChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(bpChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(urgentChannel);
  }

  // Schedule medication reminder
  Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required DateTime scheduledTime,
    required String dosage,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.medicationReminderChannel,
        'Medication Reminders',
        channelDescription: 'Notifications for medication reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@drawable/medication_icon'),
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'medication_reminder',
        threadIdentifier: 'medication_reminders',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        'Time for your medication',
        'Take $dosage of $medicationName',
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        payload: 'medication_reminder:$id',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      _logger.info('Scheduled medication reminder for $medicationName at $scheduledTime');
    } catch (e) {
      _logger.severe('Failed to schedule medication reminder: $e');
    }
  }

  // Schedule blood pressure measurement reminder
  Future<void> scheduleBloodPressureReminder({
    required int id,
    required DateTime scheduledTime,
    String? customMessage,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.bpMeasurementChannel,
        'Blood Pressure Reminders',
        channelDescription: 'Notifications for blood pressure measurements',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@drawable/bp_icon'),
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'bp_reminder',
        threadIdentifier: 'bp_reminders',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final message = customMessage ?? 'Time to measure your blood pressure';

      await _notifications.zonedSchedule(
        id,
        'Blood Pressure Check',
        message,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        payload: 'bp_reminder:$id',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      _logger.info('Scheduled BP reminder at $scheduledTime');
    } catch (e) {
      _logger.severe('Failed to schedule BP reminder: $e');
    }
  }

  // Show urgent health alert
  Future<void> showUrgentAlert({
    required int id,
    required String title,
    required String message,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.urgentAlertChannel,
        'Urgent Health Alerts',
        channelDescription: 'Critical health alerts requiring immediate attention',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@drawable/alert_icon'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'urgent_alert',
        threadIdentifier: 'urgent_alerts',
        interruptionLevel: InterruptionLevel.critical,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id,
        title,
        message,
        details,
        payload: payload ?? 'urgent_alert:$id',
      );

      _logger.warning('Urgent alert shown: $title');
    } catch (e) {
      _logger.severe('Failed to show urgent alert: $e');
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      _logger.info('Cancelled notification: $id');
    } catch (e) {
      _logger.severe('Failed to cancel notification $id: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.info('Cancelled all notifications');
    } catch (e) {
      _logger.severe('Failed to cancel all notifications: $e');
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      _logger.severe('Failed to get pending notifications: $e');
      return [];
    }
  }

  // Request permissions (mainly for iOS)
  Future<bool> requestPermissions() async {
    try {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return result ?? true; // Android doesn't need explicit permission request
    } catch (e) {
      _logger.severe('Failed to request permissions: $e');
      return false;
    }
  }

  // Schedule recurring medication reminders
  Future<void> scheduleMedicationSchedule({
    required String medicationId,
    required String medicationName,
    required String dosage,
    required List<DateTime> scheduleTimes,
  }) async {
    try {
      for (int i = 0; i < scheduleTimes.length; i++) {
        final notificationId = medicationId.hashCode + i;
        await scheduleMedicationReminder(
          id: notificationId,
          medicationName: medicationName,
          scheduledTime: scheduleTimes[i],
          dosage: dosage,
        );
      }
    } catch (e) {
      _logger.severe('Failed to schedule medication schedule: $e');
    }
  }

  // Cancel medication schedule
  Future<void> cancelMedicationSchedule(String medicationId) async {
    try {
      final pending = await getPendingNotifications();
      final medicationNotifications = pending
          .where((notification) => notification.payload?.contains(medicationId) == true)
          .toList();

      for (final notification in medicationNotifications) {
        await cancelNotification(notification.id);
      }

      _logger.info('Cancelled medication schedule for $medicationId');
    } catch (e) {
      _logger.severe('Failed to cancel medication schedule: $e');
    }
  }
}