import 'package:app_gore_callao/config/theme/app_radii.dart';
import 'package:app_gore_callao/config/theme/app_spacing.dart';
import 'package:app_gore_callao/config/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme() => _buildTheme(
    brightness: Brightness.light,
    appColors: AppThemeColors.light,
  );

  static ThemeData darkTheme() =>
      _buildTheme(brightness: Brightness.dark, appColors: AppThemeColors.dark);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppThemeColors appColors,
  }) {
    final ColorScheme baseScheme = ColorScheme.fromSeed(
      seedColor: appColors.brandPrimary,
      brightness: brightness,
    );

    final ColorScheme colorScheme = baseScheme.copyWith(
      primary: appColors.brandPrimary,
      secondary: appColors.brandAccent,
      surface: appColors.surfacePrimary,
      onSurface: appColors.textPrimary,
      error: appColors.danger,
      outline: appColors.borderSubtle,
    );

    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Montserrat',
      scaffoldBackgroundColor: appColors.pageBackground,
      canvasColor: appColors.pageBackground,
      dividerColor: appColors.borderSubtle,
      splashFactory: InkRipple.splashFactory,
      extensions: <ThemeExtension<dynamic>>[appColors],
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Montserrat',
          color: appColors.textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: appColors.surfacePrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: appColors.surfacePrimary),
      listTileTheme: ListTileThemeData(
        iconColor: appColors.brandPrimary,
        textColor: appColors.textPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: appColors.surfacePrimary,
        indicatorColor: appColors.brandPrimarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          final bool selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? appColors.brandPrimary : appColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? appColors.brandPrimary : appColors.textSecondary,
          );
        }),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appColors.brandPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appColors.textPrimary,
          side: BorderSide(color: appColors.borderSubtle),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.xLargeRadius),
          padding: AppSpacing.symmetric(
            vertical: AppSpacing.s14,
            horizontal: AppSpacing.s16,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: appColors.brandPrimary,
          foregroundColor: appColors.onBrand,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.xLargeRadius),
          padding: AppSpacing.symmetric(
            vertical: AppSpacing.s14,
            horizontal: AppSpacing.s16,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.brandPrimary,
          foregroundColor: appColors.onBrand,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
          elevation: isDark ? 0 : 6,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.inputBackground,
        labelStyle: TextStyle(color: appColors.textSecondary),
        hintStyle: TextStyle(color: appColors.textMuted),
        errorMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: AppRadii.cardRadius,
          borderSide: BorderSide(color: appColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.cardRadius,
          borderSide: BorderSide(color: appColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.cardRadius,
          borderSide: BorderSide(color: appColors.brandPrimary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.cardRadius,
          borderSide: BorderSide(color: appColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.cardRadius,
          borderSide: BorderSide(color: appColors.danger, width: 1.4),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.brandPrimary;
          }
          return appColors.transparent;
        }),
        side: BorderSide(color: appColors.borderSubtle),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.brandPrimary;
          }
          return appColors.textMuted;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: appColors.brandPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: appColors.surfaceSecondary,
        contentTextStyle: TextStyle(color: appColors.textPrimary),
      ),
    );
  }
}
