import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/app_strings.dart';
import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/appointments/presentation/cubit/appointments_cubit.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/views/splash_view.dart';
import '../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../features/doctors/presentation/cubit/doctors_cubit.dart';
import '../features/patients/presentation/cubit/patients_cubit.dart';

/// Root application widget for ClinicFlow.
class ClinicFlowApp extends StatelessWidget {
  const ClinicFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(
          value: sl<AuthCubit>(),
        ),
        BlocProvider<DashboardCubit>.value(
          value: sl<DashboardCubit>()..loadDashboard(),
        ),
        BlocProvider<PatientsCubit>.value(
          value: sl<PatientsCubit>()..loadPatients(),
        ),
        BlocProvider<AppointmentsCubit>.value(
          value: sl<AppointmentsCubit>()..loadAppointments(),
        ),
        BlocProvider<DoctorsCubit>.value(
          value: sl<DoctorsCubit>()..loadDoctors(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('tr', 'TR'),
        home: const SplashView(),
      ),
    );
  }
}
