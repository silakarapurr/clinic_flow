import '../models/doctor.dart';

abstract class DoctorsRepository {
  Future<List<Doctor>> getDoctors();
  Future<Doctor?> getDoctorById(String id);
}
