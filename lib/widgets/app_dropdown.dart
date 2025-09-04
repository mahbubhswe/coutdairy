import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../local_library/text_from_field_wraper.dart';

class AppDropdown extends StatelessWidget {
  final String? value;
  final String label;
  final String hintText;
  final List<String> items;
  final IconData prefixIcon;
  final ValueChanged<String?> onChanged;

  const AppDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.hintText,
    required this.items,
    required this.prefixIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormFieldWrapper(
      borderFocusedColor: AppColors.fixedPrimary,
      prefix: Icon(prefixIcon),
      formField: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          hintText: hintText,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
