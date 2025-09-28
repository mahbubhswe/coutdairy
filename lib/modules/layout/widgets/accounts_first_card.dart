import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../case/controllers/case_controller.dart';
import 'accounts_card.dart';

class AccountsFirstCard extends StatelessWidget {
  const AccountsFirstCard({super.key});

  @override
  Widget build(BuildContext context) {
    final caseController = Get.find<CaseController>();

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

      return DashboardMetricsGrid(
        metrics: [
          DashboardMetric(
            title: 'চলমান কেস',
            amount: running,
            icon: Icons.play_circle_fill,
          ),
          DashboardMetric(
            title: 'বন্ধ কেস',
            amount: closed,
            icon: Icons.lock_outline,
          ),
          DashboardMetric(
            title: 'কমপ্লিট কেস',
            amount: complicated,
            icon: Icons.task_alt,
          ),
          DashboardMetric(
            title: 'মোট কেস',
            amount: totalCases,
            icon: Icons.library_books,
          ),
        ],
      );
    });
  }
}
