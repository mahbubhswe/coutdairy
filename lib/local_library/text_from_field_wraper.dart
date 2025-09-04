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
    this.shadowSize = 0.5,
    this.borderRadius = 12.0,
    this.borderThickness = 1.0,
    this.borderColor,
    this.borderFocusedThickness = 3.0,
    this.borderFocusedColor,
  });

  final Widget formField;
  final TextFormFieldPosition position;
  final Widget? prefix;
  final Widget? suffix;
  final Color? shadowColor;
  final double shadowSize;
  final double borderRadius;
  final double borderThickness;
  final Color? borderColor;
  final double borderFocusedThickness;
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

  bool get hasTopBorder =>
      hasFocus ||
      [
        TextFormFieldPosition.alone,
        TextFormFieldPosition.top,
        TextFormFieldPosition.topLeft,
        TextFormFieldPosition.topRight,
        TextFormFieldPosition.left,
        TextFormFieldPosition.right,
      ].contains(widget.position);

  bool get hasLeftBorder =>
      hasFocus ||
      [
        TextFormFieldPosition.alone,
        TextFormFieldPosition.top,
        TextFormFieldPosition.bottom,
        TextFormFieldPosition.topLeft,
        TextFormFieldPosition.left,
        TextFormFieldPosition.center,
        TextFormFieldPosition.bottomLeft,
      ].contains(widget.position);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final Color shadowColor = widget.shadowColor ?? theme.shadowColor;
    final Color borderColorUnFocused = widget.borderColor ?? cs.outlineVariant;
    final Color borderColorFocused = widget.borderFocusedColor ?? cs.primary;
    final Color fillColor = cs.surface;
    Color borderColor = hasFocus ? borderColorFocused : borderColorUnFocused;
    double borderWidth =
        hasFocus ? widget.borderFocusedThickness : widget.borderThickness;
    double cornerRadius = widget.borderRadius;
    double innerRadius = cornerRadius - borderWidth;

    return Focus(
      focusNode: focusNode,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          hasLeftBorder ? borderWidth : 0.0,
          hasTopBorder ? borderWidth : 0.0,
          borderWidth,
          borderWidth,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.only(
            topLeft:
                hasTopLeftRadius ? Radius.circular(cornerRadius) : Radius.zero,
            topRight:
                hasTopRightRadius ? Radius.circular(cornerRadius) : Radius.zero,
            bottomLeft: hasBottomLeftRadius
                ? Radius.circular(cornerRadius)
                : Radius.zero,
            bottomRight: hasBottomRightRadius
                ? Radius.circular(cornerRadius)
                : Radius.zero,
          ),
          boxShadow: [
            if (widget.shadowSize != 0.0)
              BoxShadow(
                color: shadowColor.withOpacity(0.5),
                blurRadius: widget.shadowSize,
                offset: Offset(widget.shadowSize, widget.shadowSize),
              ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.only(
              topLeft:
                  hasTopLeftRadius ? Radius.circular(innerRadius) : Radius.zero,
              topRight: hasTopRightRadius
                  ? Radius.circular(innerRadius)
                  : Radius.zero,
              bottomLeft: hasBottomLeftRadius
                  ? Radius.circular(innerRadius)
                  : Radius.zero,
              bottomRight: hasBottomRightRadius
                  ? Radius.circular(innerRadius)
                  : Radius.zero,
            ),
          ),
          child: Row(
            children: [
              if (widget.prefix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: widget.prefix!,
                ),
              Expanded(child: widget.formField),
              if (widget.suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: widget.suffix!,
                )
            ],
          ),
        ),
      ),
    );
  }
}
