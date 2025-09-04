import 'package:hugeicons/hugeicons.dart';

import '../../../widgets/dynamic_multi_step_form.dart';
import '../../../widgets/app_type_ahead_field.dart';
import '../../../widgets/app_text_from_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import '../../../utils/app_date_formatter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../local_library/text_from_field_wraper.dart';

import '../../../models/court_case.dart';
import '../../../models/party.dart';
import '../controllers/edit_case_controller.dart';

class EditCaseScreen extends StatelessWidget {
  const EditCaseScreen(this.caseItem, {super.key});

  final CourtCase caseItem;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditCaseController(caseItem));

    Widget caseTypeChips() {
      final appBarColor = Theme.of(context).appBarTheme.backgroundColor ??
          Theme.of(context).colorScheme.primary;
      return Wrap(
        spacing: 8,
        children: controller.caseTypes.map((type) {
          return Obx(() {
            final isSelected = controller.selectedCaseType.value == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (_) => controller.selectedCaseType.value = type,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? Colors.transparent : appBarColor,
                ),
              ),
            );
          });
        }).toList(),
      );
    }

    Widget partyDropdown({
      required Rx<Party?> selected,
      required String label,
      required String hint,
      required IconData icon,
    }) {
      final textController = TextEditingController();
      return Obx(() {
        final cs = Theme.of(context).colorScheme;
        if (selected.value != null &&
            textController.text != selected.value!.name) {
          textController.text = selected.value!.name;
        }
        return TextFormFieldWrapper(
          borderFocusedColor: cs.primary,
          formField: TypeAheadField<Party>(
            controller: textController,
            builder: (context, textEditingController, focusNode) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                cursorColor: cs.onSurface,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
                ),
                onChanged: (_) => selected.value = null,
              );
            },
            suggestionsCallback: (pattern) {
              final query = pattern.toLowerCase();
              return controller.parties.where((p) {
                return p.name.toLowerCase().contains(query) ||
                    p.phone.contains(pattern);
              }).toList();
            },
            itemBuilder: (context, Party party) {
              return ListTile(
                title: Text(party.name),
                subtitle: Text(party.phone),
              );
            },
            onSelected: (Party party) {
              selected.value = party;
              textController.text = party.name;
            },
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Case')),
      body: Obx(() => DynamicMultiStepForm(
            steps: [
              FormStep(
                title: const Text('Case Info'),
                content: Column(
                  spacing: 10,
                  children: [
                    caseTypeChips(),
                    AppTextFromField(
                      controller: controller.caseTitle,
                      label: 'Case Title',
                      hintText: 'Enter case title',
                      prefixIcon: Icons.title,
                    ),
                    AppTypeAheadField(
                      controller: controller.courtName,
                      label: 'Court Name',
                      hintText: 'Enter court name',
                      prefixIcon: Icons.account_balance,
                      suggestions: controller.allCourtNames,
                    ),
                    AppTextFromField(
                      controller: controller.caseNumber,
                      label: 'Case Number',
                      hintText: 'Enter case number',
                      prefixIcon: Icons.numbers,
                    ),
                    AppTextFromField(
                      controller: controller.caseStatus,
                      label: 'Case Status',
                      hintText: 'Enter case status',
                      prefixIcon: Icons.flag_outlined,
                    ),
                    AppTextFromField(
                      controller: controller.caseSummary,
                      label: 'Summary',
                      hintText: 'Enter summary',
                      prefixIcon: Icons.description_outlined,
                      isMaxLines: 3,
                    ),
                    Obx(() => ListTile(
                          title: Text(controller.filedDate.value?.formattedDate ??
                              'Filed Date'),
                          trailing:
                              const Icon(HugeIcons.strokeRoundedCalendar01),
                          onTap: () async {
                            final picked = await showDatePicker(
                                context: context,
                                initialDate: controller.filedDate.value ??
                                    DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (picked != null)
                              controller.filedDate.value = picked;
                          },
                        )),
                  ],
                ),
              ),
              FormStep(
                title: const Text('Parties'),
                content: Column(
                  children: [
                    partyDropdown(
                      selected: controller.selectedPlaintiff,
                      label: 'Plaintiff',
                      hint: 'Select plaintiff',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    partyDropdown(
                      selected: controller.selectedDefendant,
                      label: 'Defendant',
                      hint: 'Select defendant',
                      icon: Icons.person_outline,
                    ),
                  ],
                ),
              ),
              FormStep(
                title: const Text('More'),
                content: Column(
                  spacing: 10,
                  children: [
                    Obx(() => ListTile(
                          title: Text(controller.hearingDate.value?.formattedDate ??
                              'Hearing Date'),
                          trailing:
                              const Icon(HugeIcons.strokeRoundedCalendar01),
                          onTap: () async {
                            final picked = await showDatePicker(
                                context: context,
                                initialDate: controller.hearingDate.value ??
                                    DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (picked != null)
                              controller.hearingDate.value = picked;
                          },
                        )),
                    AppTypeAheadField(
                      controller: controller.judgeName,
                      label: 'Judge Name',
                      hintText: 'Enter judge name',
                      prefixIcon: Icons.gavel,
                      suggestions: controller.allJudgeNames,
                    ),
                    AppTextFromField(
                      controller: controller.courtOrder,
                      label: 'Court Order',
                      hintText: 'Enter court order',
                      prefixIcon: Icons.article_outlined,
                    ),
                  ],
                ),
              ),
            ],
            isLoading: controller.isLoading.value,
            controlsInBottom: true,
            onSubmit: () {
              PanaraConfirmDialog.show(
                context,
                title: 'নিশ্চিত করুন',
                message: 'কেস আপডেট করতে চান?',
                confirmButtonText: 'হ্যাঁ',
                cancelButtonText: 'না',
                onTapCancel: () {
                  Navigator.of(context).pop();
                },
                onTapConfirm: () async {
                  Navigator.of(context).pop();
                  final success = await controller.updateCase();
                  if (success) {
                    PanaraInfoDialog.show(
                      context,
                      title: 'সফল হয়েছে',
                      buttonText: 'Okey',
                      message: 'কেস আপডেট করা হয়েছে',
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
                      message: 'কেস আপডেট করতে ব্যর্থ হয়েছে',
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
            },
          )),
    );
  }
}
