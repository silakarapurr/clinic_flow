import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../models/appointment_status.dart';

/// Pill-shaped badge showing appointment status.
class AppStatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const AppStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: AppRadius.roundedFull,
        border: Border.all(
          color: status.color.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: status.color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: AppTypography.labelSmall.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
