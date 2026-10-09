import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';
import '../../domain/models/appointment.dart';
import 'appointment_detail_sheet.dart';
import 'create_appointment_dialog.dart';

class AppointmentsCalendarView extends StatefulWidget {
  const AppointmentsCalendarView({super.key});

  @override
  State<AppointmentsCalendarView> createState() => _AppointmentsCalendarViewState();
}

class _AppointmentsCalendarViewState extends State<AppointmentsCalendarView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    unawaited(context.read<AppointmentsCubit>().loadAppointments(date: _selectedDate));
  }

  void _openCreateAppointment() {
    showDialog<void>(
      context: context,
      builder: (ctx) => CreateAppointmentDialog(
        initialDate: _selectedDate,
        onSave: ({
          required doctorId,
          required doctorName,
          required patientId,
          required patientName,
          required patientPhone,
          required serviceName,
          required startTime,
          required endTime,
          clinicalNote,
        }) {
          context.read<AppointmentsCubit>().createAppointment(
                doctorId: doctorId,
                doctorName: doctorName,
                patientId: patientId,
                patientName: patientName,
                patientPhone: patientPhone,
                serviceName: serviceName,
                startTime: startTime,
                endTime: endTime,
                clinicalNote: clinicalNote,
              );
        },
      ),
    );
  }

  void _openDetailSheet(Appointment appointment) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppointmentDetailSheet(
        appointment: appointment,
        onUpdate: (status, note) {
          context.read<AppointmentsCubit>().updateStatus(
                appointment.id,
                status,
                clinicalNote: note,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy', 'tr_TR');
    final timeFormat = DateFormat('HH:mm');

    // Calculate the start of the week for the selected date (Monday)
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: const Text(
          AppStrings.appointments,
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
              onTap: _openCreateAppointment,
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
      body: Column(
        children: [
          // Modern Calendar Header with Month & Week Strip
          Container(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.sm,
              bottom: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.8),
                  width: 0.8,
                ),
              ),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                // Month selector & Quick Today button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        final cubit = context.read<AppointmentsCubit>();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          locale: const Locale('tr', 'TR'),
                        );
                        if (picked != null && mounted) {
                          setState(() {
                            _selectedDate = picked;
                          });
                          unawaited(cubit.loadAppointments(date: picked));
                        }
                      },
                      borderRadius: AppRadius.roundedMd,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              monthFormat.format(_selectedDate).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Quick "Bugün" button
                        InkWell(
                          onTap: () {
                            final now = DateTime.now();
                            setState(() {
                              _selectedDate = now;
                            });
                            unawaited(
                              context.read<AppointmentsCubit>().loadAppointments(date: now),
                            );
                          },
                          borderRadius: AppRadius.roundedFull,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: AppRadius.roundedFull,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              'Bugün',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, size: 22),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                            });
                            unawaited(
                              context.read<AppointmentsCubit>().loadAppointments(date: _selectedDate),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, size: 22),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.add(const Duration(days: 7));
                            });
                            unawaited(
                              context.read<AppointmentsCubit>().loadAppointments(date: _selectedDate),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Interactive 7-Day Strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weekDays.map((date) {
                    final isSelected = date.year == _selectedDate.year &&
                        date.month == _selectedDate.month &&
                        date.day == _selectedDate.day;
                    final isToday = date.year == DateTime.now().year &&
                        date.month == DateTime.now().month &&
                        date.day == DateTime.now().day;

                    final dayName = DateFormat('E', 'tr_TR').format(date).toUpperCase();

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                            unawaited(
                              context.read<AppointmentsCubit>().loadAppointments(date: date),
                            );
                          },
                          borderRadius: AppRadius.roundedMd,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.primaryGradient : null,
                              color: isSelected
                                  ? null
                                  : (isToday ? AppColors.primaryTint : AppColors.surface),
                              borderRadius: AppRadius.roundedMd,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isToday
                                        ? AppColors.primary.withValues(alpha: 0.4)
                                        : AppColors.border.withValues(alpha: 0.8)),
                                width: 1.0,
                              ),
                              boxShadow: isSelected ? AppShadows.primaryGlow : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : AppColors.slateLight,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Appointments List
          Expanded(
            child: BlocConsumer<AppointmentsCubit, AppointmentsState>(
              listener: (context, state) {
                if (state is AppointmentCreatedSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.appointmentCreated),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is AppointmentsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AppointmentsLoading) {
                  return const LoadingIndicator();
                }

                if (state is AppointmentsError) {
                  return ErrorStateView(
                    message: state.message,
                    onRetry: () => context
                        .read<AppointmentsCubit>()
                        .loadAppointments(date: _selectedDate),
                  );
                }

                if (state is AppointmentsLoaded) {
                  if (state.appointments.isEmpty) {
                    final dateLabel = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_selectedDate);
                    return EmptyStateView(
                      title: '$dateLabel için randevu yok',
                      description:
                          'Bu tarihe yeni bir randevu eklemek için yukarıdaki "+ Randevu" butonuna dokunabilirsiniz.',
                      icon: Icons.event_note_outlined,
                      actionText: AppStrings.newAppointment,
                      onAction: _openCreateAppointment,
                    );
                  }

                  return ListView.separated(
                    padding: AppSpacing.pagePadding,
                    itemCount: state.appointments.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = state.appointments[index];
                      final timeStr =
                          '${timeFormat.format(item.startTime)} - ${timeFormat.format(item.endTime)}';

                      final initial = item.patientName.isNotEmpty
                          ? item.patientName[0].toUpperCase()
                          : 'H';

                      return AppCard(
                        onTap: () => _openDetailSheet(item),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: AppRadius.roundedLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
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
                                        size: 13,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        timeStr,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppStatusBadge(status: item.status),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(
                                    initial,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.primaryDark,
                                      fontSize: 14,
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
                                        item.patientName,
                                        style: AppTypography.titleMedium.copyWith(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.serviceName} • ${item.doctorName}',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.slateLight,
                                        ),
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
                            if (item.clinicalNote != null &&
                                item.clinicalNote!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.borderSubtle,
                                  borderRadius: AppRadius.roundedSm,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.notes_rounded,
                                      size: 14,
                                      color: AppColors.slateLight,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item.clinicalNote!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.slateDark,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
