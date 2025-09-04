import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_from_field.dart';
import '../controllers/edit_party_controller.dart';
import '../../../models/party.dart';

class EditPartyScreen extends StatelessWidget {
  final Party party;
  const EditPartyScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<EditPartyController>()) {
      Get.delete<EditPartyController>();
    }
    final controller = Get.put(EditPartyController(party));
    return Scaffold(
      appBar: AppBar(
        title: const Text('পক্ষ সম্পাদনা'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          spacing: 16,
          children: [
            GestureDetector(
              onTap: controller.showImagePicker,
              child: Obx(() {
                final image = controller.photo.value;
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: image != null
                      ? FileImage(File(image.path))
                      : (party.photoUrl != null
                          ? NetworkImage(party.photoUrl!) as ImageProvider
                          : null),
                  child: image == null && party.photoUrl == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                );
              }),
            ),
            AppTextFromField(
              controller: controller.name,
              label: 'নাম',
              hintText: 'পক্ষের নাম লিখুন',
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
              label: 'ঠিকানা',
              hintText: 'ঠিকানা লিখুন',
              prefixIcon: Icons.home,
              isMaxLines: 3,
            ),
            Obx(() => SwitchListTile(
                  title: const Text('এসএমএস নোটিফায়ার'),
                  contentPadding: EdgeInsets.zero,
                  value: controller.isSendSms.value,
                  onChanged: (v) => controller.isSendSms.value = v,
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
                          message: 'পক্ষ আপডেট করতে চান?',
                          confirmButtonText: 'হ্যাঁ',
                          cancelButtonText: 'না',
                          onTapCancel: () {
                            Navigator.of(context).pop();
                          },
                          onTapConfirm: () async {
                            Navigator.of(context).pop();
                            final success = await controller.updateParty();
                            if (success) {
                              PanaraInfoDialog.show(
                                context,
                                title: 'সফল হয়েছে',
                                buttonText: 'Okey',
                                message: 'পক্ষ আপডেট করা হয়েছে',
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
                                message: 'পক্ষ আপডেট করতে ব্যর্থ হয়েছে',
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
