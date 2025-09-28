import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../accounts/controllers/transaction_controller.dart';
import '../../party/controllers/party_controller.dart';
import 'accounts_card.dart';

class AccountsSecondCard extends StatelessWidget {
  const AccountsSecondCard({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Obx(() {
      final totalParties = partyController.parties.length.toDouble();
      final totalDeposit = sumWhere('Deposit');
      final totalExpense = sumWhere('Expense') + sumWhere('Withdrawal');
      final balance = totalDeposit - totalExpense;

      return Column(
        spacing: 5,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: AccountsCard(
                  title: 'মোট পার্টি',
                  amount: totalParties,
                  icon: Icons.people_alt,
                ),
              ),
              Expanded(
                child: AccountsCard(
                  title: 'মোট জমা',
                  amount: totalDeposit,
                  icon: Icons.savings,
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: AccountsCard(
                  title: 'মোট খরচ',
                  amount: totalExpense,
                  icon: Icons.trending_down,
                ),
              ),
              Expanded(
                child: AccountsCard(
                  title: 'বর্তমান ব্যালেন্স',
                  amount: balance,
                  icon: Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
