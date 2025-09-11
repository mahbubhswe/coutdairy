import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_from_field.dart';
import '../controllers/add_party_controller.dart';

class AddPartyScreen extends StatelessWidget {
  const AddPartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<AddPartyController>()) {
      Get.delete<AddPartyController>();
    }
    final controller = Get.put(AddPartyController());
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('নতুন পার্টি যোগ করুন')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          spacing: 16,
          children: [
            Obx(() {
              final image = controller.photo.value;
              return Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: controller.showImagePicker,
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      if (image == null)
                        DottedBorder(
                          color: cs.outlineVariant,
                          strokeWidth: 1.4,
                          dashPattern: const [8, 6],
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 125,
                              height: 125,
                              color: cs.surfaceContainerHighest,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_rounded,
                                      size: 36,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'ফটো যোগ করুন',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(image.path),
                            width: 125,
                            height: 125,
                            fit: BoxFit.cover,
                          ),
                        ),
                      // Dotted border shown only when no image (handled above)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            AppTextFromField(
              controller: controller.name,
              label: 'নাম',
              hintText: 'পার্টির নাম লিখুন',
              prefixIcon: Icons.person,
            ),
            AppTextFromField(
              controller: controller.phone,
              label: 'মোবাইল',
              hintText: 'মোবাইল নম্বর লিখুন',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            AppTextFromField(
              controller: controller.address,
              label: 'ঠিকানা (ঐচ্ছিক)',
              hintText: 'ঠিকানা লিখতে পারেন (ঐচ্ছিক)',
              prefixIcon: Icons.home,
              isMaxLines: 3,
            ),
            // SMS notification option removed
            const SizedBox(height: 20),
          ],
        ),
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
                        title: 'আপনি কি নিশ্চিত?',
                        message: 'পার্টি তথ্য সংরক্ষণ করতে চান?',
                        confirmButtonText: 'হ্যাঁ',
                        cancelButtonText: 'না',
                        onTapCancel: () {
                          Navigator.of(context).pop();
                        },
                        onTapConfirm: () async {
                          Navigator.of(context).pop();
                          final success = await controller.addParty();
                          if (success) {
                            PanaraInfoDialog.show(
                              context,
                              title: 'সফল',
                              buttonText: 'ঠিক আছে',
                              message: 'পার্টি সফলভাবে যুক্ত হয়েছে',
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
                              buttonText: 'ঠিক আছে',
                              message: 'পার্টি যোগ করতে ব্যর্থ হয়েছে',
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
        ),
      ),
    );
  }
}

// Removed custom dashed painter in favor of dotted_border package
