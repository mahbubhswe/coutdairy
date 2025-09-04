import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/party.dart';
import '../../case/controllers/case_controller.dart';
import '../../case/widgets/case_tile.dart';
import '../../../widgets/data_not_found.dart';

class PartyCasesScreen extends StatelessWidget {
  final Party party;
  PartyCasesScreen({super.key, required this.party});

  final CaseController _caseController = Get.isRegistered<CaseController>()
      ? Get.find<CaseController>()
      : Get.put(CaseController());

  bool _matchesParty(Party a, Party b) {
    // Match by name and phone to avoid false positives
    return a.name == b.name && a.phone == b.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${party.name} - কেস')),
      body: Obx(() {
        if (_caseController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final cases = _caseController.cases.where((c) {
          return _matchesParty(c.plaintiff, party) ||
              _matchesParty(c.defendant, party);
        }).toList();

        if (cases.isEmpty) {
          return const DataNotFound(title: 'Sorry', subtitle: 'No Case Found');
        }

        return ListView.builder(
          itemCount: cases.length,
          itemBuilder: (context, index) {
            final item = cases[index];
            return CaseTile(caseItem: item);
          },
        );
      }),
    );
  }
}

