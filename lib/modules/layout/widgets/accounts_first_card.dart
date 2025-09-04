import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../case/controllers/case_controller.dart';
import 'accounts_card.dart';

class AccountsFirstCard extends StatelessWidget {
  const AccountsFirstCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final caseController = Get.find<CaseController>();

    return Obx(() {
      final cases = caseController.cases;
      final running =
          cases.where((c) => c.caseStatus.toLowerCase() == 'ongoing').length.toDouble();
      final closed =
          cases.where((c) => c.caseStatus.toLowerCase() == 'disposed').length.toDouble();
      final complicated =
          cases.where((c) => c.caseStatus.toLowerCase() == 'completed').length.toDouble();
      final totalCases = cases.length.toDouble();
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      final newCases = cases
          .where((c) => c.filedDate.toDate().isAfter(threeMonthsAgo))
          .length
          .toDouble();
      final totalCourts =
          cases.map((c) => c.courtName).toSet().length.toDouble();

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
                  AccountsCard(title: 'চলমান কেস', amount: running),
                  AccountsCard(title: 'বন্ধ কেস', amount: closed),
                  AccountsCard(title: 'কমপ্লিট কেস', amount: complicated),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AccountsCard(title: 'মোট কেস', amount: totalCases),
                  AccountsCard(title: 'নতুন কেস', amount: newCases),
                  AccountsCard(title: 'মোট কোর্ট', amount: totalCourts),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
