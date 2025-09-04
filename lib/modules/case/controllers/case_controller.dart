import 'package:get/get.dart';

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
    final tomorrow = tomorrowCases;
    final title = "Tomorrow's Cases";
    final body = tomorrow.isEmpty
        ? 'No cases scheduled for tomorrow'
        : tomorrow.map((c) => c.caseTitle).join(', ');
    await _localNoti.scheduleDailyAtTime(
      id: 2,
      title: title,
      body: body,
      hour: 16,
      minute: 0,
      payload: 'tomorrow_cases',
    );
  }
}
