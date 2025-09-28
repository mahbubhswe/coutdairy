import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/app_footer.dart';
import '../controllers/account_activation_controller.dart';

/// Redesigned activation screen
/// – cleaner layout
/// – better responsiveness (breakpoints at 640 / 960)
/// – improved contrast/accessibility
/// – feature grid instead of a fixed-height list
/// – subtle animations and tactile feedback
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final double maxContent = w >= 960 ? 880 : 720;
              final double sidePad = w > maxContent
                  ? (w - maxContent) / 2
                  : (w >= 640 ? 24 : 16);

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(sidePad, 24, sidePad, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderSection(controller: controller),
                    const SizedBox(height: 28),
                    _PlansSection(controller: controller),
                    const SizedBox(height: 28),
                    _FeatureShowcase(controller: controller),
                    const SizedBox(height: 24),
                    const _SupportCard(),
                    const SizedBox(height: 32),
                    const AppFooter(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.controller});
  final AccountActivationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final monthly = controller.monthlyCharge;
    final priceLabel = monthly > 0
        ? 'BDT ${monthly.toStringAsFixed(0)} / month'
        : 'Pricing coming soon';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            Color.alphaBlend(cs.primary.withOpacity(0.2), cs.primaryContainer),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.16),
            blurRadius: 42,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.onPrimary.withOpacity(0.18)),
            ),
            child: Text(
              'Account inactive',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onPrimary,
                letterSpacing: 0.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Activate your chamber today',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            // Fixed brand spelling and removed mojibake char
            'Unlock every smart tool in Court Diary and keep matters, parties, and finance perfectly in sync.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onPrimary.withOpacity(0.9),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _HeaderTag('Case timeline & reminders'),
              _HeaderTag('Bulk client SMS'),
              _HeaderTag('Finance dashboard'),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_outlined, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  priceLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: cs.onPrimary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.onPrimary.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: cs.onPrimary,
          fontWeight: FontWeight.w600,
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
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Activation pricing is not configured yet. Please contact support for assistance.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final sixTotal = (monthly * 6 * 0.90).toDouble();
    final twelveTotal = (monthly * 12 * 0.75).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose the plan that fits',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Save more with longer commitments and unlock every premium workflow.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 640;
            final cards = [
              _PlanCard(
                title: '6 month focus',
                subtitle: '10% savings',
                highlight: false,
                monthly: monthly,
                months: 6,
                total: sixTotal,
                onPressed: () => controller.activateForMonths(months: 6),
              ),
              _PlanCard(
                title: '12 month pro',
                subtitle: 'Best value (25% off)',
                highlight: true,
                monthly: monthly,
                months: 12,
                total: twelveTotal,
                onPressed: () => controller.activateForMonths(months: 12),
              ),
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[1]),
                ],
              );
            }
            return Column(
              children: [
                cards[0],
                const SizedBox(height: 16),
                cards[1],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PlanCard extends StatefulWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.highlight,
    required this.monthly,
    required this.months,
    required this.total,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final bool highlight;
  final int monthly;
  final int months;
  final double total;
  final VoidCallback onPressed;

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hovering = false;

  String _formatCurrency(double value) => 'BDT ${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final cardBackground = widget.highlight ? null : cs.surface;
    final titleColor = widget.highlight ? cs.onPrimary : cs.onSurface;
    final subtitleColor = widget.highlight
        ? cs.onPrimary.withOpacity(0.88)
        : cs.onSurfaceVariant;
    final borderColor = widget.highlight ? Colors.transparent : cs.outlineVariant;
    final gradient = widget.highlight
        ? LinearGradient(
            colors: [cs.primary, cs.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    final perMonth = widget.monthly.toDouble();
    final original = perMonth * widget.months;
    final discount = (original - widget.total).clamp(0, double.infinity);
    final percent = original > 0 ? (discount / original * 100).round() : 0;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: widget.highlight ? cs.onPrimary : cs.primary,
      foregroundColor: widget.highlight ? cs.primary : cs.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: _hovering ? 2 : 0,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: _hovering
          ? Matrix4.translationValues(0.0, -2.0, 0.0)
          : Matrix4.identity(),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        decoration: BoxDecoration(
          gradient: gradient,
          color: cardBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.08 : 0.05),
              blurRadius: _hovering ? 34 : 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.highlight)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.onPrimary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Recommended',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(widget.total),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.months} months access',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'BDT ${perMonth.toStringAsFixed(0)} / month',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You save BDT ${discount.toStringAsFixed(0)} (${percent}%) versus monthly billing.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: subtitleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  widget.onPressed();
                },
                child: Text(
                  'Activate for ${widget.months} month${widget.months > 1 ? "s" : ""}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureShowcase extends StatelessWidget {
  const _FeatureShowcase({required this.controller});
  final AccountActivationController controller;

  static const _features = [
    'Unlimited case creation and updates',
    'Share instant hearing reminders',
    'Integrated party and finance tracking',
    'Smart calendar with overdue insights',
    'Secure cloud backup for every document',
    'Bulk SMS tools for client updates',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything you unlock',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Designed for busy chambers – stay organised, proactive, and stress free.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 640;
              final colCount = isWide ? 2 : 1;
              return _FeatureGrid(features: _features, columns: colCount);
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.features, this.columns = 2});
  final List<String> features;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 16,
        childAspectRatio: 5.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) {
        final text = features[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, size: 16, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  height: 1.35,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.support_agent, color: cs.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a tailored plan?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Our team can help you migrate data, onboard your associates, and craft a plan that suits your chamber.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Keep these selectable so users can copy easily without extra packages
                SelectableText(
                  'Email support@courtdiary.com or call +880 1234-567890',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
