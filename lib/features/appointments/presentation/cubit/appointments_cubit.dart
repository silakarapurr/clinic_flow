import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../shared/models/appointment_status.dart';
import '../../domain/repositories/appointments_repository.dart';
import 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final AppointmentsRepository _appointmentsRepository;
  DateTime _currentSelectedDate = DateTime.now();

  AppointmentsCubit({required AppointmentsRepository appointmentsRepository})
      : _appointmentsRepository = appointmentsRepository,
        super(const AppointmentsInitial());

  DateTime get selectedDate => _currentSelectedDate;

  Future<void> loadAppointments({DateTime? date}) async {
    final targetDate = date ?? _currentSelectedDate;
    _currentSelectedDate = targetDate;
    emit(const AppointmentsLoading());

    try {
      final list = await _appointmentsRepository.getAppointments(date: targetDate);
      emit(AppointmentsLoaded(
        appointments: list,
        selectedDate: targetDate,
      ));
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(AppointmentsError(failure.message));
    }
  }

  Future<void> createAppointment({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String serviceName,
    required DateTime startTime,
    required DateTime endTime,
    String? clinicalNote,
  }) async {
    try {
      final created = await _appointmentsRepository.createAppointment(
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
      emit(AppointmentCreatedSuccess(created));
      await loadAppointments(date: _currentSelectedDate);
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(AppointmentsError(failure.message));
    }
  }

  Future<void> updateStatus(
    String appointmentId,
    AppointmentStatus status, {
    String? clinicalNote,
  }) async {
    try {
      await _appointmentsRepository.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
        clinicalNote: clinicalNote,
      );
      await loadAppointments(date: _currentSelectedDate);
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(AppointmentsError(failure.message));
    }
  }
}
