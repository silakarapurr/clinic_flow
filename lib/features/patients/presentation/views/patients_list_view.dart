import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/patients_cubit.dart';
import '../cubit/patients_state.dart';
import 'create_patient_dialog.dart';
import 'patient_detail_view.dart';

class PatientsListView extends StatefulWidget {
  const PatientsListView({super.key});

  @override
  State<PatientsListView> createState() => _PatientsListViewState();
}

class _PatientsListViewState extends State<PatientsListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PatientsCubit>().loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreatePatient() {
    showDialog<void>(
      context: context,
      builder: (ctx) => CreatePatientDialog(
        onSave: (name, phone, birthDate, notes) {
          context.read<PatientsCubit>().createPatient(
                fullName: name,
                phone: phone,
                birthDate: birthDate,
                notes: notes,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: const Text(
          AppStrings.patients,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: InkWell(
              onTap: _openCreatePatient,
              borderRadius: AppRadius.roundedFull,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.roundedFull,
                  boxShadow: AppShadows.primaryGlow,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Yeni Hasta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Counter Header
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.8),
                  width: 0.8,
                ),
              ),
            ),
            child: AppTextField(
              hint: AppStrings.searchPatient,
              controller: _searchController,
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.slateLight,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        context.read<PatientsCubit>().loadPatients();
                      },
                    )
                  : null,
              onChanged: (val) {
                context.read<PatientsCubit>().loadPatients(query: val);
              },
            ),
          ),

          // Patients List
          Expanded(
            child: BlocConsumer<PatientsCubit, PatientsState>(
              listener: (context, state) {
                if (state is PatientCreatedSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.patientCreated),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is PatientsLoading) {
                  return const LoadingIndicator();
                }

                if (state is PatientsError) {
                  return ErrorStateView(
                    message: state.message,
                    onRetry: () => context.read<PatientsCubit>().loadPatients(),
                  );
                }

                if (state is PatientsLoaded) {
                  if (state.patients.isEmpty) {
                    return EmptyStateView(
                      title: AppStrings.noPatientsFound,
                      description: 'İlk hasta kaydını hemen oluşturabilirsiniz.',
                      icon: Icons.person_off_outlined,
                      actionText: AppStrings.newPatient,
                      onAction: _openCreatePatient,
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.pagePadding,
                    itemCount: state.patients.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final patient = state.patients[index];
                      final initial = patient.fullName.isNotEmpty
                          ? patient.fullName[0].toUpperCase()
                          : 'H';

                      return AppCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  PatientDetailView(patient: patient),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: AppRadius.roundedLg,
                        child: Row(
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          patient.fullName,
                                          style: AppTypography.titleMedium.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (patient.notes != null &&
                                          patient.notes!.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.statusScheduledBg,
                                            borderRadius: AppRadius.roundedFull,
                                          ),
                                          child: Text(
                                            'Not Var',
                                            style: AppTypography.labelSmall.copyWith(
                                              color: AppColors.statusScheduled,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone_outlined,
                                        size: 13,
                                        color: AppColors.slateLight,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        patient.phone,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.slateLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.borderSubtle,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: AppColors.slateMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
