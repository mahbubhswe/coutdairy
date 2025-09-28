import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../models/court_case.dart';
import '../../../utils/app_date_formatter.dart';
import '../../../utils/activation_guard.dart';
import '../controllers/case_controller.dart';

class CaseUpdateTile extends StatelessWidget {
  const CaseUpdateTile({super.key, required this.caseItem});

  final CourtCase caseItem;

  String _format(DateTime date) => date.formattedDate;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaseController>();
    final lastDate = caseItem.nextHearingDate?.toDate();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 4),
        title: Text(caseItem.caseTitle),
        subtitle: Text(
          'Case No: ${caseItem.caseNumber}\nNext date: ${lastDate != null ? _format(lastDate) : 'N/A'}',
        ),
        trailing: IconButton(
          icon: const Icon(HugeIcons.strokeRoundedCalendar01),
          onPressed: () async {
            if (!ActivationGuard.check()) return;
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              await controller.updateNextHearingDate(caseItem, picked);
            }
          },
        ),
      ),
    );
  }
}
