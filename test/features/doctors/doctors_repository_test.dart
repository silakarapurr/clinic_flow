import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_flow/features/doctors/data/repositories/doctors_repository_impl.dart';

void main() {
  late DoctorsRepositoryImpl repository;

  setUp(() {
    repository = DoctorsRepositoryImpl();
  });

  group('DoctorsRepositoryImpl Tests', () {
    test('should retrieve doctors list', () async {
      final list = await repository.getDoctors();
      expect(list, isNotEmpty);
    });

    test('should retrieve doctor by id', () async {
      final list = await repository.getDoctors();
      final doctor = list.first;

      final fetched = await repository.getDoctorById(doctor.id);
      expect(fetched, isNotNull);
      expect(fetched?.id, doctor.id);
      expect(fetched?.fullName, doctor.fullName);
    });
  });
}
