import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:court_dairy/services/app_update_service.dart';
import 'package:court_dairy/services/fcm_service.dart';
import 'package:court_dairy/services/local_notification.dart';
import 'package:court_dairy/services/local_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:court_dairy/firebase_options.dart';
import '../modules/case/screens/overdue_cases_screen.dart';
import '../modules/case/screens/tomorrow_cases_screen.dart';
import '../utils/app_config.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // 1) Firebase core
    // Use FlutterFire options to avoid relying on Android resource values.xml
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2) Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 3) Local storage
    await LocalStorageService.init();

    // 4) App config (non-critical: do not block UI)
    const docId = String.fromEnvironment(
      'APP_CONFIG_ID',
      defaultValue: '7Wv3FSb5VOsWLtjzmpbl',
    );
    unawaited(
      AppConfigService
          .load(docId: docId)
          .timeout(const Duration(seconds: 3))
          .catchError((_) {}),
    );

    // 5) FCM token initialization and refresh listener (can hang offline)
    unawaited(
      FcmService()
          .initialize()
          .timeout(const Duration(seconds: 5))
          .catchError((_) {}),
    );

    // 6) Local notifications: ensure plugin is initialized BEFORE app runs
    // so any early scheduling by controllers succeeds.
    final localNoti = LocalNotificationService();
    try {
      await localNoti.initialize(
        onTap: (payload) {
          if (payload == 'overdue_cases') {
            Get.to(() => const OverdueCasesScreen());
          } else if (payload == 'tomorrow_cases') {
            Get.to(() => const TomorrowCasesScreen());
          }
        },
      );
    } catch (_) {}
    // Daily reminders via alarm-based scheduling
    unawaited(
      localNoti
          .scheduleDailyAtTime(
            id: 2,
            title: 'আগামীকালের কেস',
            body: 'আগামীকালের কেস দেখতে ট্যাপ করুন।',
            hour: 16,
            minute: 0,
            payload: 'tomorrow_cases',
          )
          .catchError((_) {}),
    );
    unawaited(
      localNoti
          .scheduleDailyAtTime(
            id: 310,
            title: 'অপারেটিং কেস আপডেট করুন',
            body: 'অপারেটিং কেস আপডেট করতে ট্যাপ করুন।',
            hour: 0,
            minute: 0,
            payload: 'overdue_cases',
          )
          .catchError((_) {}),
    );

    // Exact-alarm prompt moved to MyApp builder (after UI mounts)

    // 7) Check for app updates in background (non-blocking)
    unawaited(AppUpdateService.checkForAppUpdate().catchError((_) {}));
  }
}
