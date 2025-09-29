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
      appBar: AppBar(title: const Text('কেস যোগ করুন')),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(5),
          child: DynamicMultiStepForm(
            steps: [
              FormStep(
                title: const Text('কেস তথ্য'),
                content: Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),

                    titledChipRow(
                      title: 'কেসের ধরন',
                      options: controller.caseTypes,
                      selected: controller.selectedCaseType,
                    ),
                    titledChipRow(
                      title: 'আদালতের ধরন',
                      options: controller.courtTypes,
                      selected: controller.selectedCourtType,
                    ),
                    AppTextFromField(
                      controller: controller.caseTitle,
                      label: 'কেসের শিরোনাম',
                      hintText: 'কেসের শিরোনাম লিখুন',
                      prefixIcon: Icons.title,
                    ),
                    AppTypeAheadField(
                      controller: controller.courtName,
                      label: 'আদালতের নাম',
                      hintText: 'আদালতের নাম লিখুন',
                      prefixIcon: Icons.account_balance,
                      suggestions: controller.allCourtNames,
                    ),
                    AppTextFromField(
                      controller: controller.caseNumber,
                      label: 'কেস নম্বর',
                      hintText: 'কেস নম্বর লিখুন',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.text,
                    ),
                    AppTextFromField(
                      controller: controller.caseSummary,
                      label: 'সারাংশ',
                      hintText: 'সারাংশ লিখুন',
                      prefixIcon: Icons.description_outlined,
                      isMaxLines: 3,
                    ),
                    Obx(
                      () => InputChip(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        label: Text(
                          controller.filedDate.value?.formattedDate ??
                              'দাখিলের তারিখ',
                        ),
                        avatar: const Icon(HugeIcons.strokeRoundedCalendar01),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                controller.filedDate.value ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            controller.filedDate.value = picked;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              FormStep(
                title: const Text('পক্ষসমূহ'),
                content: Column(
                  spacing: 10,
                  children: [
                    SizedBox(height: 5),
                    partyDropdown(
                      selected: controller.selectedPlaintiff,
                      label: 'বাদী',
                      hint: 'বাদী নির্বাচন করুন',
                      icon: Icons.person_outline,
                    ),
                    partyDropdown(
                      selected: controller.selectedDefendant,
                      label: 'বিবাদী',
                      hint: 'বিবাদী নির্বাচন করুন',
                      icon: Icons.person_outline,
                    ),
                  ],
                ),
              ),
              FormStep(
                title: const Text('আরও'),
                content: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 5),

                    AppTypeAheadField(
                      controller: controller.judgeName,
                      label: 'বিচারকের নাম',
                      hintText: 'বিচারকের নাম লিখুন',
                      prefixIcon: Icons.gavel,
                      suggestions: controller.allJudgeNames,
                    ),
                    AppTextFromField(
                      controller: controller.courtOrder,
                      label: 'আদালতের আদেশ',
                      hintText: 'আদালতের আদেশ লিখুন',
                      prefixIcon: Icons.article_outlined,
                    ),
                    Obx(
                      () => InputChip(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        label: Text(
                          controller.hearingDate.value?.formattedDate ??
                              'শুনানির তারিখ',
                        ),
                        avatar: const Icon(HugeIcons.strokeRoundedCalendar01),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                controller.hearingDate.value ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            controller.hearingDate.value = picked;
                          }
                        },
                      ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('কেস যুক্ত করা হয়েছে')),
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
                        content: Text('কেস যুক্ত করতে ব্যর্থ হয়েছে'),
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
