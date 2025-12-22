import 'package:flutter/material.dart';
import 'colors.dart';

/// Mexican Bulking Typography System
/// Bold, impactful typography for gym aesthetic
class AppTypography {
  AppTypography._();

  // Font Family
  static const String fontFamily = 'Poppins';

  // Display Styles - For hero sections and large headers
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline Styles - For section headers
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title Styles - For cards and list items
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body Styles - For content text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label Styles - For buttons and small text
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Dark Theme Text Styles
  static TextStyle get displayLargeDark =>
      displayLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get displayMediumDark =>
      displayMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get displaySmallDark =>
      displaySmall.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get headlineLargeDark =>
      headlineLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get headlineMediumDark =>
      headlineMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get headlineSmallDark =>
      headlineSmall.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get titleLargeDark =>
      titleLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get titleMediumDark =>
      titleMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get titleSmallDark =>
      titleSmall.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get bodyLargeDark =>
      bodyLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get bodyMediumDark =>
      bodyMedium.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle get bodySmallDark =>
      bodySmall.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle get labelLargeDark =>
      labelLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get labelMediumDark =>
      labelMedium.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle get labelSmallDark =>
      labelSmall.copyWith(color: AppColors.textSecondaryDark);

  // Primary Accent Text Styles
  static TextStyle get displayLargePrimary =>
      displayLarge.copyWith(color: AppColors.primary);
  static TextStyle get headlineLargePrimary =>
      headlineLarge.copyWith(color: AppColors.primary);
  static TextStyle get titleLargePrimary =>
      titleLarge.copyWith(color: AppColors.primary);
}
