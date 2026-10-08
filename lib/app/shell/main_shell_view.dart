import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import '../../features/appointments/presentation/cubit/appointments_cubit.dart';
import '../../features/appointments/presentation/views/appointments_calendar_view.dart';
import '../../features/appointments/presentation/views/create_appointment_dialog.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/dashboard/presentation/views/dashboard_view.dart';
import '../../features/doctors/presentation/cubit/doctors_cubit.dart';
import '../../features/doctors/presentation/views/doctors_list_view.dart';
import '../../features/patients/presentation/cubit/patients_cubit.dart';
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
    showDialog(
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
            context.read<DashboardCubit>().loadDashboard();
          }
        },
      ),
    );
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

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Refresh dashboard data when navigating to dashboard tab
          if (index == 0) {
            context.read<DashboardCubit>().loadDashboard();
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: AppStrings.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today_rounded),
            label: AppStrings.appointments,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: AppStrings.patients,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services_rounded),
            label: 'Hekimler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: AppStrings.settings,
          ),
        ],
      ),
    );
  }
}
