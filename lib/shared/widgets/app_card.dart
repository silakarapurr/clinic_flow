import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Sleek iOS-style Card container with soft diffuse elevation and refined borders.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.roundedLg;

    final decoration = BoxDecoration(
      color: gradient == null ? (color ?? AppColors.surface) : null,
      gradient: gradient,
      borderRadius: radius,
      border: Border.all(
        color: borderColor ?? AppColors.border.withValues(alpha: 0.8),
        width: 1.0,
      ),
      boxShadow: boxShadow ?? AppShadows.card,
    );

    if (onTap != null) {
      return Container(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: padding ?? AppSpacing.cardPadding,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: decoration,
      child: child,
    );
  }
}

