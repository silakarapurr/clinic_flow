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
    context.read<AppointmentsCubit>().loadAppointments(date: _selectedDate);
  }

  void _openCreateAppointment() {
    showDialog(
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
    showModalBottomSheet(
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
    final dateFormat = DateFormat('d MMMM yyyy, EEEE', 'tr_TR');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appointments, style: AppTypography.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: IconButton.filled(
              onPressed: _openCreateAppointment,
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
      body: Column(
        children: [
          // Date Selector Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    });
                    context
                        .read<AppointmentsCubit>()
                        .loadAppointments(date: _selectedDate);
                  },
                ),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      locale: const Locale('tr', 'TR'),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                      context
                          .read<AppointmentsCubit>()
                          .loadAppointments(date: _selectedDate);
                    }
                  },
                  borderRadius: AppRadius.roundedSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          dateFormat.format(_selectedDate),
                          style: AppTypography.titleMedium.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                    context
                        .read<AppointmentsCubit>()
                        .loadAppointments(date: _selectedDate);
                  },
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
                    return EmptyStateView(
                      title: 'Bu tarihte planlanmış randevu yok',
                      description:
                          'Yeni bir randevu planlamak için "+" butonuna dokunun.',
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

                      return AppCard(
                        onTap: () => _openDetailSheet(item),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time column
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: AppRadius.roundedSm,
                              ),
                              child: Text(
                                timeStr,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Details column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.patientName,
                                        style: AppTypography.titleMedium
                                            .copyWith(fontSize: 16),
                                      ),
                                      AppStatusBadge(status: item.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.serviceName} • ${item.doctorName}',
                                    style: AppTypography.bodySmall,
                                  ),
                                  if (item.clinicalNote != null &&
                                      item.clinicalNote!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Not: ${item.clinicalNote}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.slateLight,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
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
