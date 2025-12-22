import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';

/// Glassmorphism card widget with blur effect and border
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = AppConstants.radiusL,
    this.blur = AppConstants.glassBlur,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
              tileMode: TileMode.clamp,
            ),
            child: Container(
              padding: padding ?? const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: backgroundColor ??
                    (isDark ? AppColors.glassDark : AppColors.glassLight),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor ??
                      (isDark ? AppColors.glassBorder : AppColors.glassBorderLight),
                  width: 0.5,
                ),
                // Gradient overlay for extra depth
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.3),
                        ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
