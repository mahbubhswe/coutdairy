import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/party.dart';
import '../../accounts/screens/add_transaction_screen.dart';

class PartyTile extends StatelessWidget {
  final Party party;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PartyTile({
    super.key,
    required this.party,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 12, right: 8),
        dense: true,
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          foregroundColor: Colors.orange,
          backgroundImage: party.photoUrl != null && party.photoUrl!.isNotEmpty
              ? NetworkImage(party.photoUrl!)
              : null,
          child: (party.photoUrl == null || party.photoUrl!.isEmpty)
              ? Text(_initials(party.name))
              : null,
        ),
        title: Text(
          party.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (party.phone.isNotEmpty)
              Text(
                party.phone,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            if (party.address.isNotEmpty)
              Text(
                party.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'পেমেন্ট',
              icon: const Icon(
                HugeIcons.strokeRoundedPayment02,
                color: Colors.green,
              ),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () async {
                Get.to(
                  () => AddTransactionScreen(partyId: party.docId),
                  fullscreenDialog: true,
                );
              },
            ),
            IconButton(
              tooltip: 'কল করুন',
              icon: const Icon(HugeIcons.strokeRoundedCall02),
              color: Colors.green,
              onPressed: () async {
                final uri = Uri(scheme: 'tel', path: party.phone);
                try {
                  await launchUrl(uri);
                } catch (_) {}
              },
            ),
            if (onEdit != null || onDelete != null) const SizedBox(width: 4),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[];
                  if (onEdit != null) {
                    items.add(const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ));
                  }
                  if (onDelete != null) {
                    items.add(const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ));
                  }
                  return items;
                },
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
