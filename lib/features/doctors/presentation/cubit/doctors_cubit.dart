import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_handler.dart';
import '../../domain/repositories/doctors_repository.dart';
import 'doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final DoctorsRepository _doctorsRepository;

  DoctorsCubit({required DoctorsRepository doctorsRepository})
      : _doctorsRepository = doctorsRepository,
        super(const DoctorsInitial());

  Future<void> loadDoctors() async {
    emit(const DoctorsLoading());
    try {
      final list = await _doctorsRepository.getDoctors();
      emit(DoctorsLoaded(list));
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(DoctorsError(failure.message));
    }
  }
}
