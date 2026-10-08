import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/metric_card.dart';
import '../widgets/today_appointment_card.dart';

class DashboardView extends StatelessWidget {
  final VoidCallback? onNewAppointmentTap;

  const DashboardView({super.key, this.onNewAppointmentTap});

  @override
  Widget build(BuildContext context) {
    final todayFormatted =
        DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.dashboard, style: AppTypography.titleLarge),
            Text(
              todayFormatted,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.slateLight,
              ),
            ),
          ],
        ),
        actions: [
          if (onNewAppointmentTap != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: IconButton.filled(
                onPressed: onNewAppointmentTap,
                icon: const Icon(Icons.add, size: 20),
                tooltip: AppStrings.newAppointment,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingIndicator(message: 'Veriler güncelleniyor...');
          }

          if (state is DashboardError) {
            return ErrorStateView(
              message: state.message,
              onRetry: () => context.read<DashboardCubit>().loadDashboard(),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Statistics Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                          crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.6,
                          children: [
                            MetricCard(
                              label: AppStrings.todayAppointments,
                              count: state.totalCount,
                              icon: Icons.calendar_month_outlined,
                              color: AppColors.primary,
                              backgroundColor: AppColors.primaryLight,
                            ),
                            MetricCard(
                              label: AppStrings.pendingAppointments,
                              count: state.pendingCount,
                              icon: Icons.hourglass_empty_rounded,
                              color: AppColors.statusScheduled,
                              backgroundColor: AppColors.statusScheduledBg,
                            ),
                            MetricCard(
                              label: AppStrings.completedAppointments,
                              count: state.completedCount + state.arrivedCount,
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.statusCompleted,
                              backgroundColor: AppColors.statusCompletedBg,
                            ),
                            MetricCard(
                              label: AppStrings.cancelledAppointments,
                              count: state.cancelledCount + state.noShowCount,
                              icon: Icons.cancel_outlined,
                              color: AppColors.statusCancelled,
                              backgroundColor: AppColors.statusCancelledBg,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.upcomingAppointments,
                          style: AppTypography.titleMedium,
                        ),
                        Text(
                          '${state.todayAppointments.length} randevu',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Appointments List or Empty State
                    if (state.todayAppointments.isEmpty)
                      EmptyStateView(
                        title: AppStrings.noAppointmentsToday,
                        description:
                            'Yeni bir randevu planlamak için "+" butonuna dokunabilirsiniz.',
                        icon: Icons.event_available_outlined,
                        actionText: AppStrings.newAppointment,
                        onAction: onNewAppointmentTap,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.todayAppointments.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final appointment = state.todayAppointments[index];
                          return TodayAppointmentCard(
                            appointment: appointment,
                            onStatusChanged: (newStatus) {
                              context.read<DashboardCubit>().updateStatus(
                                    appointment.id,
                                    newStatus,
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

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
