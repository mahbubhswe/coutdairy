import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/case_controller.dart';
import '../widgets/case_tile.dart';

class CasesOnDateScreen extends StatelessWidget {
  const CasesOnDateScreen({super.key, required this.date});

  final DateTime date;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaseController>();
    final title = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Cases on $title'),
      ),
      body: Obx(() {
        final list = controller.cases.where((c) {
          final d = c.nextHearingDate?.toDate();
          if (d == null) return false;
          return _isSameDay(d, date);
        }).toList();
        if (list.isEmpty) {
          return const Center(child: Text('No cases for this date'));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) => CaseTile(caseItem: list[i]),
        );
      }),
    );
  }
}

