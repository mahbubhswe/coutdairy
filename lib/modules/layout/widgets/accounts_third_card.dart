import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../accounts/controllers/transaction_controller.dart';
import '../../case/controllers/case_controller.dart';
import 'accounts_card.dart';

class AccountsThirdCard extends StatelessWidget {
  const AccountsThirdCard({super.key});

  @override
  Widget build(BuildContext context) {
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

      return Column(
        spacing: 5,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: AccountsCard(
                  title: 'নতুন কেস',
                  amount: newCases,
                  icon: Icons.new_releases,
                ),
              ),
              Expanded(
                child: AccountsCard(
                  title: 'মোট কোর্ট',
                  amount: totalCourts,
                  icon: Icons.account_balance,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: AccountsCard(
                  title: 'এই মাসে জমা',
                  amount: depositThisMonth,
                  icon: Icons.attach_money,
                ),
              ),
              Expanded(
                child: AccountsCard(
                  title: 'এই মাসে খরচ',
                  amount: expenseThisMonth,
                  icon: Icons.money_off,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
