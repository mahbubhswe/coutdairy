import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../local_library/text_from_field_wraper.dart';

class AppTypeAheadField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final List<String> suggestions;
  final TextFormFieldPosition textFormFieldPosition;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onFieldSubmitted;

  const AppTypeAheadField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.suggestions,
    this.textFormFieldPosition = TextFormFieldPosition.alone,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormFieldWrapper(
      borderFocusedColor: cs.primary,
      position: textFormFieldPosition,
      formField: TypeAheadField<String>(
        controller: controller,
        builder: (context, textController, focusNode) {
          return TextField(
            controller: textController,
            focusNode: focusNode,
            cursorColor: Theme.of(context).colorScheme.onSurface,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              labelText: label,
              prefixIcon: Icon(prefixIcon, color: cs.onSurfaceVariant),
            ),
            onChanged: onChanged,
            onTap: onTap,
            onSubmitted: onFieldSubmitted,
          );
        },
        suggestionsCallback: (pattern) {
          return suggestions
              .where((s) => s.toLowerCase().contains(pattern.toLowerCase()))
              .toList();
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSelected: (suggestion) {
          controller.text = suggestion;
        },
        // TypeAheadField (v5) is not a FormField; validation is handled
        // by parent form fields if needed.
      ),
    );
  }
}
