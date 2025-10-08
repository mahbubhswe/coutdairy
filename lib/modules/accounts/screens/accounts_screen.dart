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
    final layoutController = Get.find<LayoutController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          Expanded(
            child: controller.transactions.isEmpty
                ? const DataNotFound(
                    title: 'No results', subtitle: 'No transactions were found')
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
