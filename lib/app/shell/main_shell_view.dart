import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/appointments/presentation/cubit/appointments_cubit.dart';
import '../../features/appointments/presentation/views/appointments_calendar_view.dart';
import '../../features/appointments/presentation/views/create_appointment_dialog.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/dashboard/presentation/views/dashboard_view.dart';
import '../../features/doctors/presentation/views/doctors_list_view.dart';
import '../../features/patients/presentation/views/patients_list_view.dart';
import '../../features/settings/presentation/views/settings_view.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _currentIndex = 0;

  void _openCreateAppointmentModal() {
    showDialog<void>(
      context: context,
      builder: (ctx) => CreateAppointmentDialog(
        initialDate: DateTime.now(),
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
        }) async {
          await sl<AppointmentsCubit>().createAppointment(
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
          if (mounted) {
            unawaited(context.read<DashboardCubit>().loadDashboard());
          }
        },
      ),
    );
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      context.read<DashboardCubit>().loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardView(onNewAppointmentTap: _openCreateAppointmentModal),
      const AppointmentsCalendarView(),
      const PatientsListView(),
      const DoctorsListView(),
      const SettingsView(),
    ];

    final navItems = [
      (
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: AppStrings.dashboard,
      ),
      (
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: AppStrings.appointments,
      ),
      (
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: AppStrings.patients,
      ),
      (
        icon: Icons.medical_services_outlined,
        activeIcon: Icons.medical_services_rounded,
        label: 'Hekimler',
      ),
      (
        icon: Icons.tune_outlined,
        activeIcon: Icons.tune_rounded,
        label: AppStrings.settings,
      ),
    ];

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => const LoginView(),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.border.withValues(alpha: 0.8),
                width: 0.8,
              ),
            ),
            boxShadow: AppShadows.floatingBar,
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = _currentIndex == index;

                  return Expanded(
                    child: InkWell(
                      onTap: () => _onTabSelected(index),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 12 : 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight.withValues(alpha: 0.6)
                                : Colors.transparent,
                            borderRadius: AppRadius.roundedFull,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? item.activeIcon : item.icon,
                                size: 22,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.slateLight,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryDark
                                      : AppColors.slateLight,
                                  letterSpacing: -0.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
