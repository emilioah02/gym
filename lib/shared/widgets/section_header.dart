import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/typography.dart';

/// Section header with title and optional action button
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;
  final bool showDivider;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.actionIcon,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.headlineSmallDark,
              ),
              if (actionText != null || actionIcon != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (actionText != null)
                        Text(
                          actionText!,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      if (actionIcon != null) ...[
                        const SizedBox(width: AppConstants.spacingXS),
                        Icon(
                          actionIcon,
                          color: AppColors.primary,
                          size: AppConstants.iconS,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            color: AppColors.glassBorder,
            height: 1,
          ),
      ],
    );
  }
}
