import 'package:court_dairy/modules/accounts/screens/accounts_screen.dart';
import 'package:court_dairy/modules/case/screens/add_case_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../case/screens/case_screen.dart';
import '../../court_dairy/screens/customer_service_screen.dart';
import '../../../constants/app_texts.dart';
import '../../accounts/screens/add_transaction_screen.dart';
import '../../case/screens/case_calendar_screen.dart';
import '../../party/screens/add_party_screen.dart';
import '../../party/screens/party_screen.dart';
import '../controllers/layout_controller.dart';
import '../../../utils/activation_guard.dart';
import '../../settings/screens/settings_screen.dart';

class LayoutScreen extends GetView<LayoutController> {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Obx(() {
      final index = controller.currentIndex.value;
      final showFab = controller.isDashboardVisible.value && index != 3;

      return Scaffold(
        appBar: AppBar(
          leadingWidth: 40,
          titleSpacing: 12,
          elevation: 0,
          title: const Text('Court Diary'),
          actions: [
          IconButton(
            onPressed: () {
              Get.to(() => CaseCalendarScreen(), fullscreenDialog: true);
            },
            icon: const Icon(HugeIcons.strokeRoundedCalendar01),
            tooltip: 'Case calendar',
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
        floatingActionButton: AnimatedScale(
          scale: showFab ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: showFab ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: showFab
                ? FloatingActionButton(
                    onPressed: () {
                      if (!ActivationGuard.check()) return;
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
                      } else if (index == 2) {
                        Get.to(
                          () => const AddTransactionScreen(),
                          fullscreenDialog: true,
                        );
                      }
                    },
                    child: const Icon(Icons.add_circle),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        body: IndexedStack(
          index: index,
          children: [
            const CaseScreen(),
            const PartyScreen(),
            const AccountsScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => (textTheme.labelMedium ?? const TextStyle())
                  .copyWith(
                    fontWeight: FontWeight.w700,
                    color: states.contains(WidgetState.selected)
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          child: NavigationBar(
            surfaceTintColor: Colors.transparent,
            selectedIndex: index,
            onDestinationSelected: controller.onDestinationSelected,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.forum_outlined),
                selectedIcon: Icon(Icons.forum),
                label: AppTexts.tabParty,
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: AppTexts.tabCase,
              ),
              NavigationDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: AppTexts.tabAccounts,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      );
    });
  }
}
