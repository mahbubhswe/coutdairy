import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final Function()? onPressed;
  final bool isLoading;
  // When true, button matches input field (surface) style
  final bool surfaceStyle;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.surfaceStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color accent = cs.secondary;
    final Color surfaceBase = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.26 : 0.12),
      cs.surface,
    );
    final Color surfaceActive = Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.34 : 0.18),
      cs.surface,
    );
    final Color disabledBase = Color.alphaBlend(
      cs.onSurface.withValues(alpha: isDark ? 0.24 : 0.08),
      cs.surface,
    );

    final Color backgroundColor = !isEnabled
        ? (surfaceStyle ? surfaceBase : disabledBase)
        : (surfaceStyle ? surfaceActive : accent);

    final Color textColor = surfaceStyle ? cs.onSurface : cs.onSecondary;
    final Color disabledText = cs.onSurfaceVariant;

    final List<BoxShadow> shadows = !isEnabled
        ? const []
        : [
            BoxShadow(
              color: accent.withValues(alpha: surfaceStyle ? 0.18 : 0.32),
              blurRadius: surfaceStyle ? 20 : 26,
              offset: Offset(0, surfaceStyle ? 8 : 12),
            ),
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          splashColor: accent.withValues(alpha: 0.12),
          highlightColor: accent.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: isLoading
                  ? CupertinoActivityIndicator(
                      color: isEnabled ? textColor : disabledText,
                    )
                  : Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: isEnabled ? textColor : disabledText,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
