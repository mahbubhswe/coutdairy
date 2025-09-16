import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../themes/theme_controller.dart';

class AccountsCard extends StatelessWidget {
  AccountsCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.gradientColors,
    this.iconBackgroundColor,
    this.iconColor,
    this.width,
  });

  final String title;
  final double amount;
  final IconData icon;
  final List<Color>? gradientColors;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final double? width;

  final themeController = Get.find<ThemeController>();

  static const List<Color> _defaultGradientDark = [
    Color(0xFF0F172A),
    Color(0xFF1E293B),
  ];

  static const List<Color> _defaultGradientLight = [
    Color(0xFF93C5FD),
    Color(0xFF60A5FA),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeController.isDarkMode;
    final cardWidth = width ?? (MediaQuery.of(context).size.width * 0.3);
    final colors = gradientColors ??
        (isDarkMode ? _defaultGradientDark : _defaultGradientLight);
    final Color foregroundColor = iconColor ?? Colors.white;
    final Color badgeColor = iconBackgroundColor ??
        Colors.white.withOpacity(isDarkMode ? 0.14 : 0.24);
    final numberFormat = NumberFormat.currency(
      locale: 'bn_BD',
      symbol: '',
      decimalDigits: 0,
    );

    return SizedBox(
      width: cardWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(isDarkMode ? 0.04 : 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(isDarkMode ? 0.45 : 0.25),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: foregroundColor,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              TweenAnimationBuilder<int>(
                tween: IntTween(
                  begin: 0,
                  end: amount.floor(),
                ),
                duration: const Duration(milliseconds: 900),
                builder: (context, value, child) {
                  return Text(
                    numberFormat.format(value).trim(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
