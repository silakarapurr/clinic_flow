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

    final initial = widget.patient.fullName.isNotEmpty
        ? widget.patient.fullName[0].toUpperCase()
        : 'H';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.patientDetail,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Header Card
            AppCard(
              borderRadius: AppRadius.roundedXl,
              boxShadow: AppShadows.cardElevated,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      initial,
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.patient.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 15,
                        color: AppColors.slateLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.patient.phone,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.slateLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (widget.patient.birthDate != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.borderSubtle,
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Text(
                        'Doğum Tarihi: ${dateFormat.format(widget.patient.birthDate!)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Clinical notes (KVKK safe)
            if (widget.patient.notes != null && widget.patient.notes!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.statusScheduledBg,
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(
                    color: AppColors.statusScheduled.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.statusScheduled,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Klinik & Dikkat Notları',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.statusScheduled,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.patient.notes!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.slateDark,
                              height: 1.4,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.patientHistory,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
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
