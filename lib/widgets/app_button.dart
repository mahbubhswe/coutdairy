import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';

class AppButton extends StatelessWidget {
  final String label;
  final Function()? onPressed;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final cs = Theme.of(context).colorScheme;

    return SimpleShadow(
      opacity: isEnabled ? 0.3 : 0, // shadow only if enabled
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isEnabled ? cs.primary : cs.outlineVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isLoading
                ? CupertinoActivityIndicator(color: cs.onPrimary)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
