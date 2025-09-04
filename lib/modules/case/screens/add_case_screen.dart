import 'package:hugeicons/hugeicons.dart';

import '../../../widgets/dynamic_multi_step_form.dart';
import '../../../widgets/app_text_from_field.dart';
import '../../../widgets/app_type_ahead_field.dart';
import '../../../constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import '../../../utils/app_date_formatter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../local_library/text_from_field_wraper.dart';

import '../controllers/add_case_controller.dart';
import '../../../models/party.dart';

class AddCaseScreen extends StatelessWidget {
  const AddCaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddCaseController());

    Widget titledChipRow({
      required String title,
      required List<String> options,
      required RxnString selected,
    }) {
      final appBarColor = Theme.of(context).appBarTheme.backgroundColor ??
          Theme.of(context).colorScheme.primary;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: options.map((t) {
                  final isSelected = selected.value == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 08),
                    child: ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      onSelected: (_) => selected.value = t,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : appBarColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      );
    }

    Widget caseStatusDropdown() {
      return Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedCaseStatus.value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 320,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: InputDecoration(
              labelText: 'Case Status',
              hintText: 'Select case status',
              prefixIcon: const Icon(Icons.flag_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            items: controller.caseStatuses
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => controller.selectedCaseStatus.value = v,
          ));
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
      appBar: AppBar(title: const Text('Add Case')),
      body: Obx(() => DynamicMultiStepForm(
            steps: [
              FormStep(
                title: const Text('Case Info'),
                content: Column(
                  spacing: 6,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titledChipRow(
                      title: 'Case Type',
                      options: controller.caseTypes,
                      selected: controller.selectedCaseType,
                    ),
                    titledChipRow(
                      title: 'Court Type',
                      options: controller.courtTypes,
                      selected: controller.selectedCourtType,
                    ),
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
                      keyboardType: TextInputType.text,
                    ),
                    caseStatusDropdown(),
                    AppTextFromField(
                      controller: controller.caseSummary,
                      label: 'Summary',
                      hintText: 'Enter summary',
                      prefixIcon: Icons.description_outlined,
                      isMaxLines: 3,
                    ),
                    Obx(() => ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
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
                  spacing: 6,
                  children: [
                    partyDropdown(
                      selected: controller.selectedPlaintiff,
                      label: 'Plaintiff',
                      hint: 'Select plaintiff',
                      icon: Icons.person_outline,
                    ),
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
                  spacing: 6,
                  children: [
                    Obx(() => ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
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
                            if (picked != null) {
                              controller.hearingDate.value = picked;
                            }
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
            controlsPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            stepIconColor: AppColors.fixedPrimary,
            onSubmit: () {
              PanaraConfirmDialog.show(
                context,
                title: 'নিশ্চিত করুন',
                message: 'কেস যুক্ত করতে চান?',
                confirmButtonText: 'হ্যাঁ',
                cancelButtonText: 'না',
                onTapCancel: () {
                  Navigator.of(context).pop();
                },
                onTapConfirm: () async {
                  Navigator.of(context).pop();
                  final success = await controller.addCase();
                  if (success) {
                    PanaraInfoDialog.show(
                      context,
                      title: 'সফল হয়েছে',
                      buttonText: 'Okey',
                      message: 'কেস যুক্ত করা হয়েছে',
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
                      message: 'কেস যুক্ত করতে ব্যর্থ হয়েছে',
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
