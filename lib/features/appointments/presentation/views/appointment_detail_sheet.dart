import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/appointment_status.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/models/appointment.dart';

class AppointmentDetailSheet extends StatefulWidget {
  final Appointment appointment;
  final void Function(AppointmentStatus status, String? note) onUpdate;

  const AppointmentDetailSheet({
    super.key,
    required this.appointment,
    required this.onUpdate,
  });

  @override
  State<AppointmentDetailSheet> createState() => _AppointmentDetailSheetState();
}

class _AppointmentDetailSheetState extends State<AppointmentDetailSheet> {
  late AppointmentStatus _selectedStatus;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.appointment.status;
    _noteController =
        TextEditingController(text: widget.appointment.clinicalNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onUpdate(
      _selectedStatus,
      _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm', 'tr_TR');
    final initial = widget.appointment.patientName.isNotEmpty
        ? widget.appointment.patientName[0].toUpperCase()
        : 'H';

    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.slateLight.withValues(alpha: 0.3),
                  borderRadius: AppRadius.roundedFull,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Randevu Detayı',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppStatusBadge(status: _selectedStatus),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Patient Card Summary
            AppCard(
              borderRadius: AppRadius.roundedLg,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
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
                              widget.appointment.patientName,
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 13,
                                  color: AppColors.slateLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.appointment.patientPhone,
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(widget.appointment.startTime),
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.medical_services_outlined,
                        size: 14,
                        color: AppColors.slateLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.appointment.serviceName} • ${widget.appointment.doctorName}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Status Selector
            Text(
              'Randevu Durumu',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppointmentStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(status.label),
                  selected: isSelected,
                  selectedColor: status.backgroundColor,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected ? status.color : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? status.color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12.5,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Clinical Note Editor
            AppTextField(
              label: AppStrings.clinicalNote,
              hint: 'Seans ve tedavi ile ilgili klinik notları yazın...',
              controller: _noteController,
              maxLines: 3,
            ),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              text: 'Değişiklikleri Kaydet',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
