import 'package:court_dairy/models/lawyer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../case/controllers/case_controller.dart';
import '../../case/screens/overdue_cases_screen.dart';
import '../services/layout_service.dart';

class LayoutController extends GetxController {
  final layoutService = LayoutService();
  final ScrollController scrollController = ScrollController();
  final isDashboardVisible = true.obs;
  final caseController = Get.put(CaseController());

  final _isShowingOverdueSheet = false.obs;
  final _hasShownOverdueSheetOnce = false.obs;

  Rxn<Lawyer> lawyer = Rxn<Lawyer>(); // nullable observable  object

  @override
  void onInit() {
    scrollController.addListener(_onScroll);
    fetchLawyerInfo(); // fetch shop data on init
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _maybeShowOverdueSheet();
    once(caseController.cases, (_) => _maybeShowOverdueSheet());
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
      lawyer.value =data;
    });
  }

  Future<void> _maybeShowOverdueSheet() async {
    if (_isShowingOverdueSheet.value || _hasShownOverdueSheetOnce.value) return;

    if (caseController.isLoading.value) return;

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
                      Text('বকেয়া হিয়ারিং আপডেট',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        count == 1
                            ? '১টি কেসের তারিখ পার হয়ে গেছে, আপডেট করা প্রয়োজন।'
                            : '$count টি কেসের তারিখ পার হয়ে গেছে, আপডেট করা প্রয়োজন।',
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
                  Icon(
                    HugeIcons.strokeRoundedClock01,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'লিস্ট খুলে নেক্সট হিয়ারিং ডেট দেখে আপডেট করুন।',
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
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('পরে'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewAll,
                    icon: const Icon(HugeIcons.strokeRoundedArrowRight02),
                    label: const Text('সব কেস দেখুন'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
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
