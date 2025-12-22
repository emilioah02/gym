import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/typography.dart';
import 'glass_card.dart';

/// Tile widget for displaying routine information
class RoutineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final int exerciseCount;
  final String duration;
  final VoidCallback? onTap;
  final bool isCompact;

  const RoutineTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.exerciseCount,
    required this.duration,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactTile(context);
    }
    return _buildFullTile(context);
  }

  Widget _buildFullTile(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusL),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primaryDark.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppConstants.radiusL),
                    ),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    ),
                  )
                : _buildPlaceholderImage(),
          ),
          // Content section
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLargeDark,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  subtitle,
                  style: AppTypography.bodyMediumDark,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingM),
                Row(
                  children: [
                    _buildInfoChip(Icons.fitness_center, '$exerciseCount ejercicios'),
                    const SizedBox(width: AppConstants.spacingM),
                    _buildInfoChip(Icons.schedule, duration),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTile(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primaryDark.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMediumDark,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  '$exerciseCount ejercicios • $duration',
                  style: AppTypography.bodySmallDark,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.fitness_center,
        size: 48,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: AppConstants.spacingXS),
        Text(text, style: AppTypography.labelSmallDark),
      ],
    );
  }
}
