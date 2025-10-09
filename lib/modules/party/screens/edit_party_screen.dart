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
        title: const Text('Edit party'),
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
              label: 'Name',
              hintText: 'Enter party name',
              prefixIcon: Icons.person,
            ),
            AppTextFromField(
              controller: controller.phone,
              label: 'Mobile',
              hintText: 'Enter mobile number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            AppTextFromField(
              controller: controller.address,
              label: 'Address',
              hintText: 'Enter address',
              prefixIcon: Icons.home,
              isMaxLines: 3,
            ),
            Obx(() => SwitchListTile(
                  title: const Text('SMS notifier'),
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
                label: 'Update',
                isLoading: controller.isLoading.value,
                onPressed: controller.enableBtn.value
                    ? () {
                        PanaraConfirmDialog.show(
                          context,
                          title: 'Confirm',
                          message: 'Do you want to update the party?',
                          confirmButtonText: 'Yes',
                          cancelButtonText: 'No',
                          onTapCancel: () {
                            Navigator.of(context).pop();
                          },
                          onTapConfirm: () async {
                            Navigator.of(context).pop();
                            final messenger = ScaffoldMessenger.of(context);
                            final success = await controller.updateParty();
                            if (!context.mounted) return;
                            if (success) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Party updated successfully'),
                                ),
                              );
                              Get.back();
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update party'),
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
