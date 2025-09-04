import 'package:court_dairy/local_library/text_from_field_wraper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AppTextFromField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIconButton;
  final bool isPassword;
  final TextInputType keyboardType;
  final int isMaxLines;
  final TextFormFieldPosition textFormFieldPosition;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onFieldSubmitted;

  const AppTextFromField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIconButton,
    this.isPassword = false,
    this.isMaxLines = 1,
    this.keyboardType = TextInputType.text,
    this.textFormFieldPosition = TextFormFieldPosition.alone,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDecimalKeyboard = keyboardType == TextInputType.number;
    final effectiveKeyboardType = isDecimalKeyboard
        ? const TextInputType.numberWithOptions(decimal: true)
        : keyboardType;

    final inputFormatters = isDecimalKeyboard
        ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
        : null;

    final cs = Theme.of(context).colorScheme;
    return TextFormFieldWrapper(
      borderFocusedColor: cs.primary,
      formField: TextFormField(
        controller: controller,
        cursorColor: Theme.of(context).colorScheme.onSurface,
        keyboardType: effectiveKeyboardType,
        inputFormatters: inputFormatters,
        obscureText: isPassword,
        validator: validator,
        maxLines: isMaxLines,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onChanged,
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: cs.onSurfaceVariant),
          suffixIcon: suffixIconButton,
        ),
      ),
      position: textFormFieldPosition,
    );
  }
}
