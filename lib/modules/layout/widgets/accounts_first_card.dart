import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../case/controllers/case_controller.dart';
import 'accounts_card.dart';

class AccountsFirstCard extends StatelessWidget {
  const AccountsFirstCard({super.key});

  static const _gradients = [
    [Color(0xFF12324B), Color(0xFF0A192F)],
    [Color(0xFF1E1B4B), Color(0xFF312E81)],
    [Color(0xFF134E4A), Color(0xFF0F2A2C)],
    [Color(0xFF1E293B), Color(0xFF0F172A)],
    [Color(0xFF0F3F5B), Color(0xFF082032)],
    [Color(0xFF2D1B69), Color(0xFF1B103F)],
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final caseController = Get.find<CaseController>();

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
              final cases = caseController.cases;
              final running = cases
                  .where((c) => c.caseStatus.toLowerCase() == 'ongoing')
                  .length
                  .toDouble();
              final closed = cases
                  .where((c) => c.caseStatus.toLowerCase() == 'disposed')
                  .length
                  .toDouble();
              final complicated = cases
                  .where((c) => c.caseStatus.toLowerCase() == 'completed')
                  .length
                  .toDouble();
              final totalCases = cases.length.toDouble();
              final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
              final newCases = cases
                  .where((c) => c.filedDate.toDate().isAfter(threeMonthsAgo))
                  .length
                  .toDouble();
              final totalCourts =
                  cases.map((c) => c.courtName).toSet().length.toDouble();

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  AccountsCard(
                    title: 'চলমান কেস',
                    amount: running,
                    icon: Icons.gavel_rounded,
                    gradientColors: _gradients[0],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'বন্ধ কেস',
                    amount: closed,
                    icon: Icons.lock_outline,
                    gradientColors: _gradients[1],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'কমপ্লিট কেস',
                    amount: complicated,
                    icon: Icons.verified,
                    gradientColors: _gradients[2],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'মোট কেস',
                    amount: totalCases,
                    icon: Icons.all_inbox,
                    gradientColors: _gradients[3],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'নতুন কেস',
                    amount: newCases,
                    icon: Icons.fiber_new,
                    gradientColors: _gradients[4],
                    width: cardWidth,
                  ),
                  AccountsCard(
                    title: 'মোট কোর্ট',
                    amount: totalCourts,
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
