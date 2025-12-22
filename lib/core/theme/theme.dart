import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/app_constants.dart';

/// Mexican Bulking Theme Configuration
/// Dark-first theme with glassmorphism aesthetic
class AppTheme {
  AppTheme._();

  // ============ DARK THEME (Primary) ============
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.backgroundDark,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: AppColors.textPrimaryDark,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLargeDark,
        displayMedium: AppTypography.displayMediumDark,
        displaySmall: AppTypography.displaySmallDark,
        headlineLarge: AppTypography.headlineLargeDark,
        headlineMedium: AppTypography.headlineMediumDark,
        headlineSmall: AppTypography.headlineSmallDark,
        titleLarge: AppTypography.titleLargeDark,
        titleMedium: AppTypography.titleMediumDark,
        titleSmall: AppTypography.titleSmallDark,
        bodyLarge: AppTypography.bodyLargeDark,
        bodyMedium: AppTypography.bodyMediumDark,
        bodySmall: AppTypography.bodySmallDark,
        labelLarge: AppTypography.labelLargeDark,
        labelMedium: AppTypography.labelMediumDark,
        labelSmall: AppTypography.labelSmallDark,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          minimumSize: const Size(double.infinity, AppConstants.buttonHeightM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.backgroundDark,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          minimumSize: const Size(double.infinity, AppConstants.buttonHeightM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.glassDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: AppConstants.iconM,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: AppTypography.bodyMediumDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.glassDark;
        }),
      ),
    );
  }

  // ============ LIGHT THEME ============
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.textPrimaryDark,
        secondary: AppColors.primary,
        onSecondary: AppColors.backgroundDark,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: AppColors.textPrimaryDark,
      ),

      scaffoldBackgroundColor: AppColors.backgroundLight,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          minimumSize: const Size(double.infinity, AppConstants.buttonHeightM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.glassBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.glassBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.glassLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          side: const BorderSide(color: AppColors.glassBorderLight),
        ),
      ),
    );
  }
}
