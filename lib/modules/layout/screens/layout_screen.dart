import 'package:court_dairy/modules/accounts/screens/accounts_screen.dart';
import 'package:court_dairy/modules/case/screens/add_case_screen.dart';
import 'package:court_dairy/modules/case/screens/case_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../case/screens/case_screen.dart';
import '../../court_dairy/screens/customer_service_screen.dart';
import '../../../constants/app_texts.dart';
import '../../accounts/screens/add_transaction_screen.dart';
import '../../case/screens/case_fullscreen_screen.dart';
import '../../case/screens/case_calendar_screen.dart';
import '../../party/screens/add_party_screen.dart';
import '../../party/screens/party_screen.dart';
import '../widgets/app_drawer.dart';
import '../controllers/layout_controller.dart';
import '../widgets/dashboard.dart';
import '../../../utils/activation_guard.dart';

class LayoutScreen extends GetView<LayoutController> {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 40,
              titleSpacing: 0,
              title: const Text('Court Diary'),
              actions: [
                IconButton(
                  onPressed: () {
                    Get.to(() => CaseSearchScreen());
                  },
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: () {
                    Get.to(
                      () => const CaseFullscreenScreen(),
                      fullscreenDialog: true,
                    );
                  },
                  icon: const Icon(HugeIcons.strokeRoundedArrowAllDirection),
                  tooltip: 'ফুলস্ক্রিন কেস',
                ),
                IconButton(
                  onPressed: () {
                    Get.to(() => CaseCalendarScreen(), fullscreenDialog: true);
                  },
                  icon: const Icon(HugeIcons.strokeRoundedCalendar01),
                  tooltip: 'কেস ক্যালেন্ডার',
                ),
                IconButton(
                  onPressed: () {
                    Get.to(() => const CustomerServiceScreen());
                  },
                  icon: const Icon(HugeIcons.strokeRoundedCustomerService01),
                  tooltip: AppTexts.customerService,
                ),
              ],
            ),
            drawer: AppDrawer(),
            floatingActionButton: Obx(() {
              final visible = controller.isDashboardVisible.value;
              return AnimatedScale(
                scale: visible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (!ActivationGuard.check()) return;
                      final index = DefaultTabController.of(context).index;
                      if (index == 0) {
                        Get.to(
                          () => const AddCaseScreen(),
                          fullscreenDialog: true,
                        );
                      } else if (index == 1) {
                        Get.to(
                          () => const AddPartyScreen(),
                          fullscreenDialog: true,
                        );
                      } else {
                        Get.to(
                          () => const AddTransactionScreen(),
                          fullscreenDialog: true,
                        );
                      }
                    },
                    child: const Icon(Icons.add_circle),
                  ),
                ),
              );
            }),
            body: Column(
              children: [
                Obx(() {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: controller.isDashboardVisible.value
                        ? Dashboard()
                        : const SizedBox.shrink(),
                  );
                }),
                Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        dividerColor: Theme.of(context).colorScheme.outline,
                        enableFeedback: true,
                        tabs: const [
                          Tab(text: AppTexts.tabParty),
                          Tab(text: AppTexts.tabCase),
                          Tab(text: AppTexts.tabAccounts),
                        ],
                      ),
                      const Expanded(
                        child: TabBarView(
                          children: [
                            CaseScreen(),
                            PartyScreen(),
                            AccountsScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
