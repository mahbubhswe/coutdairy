import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../themes/theme_controller.dart';
import '../../case/controllers/case_controller.dart';
import 'accounts_card.dart';

class AccountsFirstCard extends StatelessWidget {
  const AccountsFirstCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
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
              AccountsCard(title: 'চলমান কেস', amount: running),
              AccountsCard(title: 'বন্ধ কেস', amount: closed),
              AccountsCard(title: 'কমপ্লিট কেস', amount: complicated),
              AccountsCard(title: 'মোট কেস', amount: totalCases),
            ],
          ),
        ),
      );
    });
  }
}
