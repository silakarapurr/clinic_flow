import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clinic_flow/features/patients/domain/models/patient.dart';
import 'package:clinic_flow/features/patients/domain/repositories/patients_repository.dart';
import 'package:clinic_flow/features/patients/presentation/cubit/patients_cubit.dart';
import 'package:clinic_flow/features/patients/presentation/cubit/patients_state.dart';

class MockPatientsRepository extends Mock implements PatientsRepository {}

void main() {
  late MockPatientsRepository mockRepo;
  late PatientsCubit cubit;

  final testPatients = [
    Patient(
      id: 'p-1',
      clinicId: 'c-1',
      fullName: 'Ahmet Yılmaz',
      phone: '0533 111 22 33',
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockRepo = MockPatientsRepository();
    cubit = PatientsCubit(patientsRepository: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('PatientsCubit Tests', () {
    test('initial state should be PatientsInitial', () {
      expect(cubit.state, const PatientsInitial());
    });

    blocTest<PatientsCubit, PatientsState>(
      'emits [PatientsLoading, PatientsLoaded] when loadPatients succeeds',
      build: () {
        when(() => mockRepo.getPatients(query: any(named: 'query')))
            .thenAnswer((_) async => testPatients);
        return cubit;
      },
      act: (c) => c.loadPatients(),
      expect: () => [
        const PatientsLoading(),
        PatientsLoaded(patients: testPatients),
      ],
    );
  });
}
