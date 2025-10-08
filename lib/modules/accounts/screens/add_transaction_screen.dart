import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_from_field.dart';
import '../../../utils/payment_methods.dart';
import '../../../utils/transaction_types.dart';
import '../controllers/add_transaction_controller.dart';

class AddTransactionScreen extends StatelessWidget {
  final String? partyId;
  const AddTransactionScreen({super.key, this.partyId});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<AddTransactionController>()) {
      Get.delete<AddTransactionController>();
    }
    final controller = Get.put(AddTransactionController(partyId: partyId));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color fieldFillColor = Color.alphaBlend(
      cs.primary.withOpacity(isDark ? 0.18 : 0.08),
      cs.surface,
    );
    final OutlineInputBorder dropdownBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Add new transaction')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final double scrollBottomPadding = bottomInset + 96;
            return Column(
              children: [
                Expanded(
                  child: Obx(() {
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        scrollBottomPadding,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Column(
                              spacing: 20,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: controller.type.value,
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(12),
                                  menuMaxHeight: 320,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Type',
                                    hintText: 'Select transaction type',
                                    prefixIcon: const Icon(
                                      Icons.account_balance_wallet_outlined,
                                    ),
                                    filled: true,
                                    fillColor: fieldFillColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: dropdownBorder,
                                    enabledBorder: dropdownBorder,
                                    focusedBorder: dropdownBorder,
                                  ),
                                  dropdownColor: fieldFillColor,
                                  items: getTransactionTypes()
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => controller.type.value = v,
                                ),
                                AppTextFromField(
                                  controller: controller.amount,
                                  label: 'Amount',
                                  hintText: 'Enter amount',
                                  prefixIcon: Icons.money,
                                  keyboardType: TextInputType.number,
                                ),
                                DropdownButtonFormField<String>(
                                  value: controller.paymentMethod.value,
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(12),
                                  menuMaxHeight: 320,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Payment method',
                                    hintText: 'Select payment method',
                                    prefixIcon: const Icon(Icons.payment),
                                    filled: true,
                                    fillColor: fieldFillColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: dropdownBorder,
                                    enabledBorder: dropdownBorder,
                                    focusedBorder: dropdownBorder,
                                  ),
                                  dropdownColor: fieldFillColor,
                                  items: paymentMethods
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      controller.paymentMethod.value = v,
                                ),
                                AppTextFromField(
                                  controller: controller.note,
                                  label: 'Note',
                                  hintText: 'Enter a note',
                                  prefixIcon: Icons.note,
                                  isMaxLines: 3,
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: AppButton(
                        label: 'Save',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.enableBtn.value
                            ? () {
                                PanaraConfirmDialog.show(
                                  context,
                                  title: 'Confirm',
                                  message: 'Do you want to add the transaction?',
                                  confirmButtonText: 'Yes',
                                  cancelButtonText: 'No',
                                  onTapCancel: () {
                                    Navigator.of(context).pop();
                                  },
                                  onTapConfirm: () async {
                                    Navigator.of(context).pop();
                                    final success = await controller
                                        .addTransaction();
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Transaction added successfully',
                                          ),
                                        ),
                                      );
                                      Get.back();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to add transaction',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  panaraDialogType: PanaraDialogType.normal,
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
