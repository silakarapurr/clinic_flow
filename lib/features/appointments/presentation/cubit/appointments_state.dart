import 'package:equatable/equatable.dart';
import '../../domain/models/appointment.dart';

sealed class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

class AppointmentsLoading extends AppointmentsState {
  const AppointmentsLoading();
}

class AppointmentsLoaded extends AppointmentsState {
  final List<Appointment> appointments;
  final DateTime selectedDate;

  const AppointmentsLoaded({
    required this.appointments,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [appointments, selectedDate];
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AppointmentCreatedSuccess extends AppointmentsState {
  final Appointment appointment;

  const AppointmentCreatedSuccess(this.appointment);

  @override
  List<Object?> get props => [appointment];
}
