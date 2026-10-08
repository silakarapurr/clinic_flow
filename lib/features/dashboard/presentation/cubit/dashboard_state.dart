import 'package:equatable/equatable.dart';
import '../../../appointments/domain/models/appointment.dart';
import '../../../../shared/models/appointment_status.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final List<Appointment> todayAppointments;
  final int totalCount;
  final int pendingCount;
  final int arrivedCount;
  final int completedCount;
  final int cancelledCount;
  final int noShowCount;

  const DashboardLoaded({
    required this.todayAppointments,
    required this.totalCount,
    required this.pendingCount,
    required this.arrivedCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.noShowCount,
  });

  factory DashboardLoaded.fromAppointments(List<Appointment> list) {
    int pending = 0;
    int arrived = 0;
    int completed = 0;
    int cancelled = 0;
    int noShow = 0;

    for (final apt in list) {
      switch (apt.status) {
        case AppointmentStatus.scheduled:
          pending++;
          break;
        case AppointmentStatus.arrived:
          arrived++;
          break;
        case AppointmentStatus.completed:
          completed++;
          break;
        case AppointmentStatus.cancelled:
          cancelled++;
          break;
        case AppointmentStatus.noShow:
          noShow++;
          break;
      }
    }

    return DashboardLoaded(
      todayAppointments: list,
      totalCount: list.length,
      pendingCount: pending,
      arrivedCount: arrived,
      completedCount: completed,
      cancelledCount: cancelled,
      noShowCount: noShow,
    );
  }

  @override
  List<Object?> get props => [
        todayAppointments,
        totalCount,
        pendingCount,
        arrivedCount,
        completedCount,
        cancelledCount,
        noShowCount,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
