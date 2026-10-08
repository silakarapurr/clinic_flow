import 'package:equatable/equatable.dart';
import '../../domain/models/patient.dart';

sealed class PatientsState extends Equatable {
  const PatientsState();

  @override
  List<Object?> get props => [];
}

class PatientsInitial extends PatientsState {
  const PatientsInitial();
}

class PatientsLoading extends PatientsState {
  const PatientsLoading();
}

class PatientsLoaded extends PatientsState {
  final List<Patient> patients;
  final String? searchQuery;

  const PatientsLoaded({required this.patients, this.searchQuery});

  @override
  List<Object?> get props => [patients, searchQuery];
}

class PatientsError extends PatientsState {
  final String message;

  const PatientsError(this.message);

  @override
  List<Object?> get props => [message];
}

class PatientCreatedSuccess extends PatientsState {
  final Patient patient;

  const PatientCreatedSuccess(this.patient);

  @override
  List<Object?> get props => [patient];
}
