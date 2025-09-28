import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/app_footer.dart';
import '../controllers/account_activation_controller.dart';

class AccountActivationScreen extends StatelessWidget {
  AccountActivationScreen({super.key});

  final controller = Get.put(AccountActivationController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: cs.surface,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ActivationPlanCard(controller: controller),
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

class _ActivationPlanCard extends StatelessWidget {
  const _ActivationPlanCard({required this.controller});
  final AccountActivationController controller;

  String _formatAmount(int amount) {
    final value = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }
    return '৳ ${_toBanglaDigits(buffer.toString())}';
  }

  String _toBanglaDigits(String value) {
    const englishToBangla = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
      ',': ',',
    };

    return value
        .split('')
        .map((char) => englishToBangla[char] ?? char)
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final activationCharge = controller.activationCharge;
    final validityDays = controller.activationValidity;
    final baseCharge = controller.baseActivationCharge;
    final baseValidity = controller.baseActivationValidity;

    String planTitle;
    String feeLabel;
    String durationSummary;
    String accessDescription;
    String calculationSummary = '';

    if (validityDays >= 365) {
      planTitle = 'বার্ষিক অ্যাক্টিভেশন প্যাকেজ';
      feeLabel = 'বার্ষিক ফি';
      durationSummary = 'এক বছর মেয়াদী সাবস্ক্রিপশনের জন্য এককালীন পেমেন্ট।';
      accessDescription = 'পুরো বছরের';
      if (baseCharge > 0 && baseValidity > 0 &&
          (baseValidity != validityDays || baseCharge != activationCharge)) {
        calculationSummary =
            'ডাটাবেসে নির্ধারিত ${_toBanglaDigits(baseValidity.toString())} দিনের ${_formatAmount(baseCharge)} ফি অনুসারে এক বছরের চার্জ নির্ণয় করা হয়েছে।';
      }
    } else if (validityDays >= 30) {
      planTitle = 'মাসিক অ্যাক্টিভেশন প্যাকেজ';
      feeLabel = 'মাসিক ফি';
      durationSummary = 'এক মাস মেয়াদি সাবস্ক্রিপশনের জন্য এককালীন পেমেন্ট।';
      accessDescription = 'পুরো মাসের';
    } else if (validityDays > 0) {
      planTitle = 'অ্যাক্টিভেশন প্যাকেজ';
      feeLabel = 'সাবস্ক্রিপশন ফি';
      durationSummary =
          '${_toBanglaDigits(validityDays.toString())} দিনের সাবস্ক্রিপশনের জন্য এককালীন পেমেন্ট।';
      accessDescription =
          '${_toBanglaDigits(validityDays.toString())} দিনের সীমিত সময়ের';
    } else {
      planTitle = 'অ্যাক্টিভেশন প্যাকেজ';
      feeLabel = 'সাবস্ক্রিপশন ফি';
      durationSummary = 'সাবস্ক্রিপশনের জন্য এককালীন পেমেন্ট।';
      accessDescription = 'সীমিত সময়ের';
    }

    if (activationCharge <= 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'অ্যাক্টিভেশন চার্জ কনফিগার করা হয়নি। সহায়তার জন্য সাপোর্টে যোগাযোগ করুন।',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.12),
            cs.primaryContainer.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: cs.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'চেম্বারের জন্য $accessDescription অ্যাক্সেস আনলক করুন এবং সব ফিচার সীমাহীনভাবে ব্যবহার করুন। পেমেন্ট সম্পূর্ণ নিরাপদ ও ডাটাবেসে সংরক্ষিত হারে সম্পন্ন হবে।',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.primary.withOpacity(0.24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feeLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatAmount(activationCharge),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  durationSummary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                if (calculationSummary.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    calculationSummary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _FeaturePoint(text: 'অ্যাপের সব প্রিমিয়াম সুবিধা তৎক্ষণাৎ চালু হবে।'),
              SizedBox(height: 10),
              _FeaturePoint(text: 'প্রফেশনাল সাপোর্ট টিম থেকে অগ্রাধিকার সহায়তা।'),
              SizedBox(height: 10),
              _FeaturePoint(text: 'চেম্বারের ডাটা ও তথ্য নিরাপদে সংরক্ষণ।'),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.activatePlan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                elevation: 0,
              ),
              child: const Text(
                'এখনই পেমেন্ট করে অ্যাক্টিভ করুন',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePoint extends StatelessWidget {
  const _FeaturePoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: cs.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
