import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

/// Reusable production button for ClinicFlow.
/// Avoids duplicate styled buttons across screens.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, borderSide) = switch (variant) {
      AppButtonVariant.primary => (
          AppColors.primary,
          AppColors.textOnPrimary,
          BorderSide.none
        ),
      AppButtonVariant.secondary => (
          AppColors.secondary,
          AppColors.textOnPrimary,
          BorderSide.none
        ),
      AppButtonVariant.outline => (
          Colors.transparent,
          AppColors.slateDark,
          const BorderSide(color: AppColors.border, width: 1.2)
        ),
      AppButtonVariant.danger => (
          AppColors.error,
          AppColors.textOnPrimary,
          BorderSide.none
        ),
    };

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: AppColors.slateLight.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fgColor),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLarge.copyWith(color: fgColor),
                  ),
                ],
              ),
      ),
    );
  }
}
