import 'dart:async';

import 'package:get/get.dart';
// Removed HomeWidget integration

import '../../../models/court_case.dart';
import '../../../services/app_firebase.dart';
import '../../../services/local_notification.dart';
import '../services/case_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaseController extends GetxController {
  final cases = <CourtCase>[].obs;
  final isLoading = true.obs;
  final selectedFilter = 'today'.obs;
  final _localNoti = LocalNotificationService();
  // Debug/testing: enable 3-minute notifications loop
  static const bool _enable3MinTestNoti = false; // disabled for real use
  Timer? _testNotiTimer;

  DateTime? _nextDate(CourtCase c) {
    return c.nextHearingDate?.toDate();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<CourtCase> get todayCases {
    final now = DateTime.now();
    return cases.where((c) {
      final d = _nextDate(c);
      if (d == null) return false;
      return _isSameDay(d, now);
    }).toList();
  }

  List<CourtCase> get tomorrowCases {
    final now = DateTime.now().add(const Duration(days: 1));
    return cases.where((c) {
      final d = _nextDate(c);
      if (d == null) return false;
      return _isSameDay(d, now);
    }).toList();
  }

  List<CourtCase> get weekCases {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return cases.where((c) {
      final d = _nextDate(c);
      if (d == null) return false;
      return !d.isBefore(startOfWeek) && !d.isAfter(endOfWeek);
    }).toList();
  }

  List<CourtCase> get monthCases {
    final now = DateTime.now();
    return cases.where((c) {
      final d = _nextDate(c);
      if (d == null) return false;
      return d.year == now.year && d.month == now.month;
    }).toList();
  }

  Map<int, int> get monthCaseCounts {
    final now = DateTime.now();
    final map = <int, int>{};
    for (final c in cases) {
      final d = _nextDate(c);
      if (d == null) continue;
      if (d.year == now.year && d.month == now.month) {
        map[d.day] = (map[d.day] ?? 0) + 1;
      }
    }
    return map;
  }

  List<CourtCase> get overdueCases {
    final now = DateTime.now();
    return cases.where((c) {
      final d = _nextDate(c);
      if (d == null) return false;
      return d.isBefore(now);
    }).toList();
  }

  List<CourtCase> get filteredCases {
    switch (selectedFilter.value) {
      case 'tomorrow':
        return tomorrowCases;
      case 'week':
        return weekCases;
      case 'month':
        return monthCases;
      default:
        return todayCases;
    }
  }

  int get todayCount => todayCases.length;
  int get tomorrowCount => tomorrowCases.length;
  int get weekCount => weekCases.length;
  int get monthCount => monthCases.length;

  @override
  void onInit() {
    super.onInit();
    final user = AppFirebase().currentUser;
    if (user != null) {
      CaseService.getCases(user.uid).listen((event) {
        cases.value = event;
        isLoading.value = false;
        _scheduleTomorrowNotification();
        _scheduleOverdueNotification();
        if (_enable3MinTestNoti) _start3MinTestNotifications();
      });
    } else {
      isLoading.value = false;
    }
  }

  Future<void> deleteCase(String docId) async {
    final user = AppFirebase().currentUser;
    if (user == null) return;
    await CaseService.deleteCase(docId, user.uid);
  }

  Future<void> updateNextHearingDate(CourtCase c, DateTime date) async {
    final user = AppFirebase().currentUser;
    if (user == null || c.docId == null) return;
    final ts = Timestamp.fromDate(date);
    await CaseService.updateNextHearingDate(c.docId!, user.uid, ts);
    final idx = cases.indexWhere((e) => e.docId == c.docId);
    if (idx != -1) {
      final prevNext = cases[idx].nextHearingDate;
      if (prevNext != null) {
        cases[idx].lastHearingDate = prevNext;
      }
      cases[idx].nextHearingDate = ts;
      cases.refresh();
    }
  }

  Future<void> _scheduleTomorrowNotification() async {
    // Daily at 4 PM BD time — only if there are tomorrow cases
    final count = tomorrowCases.length;
    if (count > 0) {
      final title = 'আগামীকালের কেস';
      final body = 'আগামীকাল $count টি কেস আছে। বিস্তারিত দেখতে ট্যাপ করুন।';
      await _localNoti.scheduleDailyAtTime(
        id: 2,
        title: title,
        body: body,
        hour: 16,
        minute: 0,
        payload: 'tomorrow_cases',
      );
    } else {
      await _localNoti.cancel(2);
    }
  }

  Future<void> _scheduleOverdueNotification() async {
    // Clean up legacy every-3-hours notifications (from older builds)
    const oldHours = [0, 3, 6, 9, 12, 15, 18, 21];
    for (final h in oldHours) {
      await _localNoti.cancel(300 + h);
    }

    // Daily at 12 PM BD time — only if there are overdue cases
    final count = overdueCases.length;
    if (count > 0) {
      final title = 'ওভারডিউ কেসের আপডেট';
      final body = 'আপনার $count টি ওভারডিউ কেস আছে। বিস্তারিত দেখতে ট্যাপ করুন।';
      await _localNoti.scheduleDailyAtTime(
        id: 310,
        title: title,
        body: body,
        hour: 0,
        minute: 0,
        payload: 'overdue_cases',
      );
    } else {
      await _localNoti.cancel(310);
    }
  }

  // DEBUG ONLY: Send notifications every 3 minutes based on current case lists.
  void _start3MinTestNotifications() {
    _testNotiTimer?.cancel();
    // Kick once shortly after startup for quick verification
    Future.delayed(const Duration(seconds: 10), _send3MinTestNotifications);
    _testNotiTimer =
        Timer.periodic(const Duration(minutes: 3), (_) => _send3MinTestNotifications());
  }

  Future<void> _send3MinTestNotifications() async {
    // Overdue notification if any
    final overdueCount = overdueCases.length;
    if (overdueCount > 0) {
      final title = 'ওভারডিউ কেসের আপডেট (TEST)';
      final body = 'আপনার $overdueCount টি ওভারডিউ কেস আছে। বিস্তারিত দেখতে ট্যাপ করুন।';
      await _localNoti.showNotification(title: title, body: body);
    }

    // Tomorrow notification if any
    final tmwCount = tomorrowCases.length;
    if (tmwCount > 0) {
      final title = 'আগামীকালের কেস (TEST)';
      final body = 'আগামীকাল $tmwCount টি কেস আছে। বিস্তারিত দেখতে ট্যাপ করুন।';
      await _localNoti.showNotification(title: title, body: body);
    }
  }

  @override
  void onClose() {
    _testNotiTimer?.cancel();
    super.onClose();
  }
}
