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
      final appBarColor =
          Theme.of(context).appBarTheme.backgroundColor ??
          Theme.of(context).colorScheme.primary;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

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

    // Case status dropdown removed as case status defaults to 'Ongoing'

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
          prefix: Icon(icon, color: cs.onSurfaceVariant, size: 20),
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
      appBar: AppBar(title: const Text('Add case')),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(5),
          child: DynamicMultiStepForm(
            steps: [
              FormStep(
                title: const Text('Case information'),
                content: Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),

                    titledChipRow(
                      title: 'Case type',
                      options: controller.caseTypes,
                      selected: controller.selectedCaseType,
                    ),
                    titledChipRow(
                      title: 'Court type',
                      options: controller.courtTypes,
                      selected: controller.selectedCourtType,
                    ),
                    AppTextFromField(
                      controller: controller.caseTitle,
                      label: 'Case title',
                      hintText: 'Enter the case title',
                      prefixIcon: Icons.title,
                    ),
                    AppTypeAheadField(
                      controller: controller.courtName,
                      label: 'Court name',
                      hintText: 'Enter the court name',
                      prefixIcon: Icons.account_balance,
                      suggestions: controller.allCourtNames,
                    ),
                    AppTextFromField(
                      controller: controller.caseNumber,
                      label: 'Case number',
                      hintText: 'Enter the case number',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.text,
                    ),
                    AppTextFromField(
                      controller: controller.underSection,
                      label: 'Under section',
                      hintText: 'Enter the under section (optional)',
                      prefixIcon: Icons.rule_outlined,
                    ),
                    Obx(
                      () {
                        final date = controller.filedDate.value;
                        final textTheme = Theme.of(context).textTheme;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Text(
                              'Filed Date',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            InputChip(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              label: Text(
                                date?.formattedDate ?? 'Select filed date',
                              ),
                              avatar: const Icon(
                                HugeIcons.strokeRoundedCalendar01,
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      date ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  controller.filedDate.value = picked;
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              FormStep(
                title: const Text('Party'),
                content: Column(
                  spacing: 10,
                  children: [
                    SizedBox(height: 5),
                    partyDropdown(
                      selected: controller.selectedPlaintiff,
                      label: 'Plaintiff',
                      hint: 'Select plaintiff',
                      icon: Icons.person_outline,
                    ),
                  ],
                ),
              ),
              FormStep(
                title: const Text('More details'),
                content: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 5),

                    AppTypeAheadField(
                      controller: controller.judgeName,
                      label: 'Judge name',
                      hintText: 'Enter the judge name',
                      prefixIcon: Icons.gavel,
                      suggestions: controller.allJudgeNames,
                    ),
                    AppTextFromField(
                      controller: controller.courtOrder,
                      label: 'Court order',
                      hintText: 'Enter the court order',
                      prefixIcon: Icons.article_outlined,
                    ),
                    Obx(
                      () {
                        final date = controller.hearingDate.value;
                        final textTheme = Theme.of(context).textTheme;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Text(
                              'Next Hearing Date',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            InputChip(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              label: Text(
                                date?.formattedDate ??
                                    'Select next hearing date',
                              ),
                              avatar: const Icon(
                                HugeIcons.strokeRoundedCalendar01,
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      date ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  controller.hearingDate.value = picked;
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            isLoading: controller.isLoading.value,
            controlsInBottom: true,
            controlsPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            stepIconColor: AppColors.fixedPrimary,
            headerColor: Theme.of(context).colorScheme.secondary,
            tightHorizontal: true,
            onSubmit: () {
              PanaraConfirmDialog.show(
                context,
                title: 'Confirm',
                message: 'Do you want to add the case?',
                confirmButtonText: 'Yes',
                cancelButtonText: 'No',
                onTapCancel: () {
                  Navigator.of(context).pop();
                },
                onTapConfirm: () async {
                  Navigator.of(context).pop();
                  final success = await controller.addCase();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Case added successfully')),
                    );
                    // Replace simple snackbar with an icon-enhanced variant
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text('Success'),
                              ), // customize message if needed
                            ],
                          ),
                        ),
                      );
                    Get.back();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add case'),
                      ),
                    );
                    // Replace simple snackbar with an icon-enhanced variant
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.error_outline, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text('Failed'),
                              ), // customize message if needed
                            ],
                          ),
                        ),
                      );
                  }
                },
                panaraDialogType: PanaraDialogType.normal,
              );
            },
          ),
        ),
      ),
    );
  }
}
