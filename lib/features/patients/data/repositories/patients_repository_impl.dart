import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/seed_data.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/patient.dart';
import '../../domain/repositories/patients_repository.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  final FirebaseFirestore? _firestore;
  final SecureStorageService? _storageService;
  final List<Patient> _inMemoryPatients = List.from(SeedData.patients);
  bool _seeded = false;

  PatientsRepositoryImpl({
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
    return _firestore!.collection('clinics').doc(clinicId).collection('patients');
  }

  @override
  Future<List<Patient>> getPatients({String? query}) async {
    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        final col = _getCollection(clinicId);
        final snapshot = await col.orderBy('created_at', descending: true).get();

        if (snapshot.docs.isEmpty && !_seeded) {
          _seeded = true;
          final batch = _firestore.batch();
          for (final p in SeedData.patients) {
            final docRef = col.doc(p.id);
            batch.set(docRef, p.copyWith(clinicId: clinicId).toJson());
          }
          await batch.commit();

          _inMemoryPatients.clear();
          _inMemoryPatients.addAll(SeedData.patients);
        } else if (snapshot.docs.isNotEmpty) {
          final fetched = snapshot.docs
              .map((doc) => Patient.fromJson(doc.data()))
              .toList();
          _inMemoryPatients.clear();
          _inMemoryPatients.addAll(fetched);
        }
      } catch (_) {
        // Fallback to local memory if offline or uninitialized
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

    if (query == null || query.trim().isEmpty) {
      return List.unmodifiable(_inMemoryPatients);
    }

    final q = query.trim().toLowerCase();
    final cleanQ = q.replaceAll(RegExp(r'\D'), '');
    return _inMemoryPatients.where((p) {
      final matchesName = p.fullName.toLowerCase().contains(q);
      final matchesPhone = cleanQ.isNotEmpty
          ? p.phone.replaceAll(RegExp(r'\D'), '').contains(cleanQ)
          : p.phone.contains(q);
      return matchesName || matchesPhone;
    }).toList();
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        final doc = await _getCollection(clinicId).doc(id).get();
        if (doc.exists && doc.data() != null) {
          return Patient.fromJson(doc.data()!);
        }
      } catch (_) {
        // Fallback to memory
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    try {
      return _inMemoryPatients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Patient> createPatient({
    required String fullName,
    required String phone,
    DateTime? birthDate,
    String? notes,
  }) async {
    final cleanName = fullName.trim();
    final cleanPhone = phone.trim();

    if (cleanName.isEmpty || cleanPhone.isEmpty) {
      throw const ServerException(message: AppStrings.validationError);
    }

    final normalizedPhone = cleanPhone.replaceAll(RegExp(r'\D'), '');

    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        final col = _getCollection(clinicId);

        // Check for duplicate phone in Firestore
        final querySnap = await col.get();
        final isDuplicate = querySnap.docs.any((d) {
          final existingPhone =
              (d.data()['phone'] as String? ?? '').replaceAll(RegExp(r'\D'), '');
          return existingPhone.isNotEmpty && existingPhone == normalizedPhone;
        });

        if (isDuplicate) {
          throw const ValidationException(
            message: AppStrings.duplicatePhoneError,
          );
        }

        final docRef = col.doc();
        final newPatient = Patient(
          id: docRef.id,
          clinicId: clinicId,
          fullName: cleanName,
          phone: cleanPhone,
          birthDate: birthDate,
          notes: notes?.trim(),
          createdAt: DateTime.now(),
        );

        await docRef.set(newPatient.toJson());
        _inMemoryPatients.insert(0, newPatient);
        return newPatient;
      } on ValidationException {
        rethrow;
      } catch (_) {
        // Fallback to local memory
      }
    }

    // Check duplicate in memory
    final hasDupInMemory = _inMemoryPatients.any((p) {
      final existingPhone = p.phone.replaceAll(RegExp(r'\D'), '');
      return existingPhone.isNotEmpty && existingPhone == normalizedPhone;
    });

    if (hasDupInMemory) {
      throw const ValidationException(
        message: AppStrings.duplicatePhoneError,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));
    final newPatient = Patient(
      id: 'pat-${DateTime.now().millisecondsSinceEpoch}',
      clinicId: SeedData.clinicId,
      fullName: cleanName,
      phone: cleanPhone,
      birthDate: birthDate,
      notes: notes?.trim(),
      createdAt: DateTime.now(),
    );

    _inMemoryPatients.insert(0, newPatient);
    return newPatient;
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        await _getCollection(clinicId)
            .doc(patient.id)
            .set(patient.toJson(), SetOptions(merge: true));
      } catch (_) {
        // Fallback
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

    final index = _inMemoryPatients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _inMemoryPatients[index] = patient;
      return patient;
    }
    _inMemoryPatients.insert(0, patient);
    return patient;
  }
}
