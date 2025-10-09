import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/court_case.dart';
import '../screens/case_detail_screen.dart';

class CaseTile extends StatelessWidget {
  const CaseTile({
    super.key,
    required this.caseItem,
    this.showUnderSection = true,
  });

  final CourtCase caseItem;
  final bool showUnderSection;

  String _initials(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return '';
    final parts = cleaned.split(RegExp(r'\s+'));
    final firstChar = parts.first.isNotEmpty ? parts.first[0] : '';
    return firstChar.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final tileBackground = theme.scaffoldBackgroundColor;
    final dividerColor = (colorScheme.outlineVariant ?? colorScheme.outline)
        .withOpacity(isDark ? 0.32 : 0.16);
    final subtitleColor = colorScheme.onSurfaceVariant;
    final leadingBackground = colorScheme.secondaryContainer;
    final leadingTextColor = colorScheme.onSecondaryContainer;
    final trailingColor = colorScheme.onSurfaceVariant;

    final lastOrder = caseItem.courtLastOrder;
    final String subtitle = (lastOrder != null && lastOrder.trim().isNotEmpty)
        ? lastOrder
        : caseItem.courtName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => CaseDetailScreen(caseItem)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: tileBackground, border: Border()),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: leadingBackground,
                child: Text(
                  _initials(caseItem.caseTitle),
                  style: TextStyle(
                    color: leadingTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseItem.caseTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Case No: ${caseItem.caseNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child:
                          (showUnderSection &&
                              caseItem.courtName.trim().isNotEmpty)
                          ? Padding(
                              key: const ValueKey('court_name_visible'),
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Court: ${caseItem.courtName.trim()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: subtitleColor,
                                ),
                              ),
                            )
                          : const SizedBox(key: ValueKey('court_name_hidden')),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: trailingColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
