import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/party.dart';
import '../../../services/app_firebase.dart';
import '../../../utils/activation_guard.dart';
import '../../accounts/controllers/transaction_controller.dart';
import '../../accounts/services/transaction_service.dart';
import '../../accounts/widgets/transaction_tile.dart';
import '../../accounts/screens/edit_transaction_screen.dart';
import '../../../widgets/data_not_found.dart';

class PartyTransactionsScreen extends StatelessWidget {
  final Party party;
  PartyTransactionsScreen({super.key, required this.party});

  final TransactionController controller = Get.isRegistered<TransactionController>()
      ? Get.find<TransactionController>()
      : Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${party.name} - লেনদেন')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final filtered = controller.transactions
            .where((t) => t.partyId == party.docId)
            .toList();
        if (filtered.isEmpty) {
          return const DataNotFound(title: 'Sorry', subtitle: 'No Transaction Found');
        }
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final transaction = filtered[index];
            return TransactionTile(
              transaction: transaction,
              onEdit: () {
                if (ActivationGuard.check()) {
                  Get.to(() => EditTransactionScreen(transaction: transaction));
                }
              },
              onDelete: () async {
                if (!ActivationGuard.check()) return;
                final user = AppFirebase().currentUser;
                if (user != null && transaction.docId != null) {
                  await TransactionService.deleteTransaction(
                      transaction.docId!, user.uid);
                }
              },
            );
          },
        );
      }),
    );
  }
}
