import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/theme_controller.dart';
import '../../accounts/controllers/transaction_controller.dart';
import '../../case/controllers/case_controller.dart';
import 'accounts_card.dart';

class AccountsThirdCard extends StatelessWidget {
  const AccountsThirdCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final caseController = Get.find<CaseController>();
    final transactionController = Get.isRegistered<TransactionController>()
        ? Get.find<TransactionController>()
        : Get.put(TransactionController());

    double sumWhereMonth(String type) {
      final now = DateTime.now();
      return transactionController.transactions
          .where(
            (t) =>
                t.type == type &&
                t.createdAt.year == now.year &&
                t.createdAt.month == now.month,
          )
          .fold<double>(0, (p, e) => p + e.amount);
    }

    return Obx(() {
      final cases = caseController.cases;
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      final newCases = cases
          .where((c) => c.filedDate.toDate().isAfter(threeMonthsAgo))
          .length
          .toDouble();
      final totalCourts = cases
          .map((c) => c.courtName)
          .toSet()
          .length
          .toDouble();
      final depositThisMonth = sumWhereMonth('Deposit');
      final expenseThisMonth =
          sumWhereMonth('Expense') + sumWhereMonth('Withdrawal');

      return Material(
        color: themeController.isDarkMode
            ? Colors.black
            : const Color.fromARGB(255, 241, 238, 238),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              AccountsCard(title: 'নতুন কেস', amount: newCases),
              AccountsCard(title: 'মোট কোর্ট', amount: totalCourts),
              AccountsCard(title: 'এই মাসে জমা', amount: depositThisMonth),
              AccountsCard(title: 'এই মাসে খরচ', amount: expenseThisMonth),
            ],
          ),
        ),
      );
    });
  }
}
