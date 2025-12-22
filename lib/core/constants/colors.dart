import 'package:flutter/material.dart';

/// Mexican Bulking Color Palette
/// Primary: Yellow (#FFCC00) - Energy, power, motivation
/// Background: Black (#000000) - Bold, gym aesthetic
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFFFCC00);
  static const Color primaryDark = Color(0xFFE6B800);
  static const Color primaryLight = Color(0xFFFFD633);

  // Background Colors
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Glass Effect Colors
  static const Color glassDark = Color(0x33FFFFFF);
  static const Color glassLight = Color(0x33000000);
  static const Color glassBorder = Color(0x66FFFFFF);
  static const Color glassBorderLight = Color(0x33000000);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xB3FFFFFF);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0x99000000);

  // Accent Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFFFCC00),
    Color(0xFFFFD633),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF000000),
  ];

  // Shadow Colors
  static const Color shadowDark = Color(0x40000000);
  static const Color shadowLight = Color(0x20000000);
  static const Color glowPrimary = Color(0x40FFCC00);
}
