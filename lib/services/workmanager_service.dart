import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/app_collections.dart';
import '../firebase_options.dart';
import '../models/court_case.dart';
import 'local_notification.dart';

const String caseCheckTask = 'case_check_task';

@pragma('vm:entry-point')
void workManagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Future.value(true);
    }

    final snap = await FirebaseFirestore.instance
        .collection(AppCollections.lawyers)
        .doc(user.uid)
        .collection(AppCollections.cases)
        .get();

    final cases = snap.docs
        .map((doc) => CourtCase.fromMap(doc.data(), docId: doc.id))
        .toList();

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    int tmwCount = 0;
    int overdueCount = 0;

    for (final c in cases) {
      final d = c.nextHearingDate?.toDate();
      if (d == null) continue;
      if (d.year == tomorrow.year &&
          d.month == tomorrow.month &&
          d.day == tomorrow.day) {
        tmwCount++;
      }
      if (d.isBefore(now)) {
        overdueCount++;
      }
    }

    final localNoti = LocalNotificationService();
    await localNoti.initialize();

    if (tmwCount > 0) {
      final title = 'আগামীকালের কেস';
      final body = 'আগামীকাল $tmwCount টি কেস আছে। বিস্তারিত দেখতে ট্যাপ করুন।';
      await localNoti.scheduleDailyAtTime(
        id: 2,
        title: title,
        body: body,
        hour: 16,
        minute: 0,
        payload: 'tomorrow_cases',
      );
    } else {
      await localNoti.cancel(2);
    }

    if (overdueCount > 0) {
      final title = 'ওভারডিউ কেসের আপডেট';
      final body =
          'আপনার $overdueCount টি ওভারডিউ কেস আছে। বিস্তারিত দেখতে ট্যাপ করুন।';
      await localNoti.scheduleDailyAtTime(
        id: 310,
        title: title,
        body: body,
        hour: 23,
        minute: 0,
        payload: 'overdue_cases',
      );
    } else {
      await localNoti.cancel(310);
    }

    return Future.value(true);
  });
}

class WorkManagerService {
  static Future<void> init() async {
    await Workmanager().initialize(
      workManagerCallbackDispatcher,
      isInDebugMode: false,
    );
    await Workmanager().registerPeriodicTask(
      caseCheckTask,
      caseCheckTask,
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}

