import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../services/local_notification.dart';

/// Prompts the user to allow Exact Alarms (Android 12+) if not granted.
/// Safe to call at startup. No-op on non-Android.
Future<void> askForExactAlarmPermissionIfNeeded() async {
  if (!Platform.isAndroid) return;

  final androidPlugin = LocalNotificationService()
      .notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  bool canExact = false;
  try {
    canExact = (await (androidPlugin?.canScheduleExactNotifications() ??
        Future.value(false)))!;
  } catch (_) {
    canExact = false;
  }

  if (canExact) return;

  // Directly open the native settings screen without an in-app dialog
  const packageName = 'com.appseba.courtdiary';
  final intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    data: 'package:$packageName',
  );
  try {
    await intent.launch();
  } catch (_) {
    // Fallback: open app details settings
    final fallback = AndroidIntent(
      action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
      data: 'package:$packageName',
    );
    await fallback.launch();
  }
}
