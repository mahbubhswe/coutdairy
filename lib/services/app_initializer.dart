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

    // 4) App config
    const docId = String.fromEnvironment(
      'APP_CONFIG_ID',
      defaultValue: '7Wv3FSb5VOsWLtjzmpbl',
    );
    await AppConfigService.load(docId: docId);

    // 5) FCM token initialization and refresh listener
    await FcmService().initialize();

    // 6) Daily reminder to update hearing dates
    final localNoti = LocalNotificationService();
    await localNoti.initialize(
      onTap: (payload) {
        if (payload == 'overdue_cases') {
          Get.to(() => const OverdueCasesScreen());
        } else if (payload == 'tomorrow_cases') {
          Get.to(() => const TomorrowCasesScreen());
        }
      },
    );
    // Use inexact daily notifications to avoid exact-alarm permission prompts
    await localNoti.scheduleDailyNotification(
      id: 1,
      title: 'Update hearing dates',
      body: 'Tap to update past hearing dates',
      payload: 'overdue_cases',
    );

    // Exact-alarm prompt moved to MyApp builder (after UI mounts)

    // 7) Check for app updates in background
    await AppUpdateService.checkForAppUpdate();
  }
}
