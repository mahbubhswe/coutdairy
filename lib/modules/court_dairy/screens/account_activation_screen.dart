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
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  'একাউন্ট অ্যাক্টিভেশন',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Plans
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: _PlansSection(controller: controller),
              ),

              // Features List
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListView(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(12),
                    children: const [
                      FeatureRow(text: 'মোকদ্দমা তালিকা ও ব্যবস্থাপনা'),
                      FeatureRow(text: 'শুনানির তারিখ রিমাইন্ডার'),
                      FeatureRow(text: 'ক্লায়েন্ট ও প্রতিপক্ষ তথ্য সংরক্ষণ'),
                      FeatureRow(text: 'কোর্ট ফি ও খরচ হিসাব'),
                      FeatureRow(text: 'ডকুমেন্ট ও প্রমাণ সংযুক্তি'),
                      FeatureRow(text: 'দৈনিক অগ্রগতির রিপোর্ট'),
                      FeatureRow(text: 'ক্যালেন্ডার সিঙ্ক ও নোটিফিকেশন'),
                      FeatureRow(text: 'কেস সার্চ ও ফিল্টার অপশন'),
                      FeatureRow(text: 'অফলাইনে তথ্য ব্যবহারের সুবিধা'),
                      FeatureRow(text: 'নিরাপদ ক্লাউড ব্যাকআপ'),
                      FeatureRow(text: 'বহু-ব্যবহারকারী পারমিশন নিয়ন্ত্রণ'),
                      FeatureRow(text: 'টাস্ক ও রিমাইন্ডার ম্যানেজার'),
                      FeatureRow(text: 'কেস আপডেট শেয়ারিং'),
                      FeatureRow(text: 'ডেটা এক্সপোর্ট ও প্রিন্টিং'),
                      FeatureRow(text: 'ক্লায়েন্ট পেমেন্ট ট্র্যাকিং'),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlansSection extends StatelessWidget {
  const _PlansSection({required this.controller});
  final AccountActivationController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final monthly = controller.monthlyCharge;
    if (monthly <= 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          'কনফিগ লোড হয়নি। অনুগ্রহ করে পরে চেষ্টা করুন।',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }
    final sixTotal = (monthly * 6 * 0.90).toDouble();
    final twelveTotal = (monthly * 12 * 0.75).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;
        final cards = [
          _PlanCard(
            title: '৬ মাস',
            subtitle: '১০% ডিসকাউন্ট',
            highlight: false,
            monthly: monthly,
            months: 6,
            total: sixTotal,
            onPressed: () => controller.activateForMonths(months: 6),
          ),
          _PlanCard(
            title: '১২ মাস',
            subtitle: '২৫% ডিসকাউন্ট',
            highlight: true,
            monthly: monthly,
            months: 12,
            total: twelveTotal,
            onPressed: () => controller.activateForMonths(months: 12),
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 14),
              Expanded(child: cards[1]),
            ],
          );
        }
        return Column(
          children: [
            cards[0],
            const SizedBox(height: 12),
            cards[1],
          ],
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool highlight;
  final int monthly;
  final int months;
  final double total;
  final VoidCallback onPressed;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.highlight,
    required this.monthly,
    required this.months,
    required this.total,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final txt = cs.onSurface;
    final subTxt = cs.onSurfaceVariant;
    String currency(double v) =>
        '৳${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 0)}';
    String _bn(String s) {
      const m = {
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
      };
      return s.split('').map((c) => m[c] ?? c).join();
    }

    final perMonth = monthly.toDouble();

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: txt,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _bn(currency(total)),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: txt,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(_bn('মোট ${months} মাস'),
                      style:
                          theme.textTheme.bodyMedium?.copyWith(color: subTxt)),
                  const Spacer(),
                  Text(_bn('প্রতি মাসে ${currency(perMonth)}'),
                      style:
                          theme.textTheme.bodySmall?.copyWith(color: subTxt)),
                ],
              ),
              const SizedBox(height: 6),
              Builder(builder: (context) {
                final double original = perMonth * months;
                final double discount =
                    (original - total).clamp(0, double.infinity);
                final String percent = original > 0
                    ? (discount / original * 100).round().toString()
                    : '0';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _bn('${months} × ${currency(perMonth)} = ${currency(original)}'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _bn('ডিসকাউন্ট (${percent}%): -${currency(discount)}'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _bn('ডিসকাউন্টের পর: ${currency(total)}'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onPressed,
                  child: Text(_bn('${months} মাসের জন্য অ্যাক্টিভ করুন'),
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.deepOrangeAccent],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FeatureRow extends StatelessWidget {
  final String text;

  const FeatureRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 14, color: cs.tertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 1.4,
                    color: cs.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
