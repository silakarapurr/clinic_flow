import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/seed_data.dart';
import '../../domain/models/patient.dart';
import '../../domain/repositories/patients_repository.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  final List<Patient> _inMemoryPatients = List.from(SeedData.patients);

  @override
  Future<List<Patient>> getPatients({String? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (query == null || query.trim().isEmpty) {
      return List.unmodifiable(_inMemoryPatients);
    }

    final q = query.trim().toLowerCase();
    return _inMemoryPatients
        .where((p) =>
            p.fullName.toLowerCase().contains(q) || p.phone.contains(q))
        .toList();
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
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
    if (fullName.trim().isEmpty || phone.trim().isEmpty) {
      throw const ServerException(message: AppStrings.validationError);
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    final newPatient = Patient(
      id: 'pat-${DateTime.now().millisecondsSinceEpoch}',
      clinicId: SeedData.clinicId,
      fullName: fullName.trim(),
      phone: phone.trim(),
      birthDate: birthDate,
      notes: notes?.trim(),
      createdAt: DateTime.now(),
    );

    _inMemoryPatients.insert(0, newPatient);
    return newPatient;
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _inMemoryPatients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _inMemoryPatients[index] = patient;
      return patient;
    }
    throw const ServerException(message: AppStrings.notFoundError);
  }
}
