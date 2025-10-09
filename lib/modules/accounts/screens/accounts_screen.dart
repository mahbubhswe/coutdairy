import 'package:court_dairy/widgets/data_not_found.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_tile.dart';
import '../../../utils/transaction_types.dart';

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
      final filters = <String>['All', ...getTransactionTypes()];
      final selectedFilter = controller.selectedFilter.value;
      final filteredTransactions = controller.filteredTransactions;
      final total = controller.filteredTotal;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final chipContainerColor = colorScheme.surface;
      final accentColor = colorScheme.secondary;
      final mutedTextColor = colorScheme.onSurfaceVariant;
      return Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final filterLabel = filters[index];
                final isSelected = selectedFilter == filterLabel;
                return ChoiceChip(
                  label: Text(
                    filterLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? colorScheme.onSecondary
                          : mutedTextColor,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (value) {
                    if (!value) return;
                    controller.setFilter(filterLabel);
                  },
                  selectedColor: accentColor,
                  backgroundColor: chipContainerColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(
                      color: isSelected
                          ? accentColor
                          : colorScheme.outlineVariant.withOpacity(0.6),
                    ),
                  ),
                  showCheckmark: false,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: filters.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.6),
                  width: 1,
                ),
                color: chipContainerColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: mutedTextColor,
                    ),
                  ),
                  Text(
                    total.toStringAsFixed(2),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? DataNotFound(
                    title: 'No results',
                    subtitle: selectedFilter == 'All'
                        ? 'No transactions were found'
                        : 'No transactions found for $selectedFilter',
                  )
                : ListView.builder(
                    controller: layoutController.scrollController,
                    itemCount: filteredTransactions.length > 10
                        ? 10
                        : filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return TransactionTile(transaction: transaction);
                    },
                  ),
          ),
        ],
      );
    });
  }
}
