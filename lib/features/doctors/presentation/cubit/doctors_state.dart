import 'package:equatable/equatable.dart';
import '../../domain/models/doctor.dart';

sealed class DoctorsState extends Equatable {
  const DoctorsState();

  @override
  List<Object?> get props => [];
}

class DoctorsInitial extends DoctorsState {
  const DoctorsInitial();
}

class DoctorsLoading extends DoctorsState {
  const DoctorsLoading();
}

class DoctorsLoaded extends DoctorsState {
  final List<Doctor> doctors;

  const DoctorsLoaded(this.doctors);

  @override
  List<Object?> get props => [doctors];
}

class DoctorsError extends DoctorsState {
  final String message;

  const DoctorsError(this.message);

  @override
  List<Object?> get props => [message];
}
