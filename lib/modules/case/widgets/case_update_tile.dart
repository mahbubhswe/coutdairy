import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/court_case.dart';
import '../../../utils/app_date_formatter.dart';
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
      child: ListTile(
        title: Text(caseItem.caseTitle),
        subtitle: Text(
          'Case No: ${caseItem.caseNumber}\nNext date: ${lastDate != null ? _format(lastDate) : 'N/A'}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.edit_calendar_outlined),
          onPressed: () async {
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
