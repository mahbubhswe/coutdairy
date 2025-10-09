import 'package:flutter/material.dart';
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
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.surface, colors.primaryContainer.withValues(alpha: 0.75)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
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

  String _formatAmount(num amount) {
    final bool hasFraction = amount is double && amount % 1 != 0;
    final value = hasFraction
        ? amount.toStringAsFixed(2)
        : amount.round().toString();
    final parts = value.split('.');
    final integerPart = parts.first;
    final buffer = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      buffer.write(integerPart[i]);
      final remaining = integerPart.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    if (parts.length > 1) {
      final fraction = parts[1];
      if (fraction != '00') {
        buffer.write('.$fraction');
      }
    }

    return 'BDT ${buffer.toString()}';
  }

  String _toBanglaDigits(String value) {
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final activationCharge = controller.activationCharge;
    final validityDays = controller.activationValidity;
    final payableActivationCharge = controller.payableActivationCharge;
    final hasDiscount = controller.hasDiscount;
    final discountPercentage = controller.discountPercentage;
    final discountLabel = discountPercentage % 1 == 0
        ? discountPercentage.toStringAsFixed(0)
        : discountPercentage.toStringAsFixed(2);

    String planTitle;
    String feeLabel;
    String durationSummary;

    if (validityDays >= 365) {
      planTitle = 'Annual activation package';
      feeLabel = 'Annual fee';
      durationSummary =
          'One-time payment for a one-year subscription.';
    } else if (validityDays >= 30) {
      planTitle = 'Monthly activation package';
      feeLabel = 'Monthly fee';
      durationSummary =
          'One-time payment for a one-month subscription.';
    } else if (validityDays > 0) {
      planTitle = 'Activation package';
      feeLabel = 'Subscription fee';
      durationSummary =
          'One-time payment for a ${validityDays.toString()}-day subscription.';
    } else {
      planTitle = 'Activation package';
      feeLabel = 'Subscription fee';
      durationSummary = 'One-time payment for the subscription.';
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
                'Activation charge is not configured. Please contact support for assistance.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          planTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),

        // Discount badge and content using a stack layout
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
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
                  if (hasDiscount)
                    Text(
                      _formatAmount(activationCharge),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    _formatAmount(payableActivationCharge),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_toBanglaDigits(discountLabel)}% discount price',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    durationSummary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Discount badge (top right)
              if (hasDiscount)
                Positioned(
                  right: -6,
                  top: -12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_toBanglaDigits(discountLabel)}% OFF',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _FeaturePoint(
              text: 'Your account will activate automatically right after payment.',
            ),
            SizedBox(height: 10),
            _FeaturePoint(
              text: 'Priority assistance from the professional support team.',
            ),
            SizedBox(height: 10),
            _FeaturePoint(text: 'Store your chamber data securely.'),
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
              'Activate now',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturePoint extends StatelessWidget {
  const _FeaturePoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
