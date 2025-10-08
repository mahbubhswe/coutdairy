import 'package:flutter/material.dart';

import '../models/court_case.dart';

class CaseTile extends StatelessWidget {
  final CourtCase data;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CaseTile(
      {super.key, required this.data, this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: ListTile(
        title: Text(data.caseTitle),
        onTap: onTap,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit?.call();
            } else if (value == 'delete') {
              onDelete?.call();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
