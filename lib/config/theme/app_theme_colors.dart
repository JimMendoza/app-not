import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color brandPrimary;
  final Color brandAccent;
  final Color onBrand;
  final Color pageBackground;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color borderSubtle;
  final Color shadowColor;
  final Color headerGradientStart;
  final Color headerGradientEnd;
  final Color headerOnColor;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color inputBackground;
  final Color drawerSelection;
  final Color success;
  final Color warning;
  final Color danger;
  final Color avatarBackground;

  const AppThemeColors({
    required this.brandPrimary,
    required this.brandAccent,
    required this.onBrand,
    required this.pageBackground,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderSubtle,
    required this.shadowColor,
    required this.headerGradientStart,
    required this.headerGradientEnd,
    required this.headerOnColor,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.inputBackground,
    required this.drawerSelection,
    required this.success,
    required this.warning,
    required this.danger,
    required this.avatarBackground,
  });

  static const AppThemeColors light = AppThemeColors(
    brandPrimary: Color(0xFF99569E),
    brandAccent: Color(0xFFEF7F7E),
    onBrand: Colors.white,
    pageBackground: Color(0xFFF6F4F8),
    surfacePrimary: Colors.white,
    surfaceSecondary: Color(0xFFF3F4F6),
    surfaceMuted: Color(0xFFF9F7FB),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF4B5563),
    textMuted: Color(0xFF6B7280),
    borderSubtle: Color(0xFFD7D2DE),
    shadowColor: Color(0x1A0F172A),
    headerGradientStart: Color(0xFF910C87),
    headerGradientEnd: Color(0xFF6D0D67),
    headerOnColor: Colors.white,
    badgeBackground: Color(0xFFFFEB3B),
    badgeForeground: Color(0xFF7A1575),
    inputBackground: Colors.white,
    drawerSelection: Color(0xFFF5ECF5),
    success: Color(0xFF15803D),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFB91C1C),
    avatarBackground: Color(0xFFFFFFFF),
  );

  static const AppThemeColors dark = AppThemeColors(
    brandPrimary: Color(0xFFD08AD4),
    brandAccent: Color(0xFFF3A39E),
    onBrand: Color(0xFFF9FAFB),
    pageBackground: Color(0xFF111116),
    surfacePrimary: Color(0xFF1A1B22),
    surfaceSecondary: Color(0xFF252733),
    surfaceMuted: Color(0xFF221D27),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFFD1D5DB),
    textMuted: Color(0xFF9CA3AF),
    borderSubtle: Color(0xFF3A3E4C),
    shadowColor: Color(0x66000000),
    headerGradientStart: Color(0xFF5E145C),
    headerGradientEnd: Color(0xFF391338),
    headerOnColor: Color(0xFFF9FAFB),
    badgeBackground: Color(0xFFFACC15),
    badgeForeground: Color(0xFF3F0B3C),
    inputBackground: Color(0xFF22242D),
    drawerSelection: Color(0xFF312334),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    avatarBackground: Color(0xFF2A2C36),
  );

  @override
  AppThemeColors copyWith({
    Color? brandPrimary,
    Color? brandAccent,
    Color? onBrand,
    Color? pageBackground,
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? borderSubtle,
    Color? shadowColor,
    Color? headerGradientStart,
    Color? headerGradientEnd,
    Color? headerOnColor,
    Color? badgeBackground,
    Color? badgeForeground,
    Color? inputBackground,
    Color? drawerSelection,
    Color? success,
    Color? warning,
    Color? danger,
    Color? avatarBackground,
  }) {
    return AppThemeColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandAccent: brandAccent ?? this.brandAccent,
      onBrand: onBrand ?? this.onBrand,
      pageBackground: pageBackground ?? this.pageBackground,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      shadowColor: shadowColor ?? this.shadowColor,
      headerGradientStart: headerGradientStart ?? this.headerGradientStart,
      headerGradientEnd: headerGradientEnd ?? this.headerGradientEnd,
      headerOnColor: headerOnColor ?? this.headerOnColor,
      badgeBackground: badgeBackground ?? this.badgeBackground,
      badgeForeground: badgeForeground ?? this.badgeForeground,
      inputBackground: inputBackground ?? this.inputBackground,
      drawerSelection: drawerSelection ?? this.drawerSelection,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      avatarBackground: avatarBackground ?? this.avatarBackground,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary: Color.lerp(
        surfaceSecondary,
        other.surfaceSecondary,
        t,
      )!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      headerGradientStart: Color.lerp(
        headerGradientStart,
        other.headerGradientStart,
        t,
      )!,
      headerGradientEnd: Color.lerp(
        headerGradientEnd,
        other.headerGradientEnd,
        t,
      )!,
      headerOnColor: Color.lerp(headerOnColor, other.headerOnColor, t)!,
      badgeBackground: Color.lerp(badgeBackground, other.badgeBackground, t)!,
      badgeForeground: Color.lerp(badgeForeground, other.badgeForeground, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      drawerSelection: Color.lerp(drawerSelection, other.drawerSelection, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      avatarBackground: Color.lerp(
        avatarBackground,
        other.avatarBackground,
        t,
      )!,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
}

extension AppThemeColorsHelpers on AppThemeColors {
  Color get transparent => surfacePrimary.withValues(alpha: 0);

  Color get brandPrimarySoft => brandPrimary.withValues(alpha: 0.12);

  Color get brandAccentSoft => brandAccent.withValues(alpha: 0.15);

  Color get successSoft => success.withValues(alpha: 0.15);

  Color get warningSoft => warning.withValues(alpha: 0.15);

  Color get dangerSoft => danger.withValues(alpha: 0.15);

  Color get headerOnColorMuted => headerOnColor.withValues(alpha: 0.82);

  Color get shadowSoft => shadowColor.withValues(alpha: 0.12);

  Color get shadowMedium => shadowColor.withValues(alpha: 0.18);
}
