import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../accounts/controllers/transaction_controller.dart';
import '../../party/controllers/party_controller.dart';
import 'accounts_card.dart';

class AccountsSecondCard extends StatelessWidget {
  AccountsSecondCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final partyController = Get.isRegistered<PartyController>()
        ? Get.find<PartyController>()
        : Get.put(PartyController());
    final transactionController = Get.isRegistered<TransactionController>()
        ? Get.find<TransactionController>()
        : Get.put(TransactionController());

    double sumWhere(String type) {
      return transactionController.transactions
          .where((t) => t.type == type)
          .fold<double>(0, (p, e) => p + e.amount);
    }

    double sumWhereMonth(String type) {
      final now = DateTime.now();
      return transactionController.transactions
          .where((t) =>
              t.type == type &&
              t.createdAt.year == now.year &&
              t.createdAt.month == now.month)
          .fold<double>(0, (p, e) => p + e.amount);
    }

    return Obx(() {
      final totalParties = partyController.parties.length.toDouble();
      final depositThisMonth = sumWhereMonth('Deposit');
      final expenseThisMonth =
          sumWhereMonth('Expense') + sumWhereMonth('Withdrawal');
      final totalDeposit = sumWhere('Deposit');
      final totalExpense = sumWhere('Expense') + sumWhere('Withdrawal');
      final balance = totalDeposit - totalExpense;

      return Material(
        color: cs.surface,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            spacing: 5,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AccountsCard(title: 'মোট পার্টি', amount: totalParties),
                  AccountsCard(title: 'এই মাসে জমা', amount: depositThisMonth),
                  AccountsCard(title: 'এই মাসে খরচ', amount: expenseThisMonth),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AccountsCard(title: 'মোট জমা', amount: totalDeposit),
                  AccountsCard(title: 'মোট খরচ', amount: totalExpense),
                  AccountsCard(title: 'বর্তমান ব্যালেন্স', amount: balance),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
