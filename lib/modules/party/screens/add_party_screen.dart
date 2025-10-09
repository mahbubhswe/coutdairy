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
      appBar: AppBar(title: const Text('Add new party')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final double scrollBottomPadding = bottomInset + 96;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 20,
                            children: [
                              Obx(() {
                                final image = controller.photo.value;
                                return InkWell(
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
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Container(
                                              width: 140,
                                              height: 140,
                                              color: cs.surface,
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.camera_alt_rounded,
                                                      size: 38,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Add photo',
                                                      style: TextStyle(
                                                        color:
                                                            cs.onSurfaceVariant,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Image.file(
                                            File(image.path),
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      Positioned(
                                        right: 6,
                                        bottom: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: cs.primary,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: cs.primary.withValues(alpha: 
                                                  0.25,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: cs.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
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
                                label: 'Address (optional)',
                                hintText: 'You may enter an address (optional)',
                                prefixIcon: Icons.home,
                                isMaxLines: 3,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  return AnimatedPadding(
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
                                    title: 'Are you sure?',
                                    message: 'Do you want to save this party?',
                                    confirmButtonText: 'Yes',
                                    cancelButtonText: 'No',
                                    onTapCancel: () {
                                      Navigator.of(context).pop();
                                    },
                                    onTapConfirm: () async {
                                      Navigator.of(context).pop();
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      final success = await controller
                                          .addParty();
                                      if (!context.mounted) return;
                                      if (success) {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Party added successfully',
                                            ),
                                          ),
                                        );
                                        Get.back();
                                      } else {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to add party',
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
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Removed custom dashed painter in favor of dotted_border package
