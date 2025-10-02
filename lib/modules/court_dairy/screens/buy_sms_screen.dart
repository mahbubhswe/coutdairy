import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
    final pricePerSms = controller.smsPrice;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SMS কেনার প্যাকেজ'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'এসএমএস প্যাকেজ',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'আপনার প্রয়োজন অনুযায়ী এসএমএস সংখ্যা নির্ধারণ করুন। পরিমাণ অনুযায়ী মূল্য স্বয়ংক্রিয়ভাবে গণনা হবে।',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.sms_outlined,
                                    color: cs.onPrimaryContainer,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'এসএমএস ক্রয় ক্যালকুলেটর',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'সংখ্যা সামঞ্জস্য করে সঙ্গে সঙ্গে আপডেট হওয়া মূল্য দেখুন।',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _metricTile(
                                    context,
                                    icon: Icons.chat_bubble_outline,
                                    label: 'নির্বাচিত এসএমএস',
                                    value: controller.formattedSmsCount,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _metricTile(
                                    context,
                                    icon: Icons.payments_outlined,
                                    label: 'আনুমানিক মূল্য',
                                    value: '${controller.formattedTotalPrice}৳',
                                    valueColor: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'সংখ্যা নির্বাচন করুন',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final min = controller.minSms;
                              final max = controller.maxSms;
                              final step = controller.step;
                              final divisions = ((max - min) / step).round();
                              final mid = min + ((max - min) ~/ 2);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 6,
                                      activeTrackColor: cs.primary,
                                      inactiveTrackColor: cs.primary
                                          .withOpacity(0.2),
                                      thumbColor: cs.primary,
                                      overlayColor: cs.primary.withOpacity(
                                        0.12,
                                      ),
                                      valueIndicatorColor: cs.primary,
                                      valueIndicatorTextStyle: theme
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: cs.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    child: Slider(
                                      value: controller.smsCount.value
                                          .toDouble(),
                                      min: min.toDouble(),
                                      max: max.toDouble(),
                                      divisions: divisions,
                                      label: controller.formattedSmsCount,
                                      onChanged: (value) {
                                        final stepped =
                                            min +
                                            ((value - min) / step).round() *
                                                step;
                                        final clamped = stepped
                                            .clamp(min, max)
                                            .toInt();
                                        controller.smsCount.value = clamped;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$min',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                      Text(
                                        '$mid',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                      Text(
                                        '$max',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'সর্বনিম্ন $min • সর্বোচ্চ $max • প্রতি ধাপ $step',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 24),
                            Text(
                              'দ্রুত নির্বাচন',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Obx(() {
                                final selectedValue = controller.smsCount.value;
                                final presets = [32, 64, 96, 160, 224, 320]
                                    .where(
                                      (value) =>
                                          value >= controller.minSms &&
                                          value <= controller.maxSms,
                                    )
                                    .toList();
                                return Row(
                                  children: presets
                                      .map(
                                        (value) => _quickSelectChip(
                                          context,
                                          value: value,
                                          selectedValue: selectedValue,
                                          onTap: () =>
                                              controller.smsCount.value = value,
                                        ),
                                      )
                                      .toList(),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'এখনই পেমেন্ট করুন',
                      onPressed: () => controller.buySms(),
                    ),
                    const SizedBox(height: 24),
                    const AppFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _metricTile(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
  Color? valueColor,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: cs.primary),
      ),
      const SizedBox(height: 12),
      Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      const SizedBox(height: 6),
      Text(
        value,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: valueColor ?? cs.onSurface,
        ),
      ),
    ],
  );
}

Widget _quickSelectChip(
  BuildContext context, {
  required int value,
  required int selectedValue,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final isSelected = value == selectedValue;
  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Text(
          '$value এসএমএস',
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
