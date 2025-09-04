import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/court_case.dart';
import '../screens/case_detail_screen.dart';

class CaseTile extends StatelessWidget {
  const CaseTile({super.key, required this.caseItem});

  final CourtCase caseItem;

  String _initials(String text) {
    final parts = text.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  // Keep UI minimal per request: title, number, court name

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Get.to(() => CaseDetailScreen(caseItem)),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 12, right: 8),
          dense: true,
          leading: CircleAvatar(
            backgroundColor: Colors.orange.shade100,
            foregroundColor: Colors.orange,
            child: Text(
              _initials(caseItem.caseTitle),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          title: Text(
            caseItem.caseTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.confirmation_number_outlined,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Case No: ${caseItem.caseNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.account_balance_outlined,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      caseItem.courtName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Trailing arrow to indicate navigation
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
