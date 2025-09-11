import 'package:court_dairy/widgets/data_not_found.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/app_firebase.dart';
import '../../../utils/transaction_types.dart';
import '../controllers/transaction_controller.dart';
import '../services/transaction_service.dart';
import '../widgets/transaction_tile.dart';
import 'edit_transaction_screen.dart';
import '../../../utils/activation_guard.dart';

class AllTransactionsScreen extends StatelessWidget {
  AllTransactionsScreen({super.key});

  final controller = Get.find<TransactionController>();
  final RxString typeFilter = 'All'.obs;
  final RxString dateFilter = 'All'.obs;

  @override
  Widget build(BuildContext context) {
    final types = ['All', ...getTransactionTypes()];
    final dates = ['All', 'Today', 'This Week', 'This Month'];
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('সমস্ত লেনদেন')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ধরন',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Obx(() {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: types.map((t) {
                        final selected = typeFilter.value == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t == 'All' ? 'সব' : t),
                            selected: selected,
                            onSelected: (_) => typeFilter.value = t,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: selected
                                    ? Colors.transparent
                                    : appBarColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Text('তারিখ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                      value: dateFilter.value,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      menuMaxHeight: 320,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: const Icon(Icons.date_range_outlined),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.7),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      items: dates
                          .map(
                              (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e == 'All'
                                      ? 'সব'
                                      : e == 'Today'
                                          ? 'আজ'
                                          : e == 'This Week'
                                              ? 'এই সপ্তাহ'
                                              : e == 'This Month'
                                                  ? 'এই মাস'
                                                  : e)))
                          .toList(),
                      onChanged: (v) => dateFilter.value = v ?? 'All',
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final filtered = controller.transactions.where((t) {
                final now = DateTime.now();
                bool typeMatch =
                    typeFilter.value == 'All' || t.type == typeFilter.value;
                bool dateMatch = true;
                switch (dateFilter.value) {
                  case 'Today':
                    dateMatch = t.createdAt.year == now.year &&
                        t.createdAt.month == now.month &&
                        t.createdAt.day == now.day;
                    break;
                  case 'This Week':
                    final start = now.subtract(Duration(days: now.weekday - 1));
                    final end = start.add(const Duration(days: 7));
                    dateMatch =
                        t.createdAt.isAfter(start) && t.createdAt.isBefore(end);
                    break;
                  case 'This Month':
                    dateMatch = t.createdAt.year == now.year &&
                        t.createdAt.month == now.month;
                    break;
                  default:
                    dateMatch = true;
                }
                return typeMatch && dateMatch;
              }).toList();

              if (filtered.isEmpty) {
                return const DataNotFound(
                    title: 'দুঃখিত', subtitle: 'কোনো লেনদেন পাওয়া যায়নি');
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final transaction = filtered[index];
                  return TransactionTile(
                    transaction: transaction,
                    onEdit: () {
                      if (ActivationGuard.check()) {
                        Get.to(() =>
                            EditTransactionScreen(transaction: transaction));
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
          )
        ],
      ),
    );
  }
}
