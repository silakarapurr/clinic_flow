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

    final initial = appointment.patientName.isNotEmpty
        ? appointment.patientName[0].toUpperCase()
        : 'H';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.roundedLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: AppRadius.roundedSm,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeString,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              AppStatusBadge(status: appointment.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  initial,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          size: 13,
                          color: AppColors.slateLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${appointment.serviceName} • ${appointment.doctorName}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.slateLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 13,
                    color: AppColors.slateMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appointment.patientPhone,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<AppointmentStatus>(
                onSelected: onStatusChanged,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedMd,
                ),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Durum',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.slateDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.slateDark,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: AppointmentStatus.scheduled,
                    child: Text(AppointmentStatus.scheduled.label),
                  ),
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
