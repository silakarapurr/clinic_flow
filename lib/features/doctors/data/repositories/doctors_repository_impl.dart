import '../../../../core/network/seed_data.dart';
import '../../domain/models/doctor.dart';
import '../../domain/repositories/doctors_repository.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  final List<Doctor> _inMemoryDoctors = List.from(SeedData.doctors);

  @override
  Future<List<Doctor>> getDoctors() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_inMemoryDoctors);
  }

  @override
  Future<Doctor?> getDoctorById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    try {
      return _inMemoryDoctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
