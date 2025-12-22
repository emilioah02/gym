/// App-wide constants for Mexican Bulking
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Mexican Bulking';
  static const String appTagline = 'ESFUÉRZATE por progresar...';
  static const String appTaglineSecondary = 'no por llegar a la perfección';
  static const String appDescription =
      'Tu compañero de gimnasio definitivo con rutinas personalizadas para hombres y mujeres.';

  // Social Media
  static const String instagramUrl = 'https://www.instagram.com/mexicanbulking_gym/';
  static const String facebookUrl = 'https://www.facebook.com/p/Mexican-Bulking-61557725126140/';

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // Glass Effect
  static const double glassBlur = 10.0;
  static const double glassOpacity = 0.1;
  static const double glassBorderOpacity = 0.2;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button Heights
  static const double buttonHeightS = 40.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;

  // Input Heights
  static const double inputHeight = 56.0;

  // Card Dimensions
  static const double cardMinHeight = 120.0;
  static const double cardImageHeight = 200.0;

  // Parallax
  static const double parallaxFactor = 0.5;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String routinesCollection = 'routines';
  static const String machinesCollection = 'machines';
  static const String exercisesCollection = 'exercises';
}
