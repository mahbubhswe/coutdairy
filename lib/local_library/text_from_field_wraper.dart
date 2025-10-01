import 'package:flutter/material.dart';

enum TextFormFieldPosition {
  alone,
  top,
  topLeft,
  topRight,
  bottom,
  bottomLeft,
  bottomRight,
  left,
  right,
  center,
}

class TextFormFieldWrapper extends StatefulWidget {
  const TextFormFieldWrapper({
    super.key,
    required this.formField,
    this.position = TextFormFieldPosition.alone,
    this.suffix,
    this.prefix,
    this.shadowColor,
    this.shadowSize = 0.15,
    this.borderRadius = 12.0,
    this.borderColor,
    this.borderFocusedColor,
  });

  final Widget formField;
  final TextFormFieldPosition position;
  final Widget? prefix;
  final Widget? suffix;
  final Color? shadowColor;
  final double shadowSize;
  final double borderRadius;
  final Color? borderColor;
  final Color? borderFocusedColor;

  @override
  TextFormFieldWrapperState createState() => TextFormFieldWrapperState();
}

class TextFormFieldWrapperState extends State<TextFormFieldWrapper> {
  bool hasFocus = false;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus && !hasFocus) {
        setState(() => hasFocus = true);
      } else if (!focusNode.hasFocus && hasFocus) {
        setState(() => hasFocus = false);
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  bool get hasTopLeftRadius => [
    TextFormFieldPosition.alone,
    TextFormFieldPosition.top,
    TextFormFieldPosition.topLeft,
    TextFormFieldPosition.left,
  ].contains(widget.position);

  bool get hasTopRightRadius => [
    TextFormFieldPosition.alone,
    TextFormFieldPosition.top,
    TextFormFieldPosition.topRight,
    TextFormFieldPosition.right,
  ].contains(widget.position);

  bool get hasBottomLeftRadius => [
    TextFormFieldPosition.alone,
    TextFormFieldPosition.bottom,
    TextFormFieldPosition.bottomLeft,
    TextFormFieldPosition.left,
  ].contains(widget.position);

  bool get hasBottomRightRadius => [
    TextFormFieldPosition.alone,
    TextFormFieldPosition.bottom,
    TextFormFieldPosition.bottomRight,
    TextFormFieldPosition.right,
  ].contains(widget.position);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final double radius = widget.borderRadius;
    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: hasTopLeftRadius ? Radius.circular(radius) : Radius.zero,
      topRight: hasTopRightRadius ? Radius.circular(radius) : Radius.zero,
      bottomLeft: hasBottomLeftRadius ? Radius.circular(radius) : Radius.zero,
      bottomRight: hasBottomRightRadius ? Radius.circular(radius) : Radius.zero,
    );

    final Color baseTint = widget.borderColor ?? cs.primary;
    final Color focusTint = widget.borderFocusedColor ?? baseTint;
    final Color baseOverlay = baseTint.withOpacity(isDark ? 0.18 : 0.06);
    final Color focusOverlay = focusTint.withOpacity(isDark ? 0.28 : 0.12);
    final Color containerColor = Color.alphaBlend(
      hasFocus ? focusOverlay : baseOverlay,
      cs.surface,
    );

    final double shadowScale = widget.shadowSize <= 0 ? 0 : widget.shadowSize;
    final List<BoxShadow> shadows = shadowScale == 0
        ? const []
        : [
            BoxShadow(
              color: (widget.shadowColor ?? Colors.black).withOpacity(
                isDark ? 0.3 : 0.1,
              ),
              blurRadius: 18 * shadowScale,
              offset: Offset(0, 6 * shadowScale),
            ),
            if (hasFocus)
              BoxShadow(
                color: cs.primary.withOpacity(isDark ? 0.26 : 0.12),
                blurRadius: 20 * shadowScale,
                offset: Offset(0, 8 * shadowScale),
              ),
          ];

    final ThemeData decorationTheme = theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );

    return Focus(
      focusNode: focusNode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: borderRadius,
          boxShadow: shadows,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.prefix != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: widget.prefix!,
                  ),
                Expanded(
                  child: Theme(data: decorationTheme, child: widget.formField),
                ),
                if (widget.suffix != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: widget.suffix!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
