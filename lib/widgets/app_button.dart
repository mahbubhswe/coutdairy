import 'package:court_dairy/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';

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
    final cs = Theme.of(context).colorScheme;

    final Color bgEnabled = surfaceStyle ? cs.surface : AppColors.fixedPrimary;
    final Color fgEnabled = surfaceStyle ? cs.onSurface : cs.onSecondary;
    final Color bgDisabled = surfaceStyle
        ? cs.surface
        : cs.outlineVariant.withOpacity(0.6);
    final Color fgDisabled = cs.onSurfaceVariant;

    return SimpleShadow(
      opacity: isEnabled ? (surfaceStyle ? 0.15 : 0.3) : 0,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            // Choose surface vs brand background
            color: isEnabled ? bgEnabled : bgDisabled,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isLoading
                ? CupertinoActivityIndicator(
                    color: isEnabled ? fgEnabled : fgDisabled,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Match content color to chosen background color
                      color: isEnabled ? fgEnabled : fgDisabled,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
