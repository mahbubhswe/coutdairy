import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:court_dairy/services/app_update_service.dart';
import 'package:court_dairy/services/fcm_service.dart';
import 'package:court_dairy/services/local_notification.dart';
import 'package:court_dairy/services/local_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../modules/case/screens/overdue_cases_screen.dart';
import '../modules/case/screens/tomorrow_cases_screen.dart';
import '../utils/app_config.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // 1) Firebase core
    await Firebase.initializeApp();

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
      defaultValue: 'XCUdkvlttJT2Mw2OEsl3',
    );
    await AppConfigService.load(docId: docId);

    // 5) FCM token initialization and refresh listener
    await FcmService().initialize();

    // 6) Daily reminder to update hearing dates
    final localNoti = LocalNotificationService();
    await localNoti.initialize(onTap: (payload) {
      if (payload == 'overdue_cases') {
        Get.to(() => const OverdueCasesScreen());
      } else if (payload == 'tomorrow_cases') {
        Get.to(() => const TomorrowCasesScreen());
      }
    });
    await localNoti.scheduleDailyAtTime(
      id: 1,
      title: 'Update hearing dates',
      body: 'Tap to update past hearing dates',
      hour: 23,
      minute: 0,
      payload: 'overdue_cases',
    );

    // 7) Check for app updates in background
    await AppUpdateService.checkForAppUpdate();
  }
}
