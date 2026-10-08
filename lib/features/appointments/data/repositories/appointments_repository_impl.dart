import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/seed_data.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../shared/models/appointment_status.dart';
import '../../domain/models/appointment.dart';
import '../../domain/repositories/appointments_repository.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final FirebaseFirestore? _firestore;
  final SecureStorageService? _storageService;
  final List<Appointment> _inMemoryAppointments =
      List.from(SeedData.getAppointments());
  bool _seeded = false;

  AppointmentsRepositoryImpl({
    FirebaseFirestore? firestore,
    SecureStorageService? storageService,
  })  : _firestore = firestore ?? _tryGetFirestore(),
        _storageService = storageService;

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<String> _getClinicId() async {
    final stored = await _storageService?.getClinicId();
    return (stored != null && stored.isNotEmpty) ? stored : SeedData.clinicId;
  }

  CollectionReference<Map<String, dynamic>> _getCollection(String clinicId) {
    return _firestore!
        .collection('clinics')
        .doc(clinicId)
        .collection('appointments');
  }

  @override
  Future<List<Appointment>> getAppointments({DateTime? date}) async {
    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        final col = _getCollection(clinicId);
        final snapshot = await col.get();

        if (snapshot.docs.isEmpty && !_seeded) {
          _seeded = true;
          final batch = _firestore.batch();
          final seedAppointments = SeedData.getAppointments();
          for (final a in seedAppointments) {
            final docRef = col.doc(a.id);
            batch.set(docRef, a.copyWith(clinicId: clinicId).toJson());
          }
          await batch.commit();

          _inMemoryAppointments.clear();
          _inMemoryAppointments.addAll(seedAppointments);
        } else if (snapshot.docs.isNotEmpty) {
          final fetched = snapshot.docs
              .map((doc) => Appointment.fromJson(doc.data()))
              .toList();
          _inMemoryAppointments.clear();
          _inMemoryAppointments.addAll(fetched);
        }
      } catch (_) {
        // Fallback to local memory if offline
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

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
    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        final col = _getCollection(clinicId);
        final snapshot =
            await col.where('patient_id', isEqualTo: patientId).get();
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs
              .map((d) => Appointment.fromJson(d.data()))
              .toList()
            ..sort((a, b) => b.startTime.compareTo(a.startTime));
          return list;
        }
      } catch (_) {
        // Fallback
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

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
    final list = await getAppointments();
    return list.any((apt) {
      if (apt.id == excludeAppointmentId) return false;
      if (apt.doctorId != doctorId) return false;
      if (apt.status == AppointmentStatus.cancelled) return false;

      // Overlap condition:
      // (StartA < EndB) and (EndA > StartB)
      final overlaps =
          apt.startTime.isBefore(endTime) && apt.endTime.isAfter(startTime);
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
    // Conflict check
    final isConflicting = await hasConflict(
      doctorId: doctorId,
      startTime: startTime,
      endTime: endTime,
    );

    if (isConflicting) {
      throw const ConflictException(message: AppStrings.conflictError);
    }

    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        final col = _getCollection(clinicId);
        final docRef = col.doc();

        final newAppointment = Appointment(
          id: docRef.id,
          clinicId: clinicId,
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

        await docRef.set(newAppointment.toJson());
        _inMemoryAppointments.add(newAppointment);
        return newAppointment;
      } catch (_) {
        // Fallback to local memory
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));
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
    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        final docRef = _getCollection(clinicId).doc(appointmentId);
        final updateData = <String, dynamic>{
          'status': status.name,
        };
        if (clinicalNote != null) {
          updateData['clinical_note'] = clinicalNote;
        }
        await docRef.set(updateData, SetOptions(merge: true));
      } catch (_) {
        // Fallback
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

    final index =
        _inMemoryAppointments.indexWhere((a) => a.id == appointmentId);

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
