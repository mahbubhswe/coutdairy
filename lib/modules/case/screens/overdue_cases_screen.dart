import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/case_controller.dart';
import '../widgets/case_update_tile.dart';

class OverdueCasesScreen extends StatelessWidget {
  const OverdueCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CaseController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overdue hearings'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = controller.overdueCases;
        if (list.isEmpty) {
          return const Center(child: Text('No overdue cases'));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) => CaseUpdateTile(caseItem: list[index]),
        );
      }),
    );
  }
}
