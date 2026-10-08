import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';

/// Supported appointment lifecycle statuses.
enum AppointmentStatus {
  scheduled,
  arrived,
  completed,
  cancelled,
  noShow;

  static AppointmentStatus fromString(String value) {
    return switch (value.toLowerCase()) {
      'scheduled' || 'bekliyor' => AppointmentStatus.scheduled,
      'arrived' || 'geldi' => AppointmentStatus.arrived,
      'completed' || 'tamamlandı' => AppointmentStatus.completed,
      'cancelled' || 'iptal' => AppointmentStatus.cancelled,
      'noshow' || 'no_show' || 'gelmedi' => AppointmentStatus.noShow,
      _ => AppointmentStatus.scheduled,
    };
  }

  String get label => switch (this) {
        AppointmentStatus.scheduled => AppStrings.pendingAppointments,
        AppointmentStatus.arrived => AppStrings.arrivedAppointments,
        AppointmentStatus.completed => AppStrings.completedAppointments,
        AppointmentStatus.cancelled => AppStrings.cancelledAppointments,
        AppointmentStatus.noShow => AppStrings.noShowAppointments,
      };

  Color get color => switch (this) {
        AppointmentStatus.scheduled => AppColors.statusScheduled,
        AppointmentStatus.arrived => AppColors.statusArrived,
        AppointmentStatus.completed => AppColors.statusCompleted,
        AppointmentStatus.cancelled => AppColors.statusCancelled,
        AppointmentStatus.noShow => AppColors.statusNoShow,
      };

  Color get backgroundColor => switch (this) {
        AppointmentStatus.scheduled => AppColors.statusScheduledBg,
        AppointmentStatus.arrived => AppColors.statusArrivedBg,
        AppointmentStatus.completed => AppColors.statusCompletedBg,
        AppointmentStatus.cancelled => AppColors.statusCancelledBg,
        AppointmentStatus.noShow => AppColors.statusNoShowBg,
      };
}
