import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_from_field.dart';
import '../../../utils/payment_methods.dart';
import '../../../utils/transaction_types.dart';
import '../../../models/transaction.dart';
import '../controllers/edit_transaction_controller.dart';

class EditTransactionScreen extends StatelessWidget {
  final Transaction transaction;
  const EditTransactionScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<EditTransactionController>()) {
      Get.delete<EditTransactionController>();
    }
    final controller = Get.put(EditTransactionController(transaction));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update transaction'),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 16,
            children: [
              DropdownButtonFormField<String>(
                value: controller.type.value,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                menuMaxHeight: 320,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: InputDecoration(
                  labelText: 'Type',
                  hintText: 'Select transaction type',
                  prefixIcon: const Icon(Icons.category),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                items: getTransactionTypes()
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: InputDecoration(
                  labelText: 'Payment method',
                  hintText: 'Select payment method',
                  prefixIcon: const Icon(Icons.payment),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                items: paymentMethods
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => controller.paymentMethod.value = v,
              ),
              AppTextFromField(
                controller: controller.note,
                label: 'Note',
                hintText: 'Enter a note',
                prefixIcon: Icons.note,
                isMaxLines: 3,
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() => SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Update',
                isLoading: controller.isLoading.value,
                onPressed: controller.enableBtn.value
                    ? () {
                        PanaraConfirmDialog.show(
                          context,
                          title: 'Confirm',
                          message: 'Do you want to update the transaction?',
                          confirmButtonText: 'Yes',
                          cancelButtonText: 'No',
                          onTapCancel: () {
                            Navigator.of(context).pop();
                          },
                          onTapConfirm: () async {
                            Navigator.of(context).pop();
                            final success =
                                await controller.updateTransaction();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaction updated successfully'),
                                ),
                              );
                              Get.back();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update transaction'),
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
          )),
    );
  }
}
