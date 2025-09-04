import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/case_controller.dart';
import '../widgets/case_tile.dart';

class CaseSearchScreen extends StatelessWidget {
  CaseSearchScreen({super.key});

  final query = ''.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaseController>();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search cases',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (v) => query.value = v.toLowerCase(),
        ),
      ),
      body: Obx(() {
        final q = query.value;
        final results = controller.cases.where((c) {
          final title = c.caseTitle.toLowerCase();
          final number = c.caseNumber.toLowerCase();
          final plaintiff = c.plaintiff.name.toLowerCase();
          final defendant = c.defendant.name.toLowerCase();
          final pPhone = c.plaintiff.phone.toLowerCase();
          final dPhone = c.defendant.phone.toLowerCase();
          return title.contains(q) ||
              number.contains(q) ||
              plaintiff.contains(q) ||
              defendant.contains(q) ||
              pPhone.contains(q) ||
              dPhone.contains(q);
        }).toList();
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (_, i) => CaseTile(caseItem: results[i]),
        );
      }),
    );
  }
}
