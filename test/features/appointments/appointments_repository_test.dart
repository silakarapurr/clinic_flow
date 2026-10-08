import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_flow/core/error/exceptions.dart';
import 'package:clinic_flow/features/appointments/data/repositories/appointments_repository_impl.dart';
import 'package:clinic_flow/shared/models/appointment_status.dart';

void main() {
  late AppointmentsRepositoryImpl repository;

  setUp(() {
    repository = AppointmentsRepositoryImpl();
  });

  group('AppointmentsRepositoryImpl Tests', () {
    test('should retrieve appointments successfully', () async {
      final list = await repository.getAppointments();
      expect(list, isNotEmpty);
    });

    test('should prevent overlapping appointments for the same doctor (conflict)', () async {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day, 14, 0);
      final end = start.add(const Duration(minutes: 30));

      // 1. Create first appointment
      await repository.createAppointment(
        doctorId: 'doc-conflict-test',
        doctorName: 'Dr. Test',
        patientId: 'pat-1',
        patientName: 'Hasta 1',
        patientPhone: '0532 000 00 00',
        serviceName: 'Muayene',
        startTime: start,
        endTime: end,
      );

      // 2. Attempt to create conflicting appointment at overlapping time (14:15 - 14:45)
      final conflictingStart = start.add(const Duration(minutes: 15));
      final conflictingEnd = conflictingStart.add(const Duration(minutes: 30));

      expect(
        () => repository.createAppointment(
          doctorId: 'doc-conflict-test',
          doctorName: 'Dr. Test',
          patientId: 'pat-2',
          patientName: 'Hasta 2',
          patientPhone: '0533 000 00 00',
          serviceName: 'Kontrol',
          startTime: conflictingStart,
          endTime: conflictingEnd,
        ),
        throwsA(isA<ConflictException>()),
      );
    });

    test('should update appointment status correctly', () async {
      final appointments = await repository.getAppointments();
      final target = appointments.first;

      final updated = await repository.updateAppointmentStatus(
        appointmentId: target.id,
        status: AppointmentStatus.completed,
        clinicalNote: 'Test tamamlandı notu.',
      );

      expect(updated.status, AppointmentStatus.completed);
      expect(updated.clinicalNote, 'Test tamamlandı notu.');
    });
  });
}
