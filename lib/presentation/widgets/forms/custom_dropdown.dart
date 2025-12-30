import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String? label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const CustomDropdown({
    super.key,
    this.value,
    this.label,
    this.hint,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceVariant,
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
    );
  }
}

class CustomDropdownSimple<T> extends StatelessWidget {
  final T? value;
  final String? label;
  final String? hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const CustomDropdownSimple({
    super.key,
    this.value,
    this.label,
    this.hint,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<T>(
      value: value,
      label: label,
      hint: hint,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      prefixIcon: prefixIcon,
      enabled: enabled,
    );
  }
}