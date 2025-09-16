import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../accounts/controllers/transaction_controller.dart';
import '../../party/controllers/party_controller.dart';
import 'accounts_card.dart';

class AccountsSecondCard extends StatelessWidget {
  const AccountsSecondCard({super.key});

  static const _gradients = [
    [Color(0xFF103B5C), Color(0xFF061A2E)],
    [Color(0xFF14532D), Color(0xFF0B2A1A)],
    [Color(0xFF5B21B6), Color(0xFF312E81)],
    [Color(0xFF0F3460), Color(0xFF0B1A33)],
    [Color(0xFF047857), Color(0xFF065F46)],
    [Color(0xFF1F2937), Color(0xFF111827)],
  ];

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
          .where(
            (t) =>
                t.type == type &&
                t.createdAt.year == now.year &&
                t.createdAt.month == now.month,
          )
          .fold<double>(0, (p, e) => p + e.amount);
    }

    return Material(
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 16.0;
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 900
                ? 3
                : width >= 520
                    ? 2
                    : 1;
            final availableWidth =
                width - spacing * (crossAxisCount - 1);
            final cardWidth = availableWidth / crossAxisCount;

            return Obx(() {
              final totalParties = partyController.parties.length.toDouble();
              final depositThisMonth = sumWhereMonth('Deposit');
              final expenseThisMonth =
                  sumWhereMonth('Expense') + sumWhereMonth('Withdrawal');
              final totalDeposit = sumWhere('Deposit');
              final totalExpense = sumWhere('Expense') + sumWhere('Withdrawal');
              final balance = totalDeposit - totalExpense;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  AccountsCard(
                    title: 'মোট পার্টি',
                    amount: totalParties,
                    icon: Icons.groups_rounded,
                    gradientColors: _gradients[0],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'এই মাসে জমা',
                    amount: depositThisMonth,
                    icon: Icons.savings_rounded,
                    gradientColors: _gradients[1],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'এই মাসে খরচ',
                    amount: expenseThisMonth,
                    icon: Icons.trending_down,
                    gradientColors: _gradients[2],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'মোট জমা',
                    amount: totalDeposit,
                    icon: Icons.account_balance_wallet_rounded,
                    gradientColors: _gradients[3],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'মোট খরচ',
                    amount: totalExpense,
                    icon: Icons.receipt_long,
                    gradientColors: _gradients[4],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'বর্তমান ব্যালেন্স',
                    amount: balance,
                    icon: Icons.account_balance,
                    gradientColors: _gradients[5],
                    width: cardWidth,
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }
}
