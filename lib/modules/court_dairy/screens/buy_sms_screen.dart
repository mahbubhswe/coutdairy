import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_footer.dart';
import '../controllers/buy_sms_controller.dart';

class BuySmsView extends StatelessWidget {
  BuySmsView({super.key});

  final controller = Get.put(BuySmsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final appBarColor = theme.appBarTheme.backgroundColor ?? cs.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: const Text('SMS কেনার প্যাকেজ'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: cs.surface,
          foregroundColor: cs.onSurface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header summary card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SMS Package',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ডানে-বামে টেনে বা নিচের প্রিসেট থেকে SMS সংখ্যা নির্বাচন করুন',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'নির্বাচিত SMS',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Obx(
                                          () => Text(
                                            controller.formattedSmsCount,
                                            style: theme.textTheme.headlineSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'আনুমানিক মূল্য',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Obx(
                                          () => Text(
                                            '${controller.formattedTotalPrice}৳',
                                            style: theme.textTheme.headlineSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Preset chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [100, 250, 500, 1000, 2000]
                                .where((v) =>
                                    v >= controller.minSms &&
                                    v <= controller.maxSms)
                                .map((v) => Obx(() {
                                      final selected =
                                          controller.smsCount.value == v;
                                      return ChoiceChip(
                                        label: Text('$v SMS'),
                                        selected: selected,
                                        onSelected: (_) =>
                                            controller.smsCount.value = v,
                                        shape: StadiumBorder(
                                          side: BorderSide(
                                            color: selected
                                                ? Colors.transparent
                                                : appBarColor,
                                          ),
                                        ),
                                      );
                                    }))
                                .toList(),
                          ),

                          const SizedBox(height: 12),

                          // Picker card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Column(
                              children: [
                                Obx(
                                  () => NumberPicker(
                                    value: controller.smsCount.value,
                                    haptics: true,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: cs.primary,
                                        width: 2,
                                      ),
                                    ),
                                    minValue: controller.minSms,
                                    maxValue: controller.maxSms,
                                    step: controller.step,
                                    axis: Axis.horizontal,
                                    onChanged: (value) =>
                                        controller.smsCount.value = value,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'সর্বনিম্ন ${controller.minSms} • সর্বোচ্চ ${controller.maxSms} • স্টেপ ${controller.step}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Benefits
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'সুবিধাসমূহ',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _benefit(cs, 'দ্রুত ডেলিভারি ও নির্ভরযোগ্যতা'),
                                const SizedBox(height: 6),
                                _benefit(cs, 'বাংলা/ইংরেজি উভয় সাপোর্টেড'),
                                const SizedBox(height: 6),
                                _benefit(cs, 'রিয়েল-টাইম ব্যালেন্স আপডেট'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          AppButton(
                            label: 'এখনই পেমেন্ট করুন',
                            onPressed: () => controller.buySms(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: AppFooter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _benefit(ColorScheme cs, String text) {
  return Row(
    children: [
      Icon(Icons.check_circle, size: 18, color: cs.primary),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(color: cs.onSurface),
        ),
      ),
    ],
  );
}
