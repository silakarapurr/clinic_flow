import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_handler.dart';
import '../../domain/repositories/patients_repository.dart';
import 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  final PatientsRepository _patientsRepository;

  PatientsCubit({required PatientsRepository patientsRepository})
      : _patientsRepository = patientsRepository,
        super(const PatientsInitial());

  Future<void> loadPatients({String? query}) async {
    emit(const PatientsLoading());
    try {
      final list = await _patientsRepository.getPatients(query: query);
      emit(PatientsLoaded(patients: list, searchQuery: query));
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(PatientsError(failure.message));
    }
  }

  Future<void> createPatient({
    required String fullName,
    required String phone,
    DateTime? birthDate,
    String? notes,
  }) async {
    try {
      final created = await _patientsRepository.createPatient(
        fullName: fullName,
        phone: phone,
        birthDate: birthDate,
        notes: notes,
      );
      emit(PatientCreatedSuccess(created));
      await loadPatients();
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(PatientsError(failure.message));
    }
  }
}
