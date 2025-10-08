import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/party/screens/add_party_screen.dart';
import 'app_config.dart';

void showNewUserDialog() {
  Future.delayed(const Duration(seconds: 5), () {
    final context = Get.context;
    if (context == null) return;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pricingMessage = _buildPricingMessage();

    Get.dialog(
      Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.15),
                cs.tertiary.withOpacity(0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: cs.surface,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.18),
                        cs.secondary.withOpacity(0.24),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: cs.primary,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Congratulations!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You have received a 30-day free trial.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                if (pricingMessage != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: cs.primaryContainer.withOpacity(0.18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome, color: cs.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            pricingMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Get.back();
                      Get.to(
                        () => const AddPartyScreen(),
                        fullscreenDialog: true,
                      );
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Get started',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(foregroundColor: cs.primary),
                  child: const Text('Remind me later'),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  });
}

String? _buildPricingMessage() {
  final config = AppConfigService.config;
  if (config == null) return null;

  final charge = config.activationCharge;

  final amount = _formatCurrency(charge);

  return 'After the trial, the monthly subscription price is only $amount.';
}

String _formatCurrency(num amount) {
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

  return buffer.toString();
}

String _toBanglaDigits(String value) {
  return value;
}
