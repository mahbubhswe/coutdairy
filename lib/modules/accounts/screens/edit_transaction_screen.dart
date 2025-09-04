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
        title: const Text('লেনদেন আপডেট করুন'),
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
                  labelText: 'ধরণ',
                  hintText: 'লেনদেনের ধরণ নির্বাচন করুন',
                  prefixIcon: const Icon(Icons.category),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.4,
                    ),
                  ),
                ),
                items: getTransactionTypes()
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => controller.type.value = v,
              ),
              AppTextFromField(
                controller: controller.amount,
                label: 'পরিমাণ',
                hintText: 'পরিমাণ লিখুন',
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
                  labelText: 'পেমেন্ট পদ্ধতি',
                  hintText: 'পেমেন্ট পদ্ধতি নির্বাচন করুন',
                  prefixIcon: const Icon(Icons.payment),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.4,
                    ),
                  ),
                ),
                items: paymentMethods
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => controller.paymentMethod.value = v,
              ),
              AppTextFromField(
                controller: controller.note,
                label: 'নোট',
                hintText: 'নোট লিখুন',
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
                label: 'আপডেট করুন',
                isLoading: controller.isLoading.value,
                onPressed: controller.enableBtn.value
                    ? () {
                        PanaraConfirmDialog.show(
                          context,
                          title: 'নিশ্চিত করুন',
                          message: 'লেনদেন আপডেট করতে চান?',
                          confirmButtonText: 'হ্যাঁ',
                          cancelButtonText: 'না',
                          onTapCancel: () {
                            Navigator.of(context).pop();
                          },
                          onTapConfirm: () async {
                            Navigator.of(context).pop();
                            final success =
                                await controller.updateTransaction();
                            if (success) {
                              PanaraInfoDialog.show(
                                context,
                                title: 'সফল হয়েছে',
                                buttonText: 'Okey',
                                message: 'লেনদেন আপডেট করা হয়েছে',
                                panaraDialogType: PanaraDialogType.success,
                                barrierDismissible: false,
                                onTapDismiss: () {
                                  Navigator.of(context).pop();
                                  Get.back();
                                },
                              );
                            } else {
                              PanaraInfoDialog.show(
                                context,
                                title: 'ত্রুটি',
                                buttonText: 'Okey',
                                message: 'লেনদেন আপডেট করতে ব্যর্থ হয়েছে',
                                panaraDialogType: PanaraDialogType.error,
                                barrierDismissible: false,
                                onTapDismiss: () {
                                  Navigator.of(context).pop();
                                },
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
