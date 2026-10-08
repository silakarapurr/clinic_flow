import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_flow/core/error/exceptions.dart';
import 'package:clinic_flow/features/patients/data/repositories/patients_repository_impl.dart';

void main() {
  late PatientsRepositoryImpl repository;

  setUp(() {
    repository = PatientsRepositoryImpl();
  });

  group('PatientsRepositoryImpl Tests', () {
    test('should retrieve patients list', () async {
      final list = await repository.getPatients();
      expect(list, isNotEmpty);
    });

    test('should search patients by query (name or phone)', () async {
      final list = await repository.getPatients(query: 'Ahmet');
      expect(list.any((p) => p.fullName.contains('Ahmet')), isTrue);
    });

    test('should create a new patient successfully', () async {
      final newPat = await repository.createPatient(
        fullName: 'Zeynep Kaya',
        phone: '0555 999 88 77',
      );
      expect(newPat.fullName, 'Zeynep Kaya');
      expect(newPat.id, isNotEmpty);

      final fetched = await repository.getPatientById(newPat.id);
      expect(fetched?.fullName, 'Zeynep Kaya');
    });

    test('should reject duplicate phone numbers with ValidationException', () async {
      await repository.createPatient(
        fullName: 'Birinci Hasta',
        phone: '0544 111 22 33',
      );

      expect(
        () => repository.createPatient(
          fullName: 'İkinci Hasta',
          phone: '0544 111 22 33',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should update existing patient', () async {
      final list = await repository.getPatients();
      final target = list.first;

      final updated = target.copyWith(notes: 'Özel alerji durumu güncellendi');
      final result = await repository.updatePatient(updated);

      expect(result.notes, 'Özel alerji durumu güncellendi');
    });
  });
}
