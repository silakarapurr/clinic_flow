import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/appointment_status.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/metric_card.dart';
import '../widgets/today_appointment_card.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback? onNewAppointmentTap;

  const DashboardView({super.key, this.onNewAppointmentTap});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  AppointmentStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final todayFormatted =
        DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.dashboard,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              todayFormatted,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.slateLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.onNewAppointmentTap != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: InkWell(
                onTap: widget.onNewAppointmentTap,
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
                      Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Randevu',
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
            final filteredAppointments = _selectedFilter == null
                ? state.todayAppointments
                : state.todayAppointments
                    .where((a) => a.status == _selectedFilter)
                    .toList();

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
                          childAspectRatio: 1.48,
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
                              icon: Icons.hourglass_top_rounded,
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

                    const SizedBox(height: AppSpacing.xl),

                    // Section Title & Filter Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.upcomingAppointments,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: AppRadius.roundedFull,
                          ),
                          child: Text(
                            '${filteredAppointments.length} randevu',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Status Filter Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Tümü', null),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Bekleyen',
                            AppointmentStatus.scheduled,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Geldi',
                            AppointmentStatus.arrived,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Tamamlandı',
                            AppointmentStatus.completed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Appointments List or Empty State
                    if (filteredAppointments.isEmpty)
                      EmptyStateView(
                        title: _selectedFilter == null
                            ? AppStrings.noAppointmentsToday
                            : '${_selectedFilter!.label} randevu bulunmuyor',
                        description:
                            'Yeni bir randevu planlamak için yukarıdaki butona dokunabilirsiniz.',
                        icon: Icons.event_available_outlined,
                        actionText: AppStrings.newAppointment,
                        onAction: widget.onNewAppointmentTap,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredAppointments.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final appointment = filteredAppointments[index];
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

  Widget _buildFilterChip(String label, AppointmentStatus? status) {
    final isSelected = _selectedFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryLight,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : AppColors.border.withValues(alpha: 0.8),
        width: 1.0,
      ),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
      ),
      onSelected: (_) {
        setState(() {
          _selectedFilter = status;
        });
      },
    );
  }
}
