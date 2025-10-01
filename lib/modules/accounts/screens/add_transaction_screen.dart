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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('নতুন লেনদেন যুক্ত করুন')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Obx(() {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: cs.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                    child: Column(
                      spacing: 20,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'লেনদেনের তথ্য',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
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
                            fillColor: cs.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          items: getTransactionTypes()
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
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
                            fillColor: cs.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          items: paymentMethods
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
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
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
      bottomNavigationBar: Obx(
        () => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: 'সেভ করুন',
              isLoading: controller.isLoading.value,
              onPressed: controller.enableBtn.value
                  ? () {
                      PanaraConfirmDialog.show(
                        context,
                        title: 'নিশ্চিত করুন',
                        message: 'লেনদেন যুক্ত করতে চান?',
                        confirmButtonText: 'হ্যাঁ',
                        cancelButtonText: 'না',
                        onTapCancel: () {
                          Navigator.of(context).pop();
                        },
                        onTapConfirm: () async {
                          Navigator.of(context).pop();
                          final success = await controller.addTransaction();
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('লেনদেন যুক্ত করা হয়েছে'),
                              ),
                            );
                            Get.back();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('লেনদেন যুক্ত করতে ব্যর্থ হয়েছে'),
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
    );
  }
}
