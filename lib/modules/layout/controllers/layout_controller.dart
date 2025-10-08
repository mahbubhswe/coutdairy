import 'dart:async';

import 'package:court_dairy/models/lawyer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../auth/controllers/local_auth_controller.dart';
import '../../case/controllers/case_controller.dart';
import '../../case/screens/overdue_cases_screen.dart';
import '../services/layout_service.dart';

class LayoutController extends GetxController {
  final layoutService = LayoutService();
  final ScrollController scrollController = ScrollController();
  final isDashboardVisible = true.obs;
  final RxInt currentIndex = 0.obs;
  final caseController = Get.put(CaseController());
  final localAuthController = Get.find<LocalAuthController>();

  final _isShowingOverdueSheet = false.obs;
  final _hasShownOverdueSheetOnce = false.obs;
  bool _overdueDelayElapsed = false; // show only after delay
  Timer? _overdueDelayTimer;

  Rxn<Lawyer> lawyer = Rxn<Lawyer>(); // nullable observable  object

  @override
  void onInit() {
    scrollController.addListener(_onScroll);
    fetchLawyerInfo(); // fetch shop data on init
    // React to cases stream updates; avoid race where first emission
    // happens before onReady registers `once`.
    ever(caseController.cases, (_) => _maybeShowOverdueSheet());
    ever<bool>(caseController.isLoading, (loading) {
      if (loading == false) _maybeShowOverdueSheet();
    });
    ever<bool>(localAuthController.isAuthenticated, (isAuthenticated) {
      if (isAuthenticated) _maybeShowOverdueSheet();
    });
    // Start a 5s delay window before we are allowed to show the sheet
    _overdueDelayTimer?.cancel();
    _overdueDelayTimer = Timer(const Duration(seconds: 5), () {
      _overdueDelayElapsed = true;
      _maybeShowOverdueSheet();
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _maybeShowOverdueSheet();
  }

  void _onScroll() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (isDashboardVisible.value) isDashboardVisible.value = false;
    } else if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!isDashboardVisible.value) isDashboardVisible.value = true;
    }
  }

  void fetchLawyerInfo() {
    layoutService.getLawyerInfo().listen((data) {
      lawyer.value = data;
    });
  }

  void onDestinationSelected(int index) {
    if (currentIndex.value == index) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
      return;
    }
    currentIndex.value = index;
    if (!isDashboardVisible.value) {
      isDashboardVisible.value = true;
    }
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _maybeShowOverdueSheet() async {
    if (!_overdueDelayElapsed) return; // wait until 5s after app open
    if (_isShowingOverdueSheet.value || _hasShownOverdueSheetOnce.value) return;

    if (caseController.isLoading.value) return;
    if (!localAuthController.isAuthenticated.value) return;

    final overdue = caseController.overdueCases;
    if (overdue.isEmpty) return;

    _hasShownOverdueSheetOnce.value = true;
    _isShowingOverdueSheet.value = true;
    await Get.bottomSheet(
      _OverdueSheetContent(
        count: overdue.length,
        onViewAll: () {
          Get.back();
          Get.to(() => const OverdueCasesScreen());
        },
      ),
      isScrollControlled: false,
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
    _isShowingOverdueSheet.value = false;
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _overdueDelayTimer?.cancel();
    super.onClose();
  }
}

class _OverdueSheetContent extends StatelessWidget {
  const _OverdueSheetContent({required this.count, required this.onViewAll});

  final int count;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ButtonStyle actionButtonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade600),
                  ),
                  child: const Icon(
                    HugeIcons.strokeRoundedCalendar01,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overdue hearing update',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count == 1
                            ? '1 case is overdue and needs to be updated.'
                            : '$count cases are overdue and need to be updated.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(HugeIcons.strokeRoundedClock01, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Open the list to review and update the next hearing date.',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: actionButtonStyle.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        colorScheme.surface,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        colorScheme.primary,
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                      side: MaterialStateProperty.all(
                        BorderSide(color: colorScheme.primary),
                      ),
                    ),
                    child: const Text('Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewAll,
                    icon: const Icon(HugeIcons.strokeRoundedArrowRight02),
                    label: const Text('View cases'),
                    style: actionButtonStyle.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.green.shade600,
                      ),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
