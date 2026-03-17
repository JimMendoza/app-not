import 'package:app_gore_callao/config/config.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomTextFormField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    final border = OutlineInputBorder(
      borderSide: BorderSide(color: appColors.borderSubtle),
      borderRadius: AppRadii.inputRadius,
    );

    return Container(
      decoration: BoxDecoration(
        color: appColors.inputBackground,
        borderRadius: AppRadii.inputRadius,
        boxShadow: AppShadows.card(context),
      ),
      child: TextFormField(
        onChanged: onChanged,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16, color: appColors.textPrimary),
        decoration: InputDecoration(
          floatingLabelStyle: TextStyle(
            color: appColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: border.copyWith(
            borderSide: BorderSide(color: appColors.danger),
          ),
          focusedErrorBorder: border.copyWith(
            borderSide: BorderSide(color: appColors.danger),
          ),
          isDense: true,
          label: label != null ? Text(label!) : null,
          hintText: hint,
          errorText: errorMessage,
          contentPadding: AppSpacing.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s14,
          ),
          focusColor: colors.primary,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
