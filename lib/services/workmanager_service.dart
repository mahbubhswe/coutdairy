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

const String tomorrowCaseCheckTask = 'tomorrow_case_check_task';
const String overdueCaseCheckTask = 'overdue_case_check_task';

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
    final localNoti = LocalNotificationService();
    await localNoti.initialize();

    if (task == tomorrowCaseCheckTask) {
      final tomorrow = now.add(const Duration(days: 1));
      int count = 0;
      for (final c in cases) {
        final d = c.nextHearingDate?.toDate();
        if (d == null) continue;
        if (d.year == tomorrow.year &&
            d.month == tomorrow.month &&
            d.day == tomorrow.day) {
          count++;
        }
      }
      if (count > 0) {
        final title = 'আগামীকালের কেস';
        final body = 'আগামীকাল $count টি কেস আছে। বিস্তারিত দেখতে ট্যাপ করুন।';
        await localNoti.showNotification(title: title, body: body);
      }
    } else if (task == overdueCaseCheckTask) {
      int count = 0;
      for (final c in cases) {
        final d = c.nextHearingDate?.toDate();
        if (d == null) continue;
        if (d.isBefore(now)) {
          count++;
        }
      }
      if (count > 0) {
        final title = 'ওভারডিউ কেসের আপডেট';
        final body =
            'আপনার $count টি ওভারডিউ কেস আছে। বিস্তারিত দেখতে ট্যাপ করুন।';
        await localNoti.showNotification(title: title, body: body);
      }
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

    final now = DateTime.now();

    // Next 4 PM for tomorrow-case checks
    final nextFourPm = DateTime(now.year, now.month, now.day, 16);
    final tmwDelay = nextFourPm.isBefore(now)
        ? nextFourPm.add(const Duration(days: 1)).difference(now)
        : nextFourPm.difference(now);
    await Workmanager().registerPeriodicTask(
      tomorrowCaseCheckTask,
      tomorrowCaseCheckTask,
      frequency: const Duration(hours: 24),
      initialDelay: tmwDelay,
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );

    // Next 12 PM for overdue-case checks
    final nextNoon = DateTime(now.year, now.month, now.day, 12);
    final overdueDelay = nextNoon.isBefore(now)
        ? nextNoon.add(const Duration(days: 1)).difference(now)
        : nextNoon.difference(now);
    await Workmanager().registerPeriodicTask(
      overdueCaseCheckTask,
      overdueCaseCheckTask,
      frequency: const Duration(hours: 24),
      initialDelay: overdueDelay,
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}

