import 'package:app_not/config/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

enum AppStateTone { brand, accent, success, warning, danger, neutral }

@immutable
class AppStateStyle {
  final Color background;
  final Color foreground;
  final Color border;

  const AppStateStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

abstract final class AppStateStyles {
  static AppStateStyle resolve(BuildContext context, AppStateTone tone) {
    final appColors = context.appColors;

    switch (tone) {
      case AppStateTone.brand:
        return AppStateStyle(
          background: appColors.brandPrimarySoft,
          foreground: appColors.brandPrimary,
          border: appColors.brandPrimary.withValues(alpha: 0.35),
        );
      case AppStateTone.accent:
        return AppStateStyle(
          background: appColors.brandAccentSoft,
          foreground: appColors.brandAccent,
          border: appColors.brandAccent.withValues(alpha: 0.35),
        );
      case AppStateTone.success:
        return AppStateStyle(
          background: appColors.successSoft,
          foreground: appColors.success,
          border: appColors.success.withValues(alpha: 0.35),
        );
      case AppStateTone.warning:
        return AppStateStyle(
          background: appColors.warningSoft,
          foreground: appColors.warning,
          border: appColors.warning.withValues(alpha: 0.35),
        );
      case AppStateTone.danger:
        return AppStateStyle(
          background: appColors.dangerSoft,
          foreground: appColors.danger,
          border: appColors.danger.withValues(alpha: 0.35),
        );
      case AppStateTone.neutral:
        return AppStateStyle(
          background: appColors.surfaceSecondary,
          foreground: appColors.textSecondary,
          border: appColors.borderSubtle,
        );
    }
  }
}

