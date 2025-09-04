import 'package:court_dairy/widgets/data_not_found.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_tile.dart';
import 'all_transactions_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionController());
    final layoutController = Get.put(LayoutController());
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Get.to(() => AllTransactionsScreen());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: const Text('All Transactions'),
                ),
              ],
            ),
          ),
          Expanded(
            child: controller.transactions.isEmpty
                ? const DataNotFound(
                    title: 'Sorry', subtitle: 'No Transaction Found')
                : ListView.builder(
                    controller: layoutController.scrollController,
                    itemCount: controller.transactions.length > 10
                        ? 10
                        : controller.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.transactions[index];
                      return TransactionTile(
                        transaction: transaction,
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
