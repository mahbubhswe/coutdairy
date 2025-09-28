import 'dart:async';
import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';

import '../services/local_notification.dart';

/// Prompts the user to allow Exact Alarms (Android 12+) if not granted.
/// Safe to call at startup. No-op on non-Android.
Future<void> askForExactAlarmPermissionIfNeeded() async {
  if (!Platform.isAndroid) return;

  final service = LocalNotificationService();
  await service.refreshAndroidExactAlarmCapability();
  if (service.canScheduleExactAlarms) {
    await service.scheduleGlobalDailyReminders();
    return;
  }

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

  // Give the system a moment after returning from settings before checking
  // the permission state again, then reschedule the reminders if allowed.
  await Future.delayed(const Duration(seconds: 1));
  await service.refreshAndroidExactAlarmCapability();
  if (service.canScheduleExactAlarms) {
    await service.scheduleGlobalDailyReminders();
  }
}
