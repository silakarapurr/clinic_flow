import 'package:get_it/get_it.dart';

import '../../features/appointments/data/repositories/appointments_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointments_repository.dart';
import '../../features/appointments/presentation/cubit/appointments_cubit.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/doctors/data/repositories/doctors_repository_impl.dart';
import '../../features/doctors/domain/repositories/doctors_repository.dart';
import '../../features/doctors/presentation/cubit/doctors_cubit.dart';
import '../../features/patients/data/repositories/patients_repository_impl.dart';
import '../../features/patients/domain/repositories/patients_repository.dart';
import '../../features/patients/presentation/cubit/patients_cubit.dart';
import '../storage/secure_storage_service.dart';

final GetIt sl = GetIt.instance;

/// Global dependency injection registration.
Future<void> initDependencies() async {
  // Core Services
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(storageService: sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<PatientsRepository>(
    () => PatientsRepositoryImpl(),
  );

  sl.registerLazySingleton<DoctorsRepository>(
    () => DoctorsRepositoryImpl(),
  );

  sl.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(),
  );

  // Cubits & Blocs
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<DashboardCubit>(
    () => DashboardCubit(appointmentsRepository: sl<AppointmentsRepository>()),
  );

  sl.registerLazySingleton<PatientsCubit>(
    () => PatientsCubit(patientsRepository: sl<PatientsRepository>()),
  );

  sl.registerLazySingleton<AppointmentsCubit>(
    () => AppointmentsCubit(appointmentsRepository: sl<AppointmentsRepository>()),
  );

  sl.registerLazySingleton<DoctorsCubit>(
    () => DoctorsCubit(doctorsRepository: sl<DoctorsRepository>()),
  );
}
