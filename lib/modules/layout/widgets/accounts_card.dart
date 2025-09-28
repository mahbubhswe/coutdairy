import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardMetric {
  final String title;
  final double amount;
  final IconData icon;

  const DashboardMetric({
    required this.title,
    required this.amount,
    required this.icon,
  });
}

class DashboardMetricsGrid extends StatelessWidget {
  final List<DashboardMetric> metrics;

  const DashboardMetricsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 16.0;
    const spacing = 16.0;
    final width = MediaQuery.of(context).size.width;
    final availableWidth = width - (horizontalPadding * 2);
    final canShowTwoColumns = availableWidth >= 500;
    final cardWidth = canShowTwoColumns
        ? (availableWidth - spacing) / 2
        : availableWidth;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12,
      ),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: metrics
            .map(
              (metric) => AccountsCard(
                title: metric.title,
                amount: metric.amount,
                icon: metric.icon,
                cardWidth: cardWidth,
              ),
            )
            .toList(),
      ),
    );
  }
}

class AccountsCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final double cardWidth;

  const AccountsCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final numberFormatter = NumberFormat.currency(
      locale: 'bn_BD',
      symbol: '',
      decimalDigits: 0,
    );

    return SizedBox(
      width: cardWidth,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1D2331) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: accent.withOpacity(isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                color: accent,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: amount,
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  numberFormatter.format(value).trim(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
