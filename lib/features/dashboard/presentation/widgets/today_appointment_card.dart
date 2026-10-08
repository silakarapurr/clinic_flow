import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/appointment_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../../appointments/domain/models/appointment.dart';

class TodayAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final ValueChanged<AppointmentStatus> onStatusChanged;
  final VoidCallback? onTap;

  const TodayAppointmentCard({
    super.key,
    required this.appointment,
    required this.onStatusChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final timeString =
        '${timeFormat.format(appointment.startTime)} - ${timeFormat.format(appointment.endTime)}';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.slateLight,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    timeString,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.slateDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AppStatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            appointment.patientName,
            style: AppTypography.titleMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 14,
                color: AppColors.slateMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${appointment.serviceName} • ${appointment.doctorName}',
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<AppointmentStatus>(
                onSelected: onStatusChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedMd,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Durum Değiştir',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: AppointmentStatus.arrived,
                    child: Text(AppointmentStatus.arrived.label),
                  ),
                  PopupMenuItem(
                    value: AppointmentStatus.completed,
                    child: Text(AppointmentStatus.completed.label),
                  ),
                  PopupMenuItem(
                    value: AppointmentStatus.noShow,
                    child: Text(AppointmentStatus.noShow.label),
                  ),
                  PopupMenuItem(
                    value: AppointmentStatus.cancelled,
                    child: Text(
                      AppointmentStatus.cancelled.label,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
