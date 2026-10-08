import '../models/patient.dart';

abstract class PatientsRepository {
  Future<List<Patient>> getPatients({String? query});
  Future<Patient?> getPatientById(String id);
  Future<Patient> createPatient({
    required String fullName,
    required String phone,
    DateTime? birthDate,
    String? notes,
  });
  Future<Patient> updatePatient(Patient patient);
}
