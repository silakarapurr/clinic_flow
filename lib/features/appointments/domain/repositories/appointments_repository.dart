import '../../../../shared/models/appointment_status.dart';
import '../models/appointment.dart';

abstract class AppointmentsRepository {
  Future<List<Appointment>> getAppointments({DateTime? date});

  Future<List<Appointment>> getAppointmentsForPatient(String patientId);

  Future<Appointment> createAppointment({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String serviceName,
    required DateTime startTime,
    required DateTime endTime,
    String? clinicalNote,
  });

  Future<Appointment> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
    String? clinicalNote,
  });

  Future<bool> hasConflict({
    required String doctorId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeAppointmentId,
  });
}
