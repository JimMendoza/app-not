import 'package:app_gore_callao/config/theme/app_theme_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle bold16Primary(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: context.appColors.brandPrimary,
      );

  static TextStyle medium14Primary(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: context.appColors.brandPrimary,
      );

  static TextStyle regular13Secondary(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 13,
        color: context.appColors.textSecondary,
      );

  static TextStyle regular14Secondary(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 14,
        color: context.appColors.textSecondary,
      );

  static TextStyle regular16Accent(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: context.appColors.brandAccent,
      );

  static TextStyle medium20Accent(BuildContext context) =>
      GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: context.appColors.brandAccent,
      );
}
