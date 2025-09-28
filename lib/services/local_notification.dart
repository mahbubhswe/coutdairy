import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._internal();
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool isInit = false;
  bool get isInited => isInit;
  bool? _canScheduleExactAlarms;
  bool get canScheduleExactAlarms => _canScheduleExactAlarms ?? false;

  Future<void> initialize({Function(String?)? onTap}) async {
    if (isInit) return;
    tz.initializeTimeZones();
    // Force Asia/Dhaka time for scheduled notifications irrespective of device TZ
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    } catch (_) {
      // If timezone DB missing Dhaka for some reason, fallback to device local
    }
    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosInitializationSettings = DarwinInitializationSettings();

    const initSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await notificationsPlugin.initialize(
      initSetting,
      onDidReceiveNotificationResponse: (details) {
        onTap?.call(details.payload);
      },
    );

    // Android 13+ needs runtime notification permission
    // Android 12+ may require special exact alarm permission
    if (Platform.isAndroid) {
      final androidPlugin = notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Request POST_NOTIFICATIONS (Android 13+)
      await androidPlugin?.requestNotificationsPermission();

      // Do NOT proactively request exact alarm permission; many devices show a
      // disabled toggle causing a confusing loop. We'll fallback to inexact.
      // We'll still query capability to help decide behavior at schedule time.
      await _refreshExactAlarmCapability(androidPlugin);
    }
    // iOS permissions
    if (Platform.isIOS) {
      final iosPlugin = notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    isInit = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'seba_pos_local_notification_channel',
        'Local Notification',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int id = timestamp % 2147483647;
    notificationsPlugin.show(id, title, body, notificationDetails());
  }

  Future<void> cancel(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Use time-based daily schedule for better reliability across platforms.
    // Default: 20:00 local time.
    await scheduleDailyAtTime(
      id: id,
      title: title,
      body: body,
      hour: 20,
      minute: 0,
      payload: payload,
    );
  }

  Future<void> scheduleDailyAtTime({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await notificationsPlugin.cancel(id);
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final scheduleMode = await _resolveAndroidScheduleMode();
    try {
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails(),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
    } on PlatformException catch (_) {
      if (scheduleMode == AndroidScheduleMode.exactAllowWhileIdle) {
        // Retry immediately with an inexact schedule if exact scheduling is
        // not permitted (e.g. the user denied exact alarm permission).
        await notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );
        _canScheduleExactAlarms = false;
      } else {
        rethrow;
      }
    }
  }

  Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    final canExact = await _ensureExactCapability();
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<bool> _ensureExactCapability() async {
    if (!Platform.isAndroid) return true;
    if (_canScheduleExactAlarms != null) {
      return _canScheduleExactAlarms!;
    }
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await _refreshExactAlarmCapability(androidPlugin);
    return _canScheduleExactAlarms ?? false;
  }

  Future<void> _refreshExactAlarmCapability(
    AndroidFlutterLocalNotificationsPlugin? androidPlugin,
  ) async {
    if (!Platform.isAndroid) {
      _canScheduleExactAlarms = true;
      return;
    }
    try {
      final result = await androidPlugin?.canScheduleExactNotifications();
      _canScheduleExactAlarms = result ?? false;
    } catch (_) {
      _canScheduleExactAlarms = false;
    }
  }

  Future<void> refreshAndroidExactAlarmCapability() async {
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await _refreshExactAlarmCapability(androidPlugin);
  }

  Future<void> scheduleGlobalDailyReminders() async {
    await scheduleDailyAtTime(
      id: 2,
      title: 'আগামীকালের কেস',
      body: 'আগামীকালের কেস দেখতে ট্যাপ করুন।',
      hour: 16,
      minute: 0,
      payload: 'tomorrow_cases',
    );

    await scheduleDailyAtTime(
      id: 310,
      title: 'অপারেটিং কেস আপডেট করুন',
      body: 'অপারেটিং কেস আপডেট করতে ট্যাপ করুন।',
      hour: 0,
      minute: 0,
      payload: 'overdue_cases',
    );
  }
}
