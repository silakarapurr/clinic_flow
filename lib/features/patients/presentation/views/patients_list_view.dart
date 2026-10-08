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
    showDialog(
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
      appBar: AppBar(
        title: Text(AppStrings.patients, style: AppTypography.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: IconButton.filled(
              onPressed: _openCreatePatient,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
              tooltip: AppStrings.newPatient,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: AppTextField(
              hint: AppStrings.searchPatient,
              controller: _searchController,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
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
                      return AppCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PatientDetailView(patient: patient),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                patient.fullName.isNotEmpty
                                    ? patient.fullName[0].toUpperCase()
                                    : 'H',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient.fullName,
                                    style: AppTypography.titleMedium
                                        .copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    patient.phone,
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.slateMuted,
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
