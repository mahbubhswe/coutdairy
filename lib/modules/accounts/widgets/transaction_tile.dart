import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/transaction.dart';
import '../../../utils/app_date_formatter.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'Expense':
        return Icons.remove_circle_outline;
      case 'Deposit':
        return Icons.add_circle_outline;
      case 'Withdrawal':
        return Icons.account_balance_wallet_outlined;
      case 'Transfer':
        return Icons.swap_horiz;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountText = NumberFormat.currency(
      locale: 'bn_BD',
      symbol: '৳',
      decimalDigits: 0,
    ).format(transaction.amount);
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 12, right: 8),
        dense: true,
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          foregroundColor: Colors.orange,
          child: Icon(_iconForType(transaction.type)),
        ),
        title: Text(
          transaction.type,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.createdAt.formattedDate,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              'Payment: ${transaction.paymentMethod}',
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amountText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange,
              ),
            ),
            if (onEdit != null || onDelete != null) const SizedBox(width: 8),
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
                    items.add(
                        const PopupMenuItem(value: 'edit', child: Text('Edit')));
                  }
                  if (onDelete != null) {
                    items.add(const PopupMenuItem(
                        value: 'delete', child: Text('Delete')));
                  }
                  return items;
                },
              ),
          ],
        ),
      ),
    );
  }
}
