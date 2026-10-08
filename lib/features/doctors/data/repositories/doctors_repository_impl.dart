import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/network/seed_data.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/doctor.dart';
import '../../domain/repositories/doctors_repository.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  final FirebaseFirestore? _firestore;
  final SecureStorageService? _storageService;
  final List<Doctor> _inMemoryDoctors = List.from(SeedData.doctors);
  bool _seeded = false;

  DoctorsRepositoryImpl({
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
    return _firestore!.collection('clinics').doc(clinicId).collection('doctors');
  }

  @override
  Future<List<Doctor>> getDoctors() async {
    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        final col = _getCollection(clinicId);
        final snapshot = await col.get();

        if (snapshot.docs.isEmpty && !_seeded) {
          _seeded = true;
          final batch = _firestore.batch();
          for (final d in SeedData.doctors) {
            final docRef = col.doc(d.id);
            batch.set(docRef, d.copyWith(clinicId: clinicId).toJson());
          }
          await batch.commit();

          _inMemoryDoctors.clear();
          _inMemoryDoctors.addAll(SeedData.doctors);
        } else if (snapshot.docs.isNotEmpty) {
          final fetched = snapshot.docs
              .map((doc) => Doctor.fromJson(doc.data()))
              .toList();
          _inMemoryDoctors.clear();
          _inMemoryDoctors.addAll(fetched);
        }
      } catch (_) {
        // Fallback to local memory if offline
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

    return List.unmodifiable(_inMemoryDoctors);
  }

  @override
  Future<Doctor?> getDoctorById(String id) async {
    if (_firestore != null) {
      try {
        final clinicId = await _getClinicId();
        final doc = await _getCollection(clinicId).doc(id).get();
        if (doc.exists && doc.data() != null) {
          return Doctor.fromJson(doc.data()!);
        }
      } catch (_) {
        // Fallback to memory
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    try {
      return _inMemoryDoctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
