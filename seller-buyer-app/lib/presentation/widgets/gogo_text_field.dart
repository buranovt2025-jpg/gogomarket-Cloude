import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class GogoTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? prefix;
  final Widget? prefixWidget;
  final Widget? suffix;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool filled;
  final FocusNode? focusNode;

  const GogoTextField({
    super.key,
    this.label,
    this.hint,
    this.prefix,
    this.prefixWidget,
    this.suffix,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.formatters,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.filled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'DM Sans', fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: filled,
        fillColor: AppColors.bgCard,
        prefixText: prefix,
        prefixStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: prefixWidget,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'DM Sans'),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'DM Sans'),
      ),
    );
  }
}
