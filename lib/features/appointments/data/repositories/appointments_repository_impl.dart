import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/seed_data.dart';
import '../../../../shared/models/appointment_status.dart';
import '../../domain/models/appointment.dart';
import '../../domain/repositories/appointments_repository.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final List<Appointment> _inMemoryAppointments = List.from(SeedData.getAppointments());

  @override
  Future<List<Appointment>> getAppointments({DateTime? date}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (date == null) {
      return List.unmodifiable(_inMemoryAppointments);
    }

    final target = DateTime(date.year, date.month, date.day);
    return _inMemoryAppointments.where((apt) {
      final aptDate = DateTime(
        apt.startTime.year,
        apt.startTime.month,
        apt.startTime.day,
      );
      return aptDate.isAtSameMomentAs(target);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<List<Appointment>> getAppointmentsForPatient(String patientId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _inMemoryAppointments
        .where((apt) => apt.patientId == patientId)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<bool> hasConflict({
    required String doctorId,
    required DateTime startTime,
    required DateTime endTime,
    String? excludeAppointmentId,
  }) async {
    return _inMemoryAppointments.any((apt) {
      if (apt.id == excludeAppointmentId) return false;
      if (apt.doctorId != doctorId) return false;
      if (apt.status == AppointmentStatus.cancelled) return false;

      // Overlap condition:
      // (StartA < EndB) and (EndA > StartB)
      final overlaps = apt.startTime.isBefore(endTime) &&
          apt.endTime.isAfter(startTime);
      return overlaps;
    });
  }

  @override
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
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Conflict check
    final isConflicting = await hasConflict(
      doctorId: doctorId,
      startTime: startTime,
      endTime: endTime,
    );

    if (isConflicting) {
      throw const ConflictException(message: AppStrings.conflictError);
    }

    final newAppointment = Appointment(
      id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
      clinicId: SeedData.clinicId,
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      serviceName: serviceName,
      startTime: startTime,
      endTime: endTime,
      status: AppointmentStatus.scheduled,
      clinicalNote: clinicalNote,
    );

    _inMemoryAppointments.add(newAppointment);
    return newAppointment;
  }

  @override
  Future<Appointment> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
    String? clinicalNote,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _inMemoryAppointments.indexWhere((a) => a.id == appointmentId);

    if (index == -1) {
      throw const ServerException(message: AppStrings.notFoundError);
    }

    final existing = _inMemoryAppointments[index];
    final updated = existing.copyWith(
      status: status,
      clinicalNote: clinicalNote ?? existing.clinicalNote,
    );

    _inMemoryAppointments[index] = updated;
    return updated;
  }
}
