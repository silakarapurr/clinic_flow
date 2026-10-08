import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/doctors_cubit.dart';
import '../cubit/doctors_state.dart';

class DoctorsListView extends StatefulWidget {
  const DoctorsListView({super.key});

  @override
  State<DoctorsListView> createState() => _DoctorsListViewState();
}

class _DoctorsListViewState extends State<DoctorsListView> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorsCubit>().loadDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.doctors, style: AppTypography.titleLarge),
      ),
      body: BlocBuilder<DoctorsCubit, DoctorsState>(
        builder: (context, state) {
          if (state is DoctorsLoading) {
            return const LoadingIndicator();
          }

          if (state is DoctorsError) {
            return ErrorStateView(
              message: state.message,
              onRetry: () => context.read<DoctorsCubit>().loadDoctors(),
            );
          }

          if (state is DoctorsLoaded) {
            return ListView.separated(
              padding: AppSpacing.pagePadding,
              itemCount: state.doctors.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final doctor = state.doctors[index];

                return AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primaryLight,
                            child: const Icon(
                              Icons.person_pin_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      doctor.fullName,
                                      style: AppTypography.titleMedium
                                          .copyWith(fontSize: 16),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: doctor.isActive
                                            ? AppColors.statusCompletedBg
                                            : AppColors.borderSubtle,
                                        borderRadius: AppRadius.roundedFull,
                                      ),
                                      child: Text(
                                        doctor.isActive
                                            ? AppStrings.activeStatus
                                            : AppStrings.inactiveStatus,
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: doctor.isActive
                                              ? AppColors.statusCompleted
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  doctor.specialty,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 15,
                            color: AppColors.slateLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            doctor.phone,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 15,
                            color: AppColors.slateLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Çalışma Saatleri: ${doctor.startHour} - ${doctor.endHour} (${doctor.slotDurationMinutes} dk seans)',
                            style: AppTypography.bodySmall,
                          ),
                        ],
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
    );
  }
}
