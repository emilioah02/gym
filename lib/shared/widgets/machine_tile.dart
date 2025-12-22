import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/typography.dart';
import 'glass_card.dart';

/// Tile widget for displaying gym machine/exercise information
class MachineTile extends StatelessWidget {
  final String name;
  final String description;
  final int sets;
  final int reps;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isExpanded;

  const MachineTile({
    super.key,
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    this.imageUrl,
    this.onTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return _buildExpandedTile(context);
    }
    return _buildCompactTile(context);
  }

  Widget _buildCompactTile(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          // Machine image
          _buildImage(size: 56),
          const SizedBox(width: AppConstants.spacingM),
          // Machine info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMediumDark,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  description,
                  style: AppTypography.bodySmallDark,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          // Sets x Reps
          _buildSetsReps(),
        ],
      ),
    );
  }

  Widget _buildExpandedTile(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusL),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.backgroundDark.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: _buildImage(size: 80, showFull: true),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTypography.titleLargeDark,
                      ),
                    ),
                    _buildSetsReps(),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  description,
                  style: AppTypography.bodyMediumDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage({required double size, bool showFull = false}) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (showFull) {
        return CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) => _buildPlaceholder(size),
          errorWidget: (_, __, ___) => _buildPlaceholder(size),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildPlaceholder(size),
          errorWidget: (_, __, ___) => _buildPlaceholder(size),
        ),
      );
    }
    return _buildPlaceholder(size);
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primaryDark.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.fitness_center,
        color: AppColors.primary,
        size: size * 0.4,
      ),
    );
  }

  Widget _buildSetsReps() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$sets × $reps',
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
