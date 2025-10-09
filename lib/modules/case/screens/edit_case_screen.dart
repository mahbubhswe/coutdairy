import 'package:hugeicons/hugeicons.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/dynamic_multi_step_form.dart';
import '../../../widgets/app_type_ahead_field.dart';
import '../../../widgets/app_text_from_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import '../../../utils/app_date_formatter.dart';

import '../../../models/court_case.dart';
import '../../../models/party.dart';
import '../controllers/edit_case_controller.dart';

class EditCaseScreen extends StatelessWidget {
  const EditCaseScreen(this.caseItem, {super.key});

  final CourtCase caseItem;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditCaseController(caseItem));

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
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: options.map((t) {
                  final isSelected = selected.value == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
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
            ),
          ),
        ],
      );
    }

    Widget partyFields() {
      Future<void> openPartyPicker() async {
        FocusScope.of(context).unfocus();
        final selectedParty = await showModalBottomSheet<Party>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (sheetCtx) {
            return SafeArea(
              child: Obx(() {
                final savedParties = controller.parties;
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetCtx).size.height * 0.6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (savedParties.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('No saved parties found'),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: savedParties.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final party = savedParties[index];
                              return ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(party.name),
                                subtitle: Text(party.phone),
                                onTap: () => Navigator.of(sheetCtx).pop(party),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              }),
            );
          },
        );

        if (selectedParty != null) {
          controller.applyPlaintiff(selectedParty);
        }
      }

      return Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextFromField(
            controller: controller.plaintiffName,
            label: 'Plaintiff name',
            hintText: 'Enter plaintiff name',
            prefixIcon: Icons.person_outline,
            suffixIconButton: Obx(() {
              if (controller.isAddingParty.value) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              return IconButton(
                tooltip: 'Select from saved parties',
                icon: const Icon(Icons.people_outline),
                onPressed: openPartyPicker,
              );
            }),
          ),
          AppTextFromField(
            controller: controller.plaintiffPhone,
            label: 'Phone number',
            hintText: 'Enter phone number',
            prefixIcon: Icons.call_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit case')),
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
                    const SizedBox(height: 5),
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
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Filed Date',
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                  initialDate: date ?? DateTime.now(),
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
                    const SizedBox(height: 5),
                    partyFields(),
                  ],
                ),
              ),
              FormStep(
                title: const Text('More details'),
                content: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 5),
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
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Next Hearing Date',
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                  initialDate: date ?? DateTime.now(),
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
                message: 'Do you want to update the case?',
                confirmButtonText: 'Yes',
                cancelButtonText: 'No',
                onTapCancel: () {
                  Navigator.of(context).pop();
                },
                onTapConfirm: () async {
                  Navigator.of(context).pop();
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await controller.updateCase();
                  if (!context.mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Case updated successfully'
                            : 'Failed to update case',
                      ),
                    ),
                  );
                  if (success) {
                    Get.back();
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
