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
              padding: const EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                          spacing: 10,
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

                            Text(
                              'সংখ্যা নির্বাচন করুন',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Obx(() {
                              final min = controller.minSms;
                              final max = controller.maxSms;
                              final step = controller.step;
                              final divisions = ((max - min) / step).round();
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
                                  Text.rich(
                                    TextSpan(
                                      text: 'আপনি ',
                                      children: [
                                        TextSpan(
                                          text: controller.formattedSmsCount,
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(
                                          text:
                                              ' টি এসএমএস নির্বাচন করেছেন,\nযার মূল্য ',
                                        ),
                                        TextSpan(
                                          text: controller.formattedTotalPrice,
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(text: ' টাকা।'),
                                      ],
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurface,
                                      height: 1.45,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
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
