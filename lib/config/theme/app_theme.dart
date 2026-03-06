import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() {
    const seedColor = Colors.deepPurple;

    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: seedColor,
      fontFamily: 'Montserrat',
      listTileTheme: const ListTileThemeData(iconColor: seedColor),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Montserrat'),
        displayMedium: TextStyle(fontFamily: 'Montserrat'),
        displaySmall: TextStyle(fontFamily: 'Montserrat'),
        headlineLarge: TextStyle(fontFamily: 'Montserrat'),
        headlineMedium: TextStyle(fontFamily: 'Montserrat'),
        headlineSmall: TextStyle(fontFamily: 'Montserrat'),
        titleLarge: TextStyle(fontFamily: 'Montserrat'),
        titleMedium: TextStyle(fontFamily: 'Montserrat'),
        titleSmall: TextStyle(fontFamily: 'Montserrat'),
        bodyLarge: TextStyle(fontFamily: 'Montserrat'),
        bodyMedium: TextStyle(fontFamily: 'Montserrat'),
        bodySmall: TextStyle(fontFamily: 'Montserrat'),
        labelLarge: TextStyle(fontFamily: 'Montserrat'),
        labelMedium: TextStyle(fontFamily: 'Montserrat'),
        labelSmall: TextStyle(fontFamily: 'Montserrat'),
      ),
    );
  }
}
