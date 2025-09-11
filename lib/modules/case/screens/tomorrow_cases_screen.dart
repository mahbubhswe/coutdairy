import 'package:court_dairy/widgets/data_not_found.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/case_controller.dart';
import '../widgets/case_tile.dart';

class TomorrowCasesScreen extends StatelessWidget {
  const TomorrowCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaseController>();
    return Scaffold(
      appBar: AppBar(title: const Text('আগামীকালের কেসসমূহ')),
      body: Obx(() {
        final list = controller.tomorrowCases;
        if (list.isEmpty) {
          return const DataNotFound(
              title: 'দুঃখিত', subtitle: 'কোনো কেস পাওয়া যায়নি');
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) => CaseTile(caseItem: list[i]),
        );
      }),
    );
  }
}
