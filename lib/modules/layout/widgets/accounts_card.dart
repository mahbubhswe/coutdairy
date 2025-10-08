import 'package:court_dairy/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountsCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;

  const AccountsCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final accent = isDark ? Colors.white : AppColors.fixedPrimary;
    final Color gradientStart = accent.withOpacity(isDark ? 0.28 : 0.18);
    final Color gradientEnd = accent.withOpacity(isDark ? 0.12 : 0.08);
    cs.outlineVariant.withOpacity(isDark ? 0.5 : 0.22);
    final numberFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: 0,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isDark ? 0.08 : 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : cs.onSurface,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: amount),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        numberFormatter.format(value).trim(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accent,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
