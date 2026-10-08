import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../appointments/domain/models/appointment.dart';
import '../../../appointments/domain/repositories/appointments_repository.dart';
import '../../domain/models/patient.dart';

class PatientDetailView extends StatefulWidget {
  final Patient patient;

  const PatientDetailView({super.key, required this.patient});

  @override
  State<PatientDetailView> createState() => _PatientDetailViewState();
}

class _PatientDetailViewState extends State<PatientDetailView> {
  late Future<List<Appointment>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = sl<AppointmentsRepository>().getAppointmentsForPatient(widget.patient.id);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.patientDetail),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Header Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      widget.patient.fullName.isNotEmpty
                          ? widget.patient.fullName[0].toUpperCase()
                          : 'H',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.patient.fullName,
                    style: AppTypography.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: AppColors.slateLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.patient.phone,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.slateLight,
                        ),
                      ),
                    ],
                  ),
                  if (widget.patient.birthDate != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Doğum Tarihi: ${dateFormat.format(widget.patient.birthDate!)}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Clinical notes (KVKK safe)
            if (widget.patient.notes != null && widget.patient.notes!.isNotEmpty) ...[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: AppColors.primaryTint,
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Klinik & Dikkat Notları',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.patient.notes!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.slateDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Appointment History
            const Text(AppStrings.patientHistory, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            FutureBuilder<List<Appointment>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: LoadingIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return ErrorStateView(
                    message: 'Geçmiş randevular yüklenemedi.',
                    onRetry: () => setState(_loadHistory),
                  );
                }

                final history = snapshot.data ?? [];
                if (history.isEmpty) {
                  return const AppCard(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(
                      child: Text(
                        'Bu hastaya ait geçmiş randevu kaydı bulunmuyor.',
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateFormat.format(item.startTime),
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppStatusBadge(status: item.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${item.serviceName} • ${item.doctorName}',
                            style: AppTypography.bodySmall,
                          ),
                          if (item.clinicalNote != null &&
                              item.clinicalNote!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: const BoxDecoration(
                                color: AppColors.borderSubtle,
                                borderRadius: AppRadius.roundedSm,
                              ),
                              child: Text(
                                'Seans Notu: ${item.clinicalNote}',
                                style: AppTypography.bodySmall.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
