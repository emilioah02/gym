import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/typography.dart';

/// Glassmorphism input field with blur effect
class InputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool enabled;
  final int maxLines;
  final FocusNode? focusNode;

  const InputField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: TextFormField(
              controller: widget.controller,
              obscureText: _obscureText,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              onChanged: widget.onChanged,
              enabled: widget.enabled,
              maxLines: widget.maxLines,
              focusNode: widget.focusNode,
              style: AppTypography.bodyLarge.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, color: AppColors.textSecondaryDark)
                    : null,
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondaryDark,
                        ),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      )
                    : widget.suffix,
                filled: true,
                fillColor: isDark ? AppColors.glassDark : AppColors.glassLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.glassBorder : AppColors.glassBorderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.glassBorder : AppColors.glassBorderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
