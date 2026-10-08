import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_handler.dart';
import '../../../appointments/domain/repositories/appointments_repository.dart';
import '../../../../shared/models/appointment_status.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AppointmentsRepository _appointmentsRepository;

  DashboardCubit({required AppointmentsRepository appointmentsRepository})
      : _appointmentsRepository = appointmentsRepository,
        super(const DashboardInitial());

  Future<void> loadDashboard() async {
    emit(const DashboardLoading());
    try {
      final now = DateTime.now();
      final appointments = await _appointmentsRepository.getAppointments(date: now);
      emit(DashboardLoaded.fromAppointments(appointments));
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(DashboardError(failure.message));
    }
  }

  Future<void> updateStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _appointmentsRepository.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
      );
      // Reload dashboard metrics
      await loadDashboard();
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(DashboardError(failure.message));
    }
  }
}
