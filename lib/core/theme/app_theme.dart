import 'package:flutter/material.dart';
import 'color_constants.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData getTheme({
    required Color accentColor,
    required bool isDarkMode,
  }) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      primary: accentColor,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      surface: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayPrice,
        headlineMedium: AppTextStyles.heading,
        bodyLarge: AppTextStyles.body,
        labelMedium: AppTextStyles.caption,
      ),
    );
  }
}
