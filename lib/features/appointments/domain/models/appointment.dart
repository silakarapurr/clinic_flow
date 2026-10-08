import 'package:equatable/equatable.dart';
import '../../../../shared/models/appointment_status.dart';

/// Appointment entity model.
class Appointment extends Equatable {
  final String id;
  final String clinicId;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String serviceName;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final String? clinicalNote;

  const Appointment({
    required this.id,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.clinicalNote,
  });

  Appointment copyWith({
    String? id,
    String? clinicId,
    String? doctorId,
    String? doctorName,
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? serviceName,
    DateTime? startTime,
    DateTime? endTime,
    AppointmentStatus? status,
    String? clinicalNote,
  }) {
    return Appointment(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      serviceName: serviceName ?? this.serviceName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      clinicalNote: clinicalNote ?? this.clinicalNote,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    try {
      // ignore: avoid_dynamic_calls
      return (value.toDate() as DateTime).toLocal();
    } catch (_) {}
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed?.toLocal();
    }
    return null;
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctors'] as Map<String, dynamic>? ?? {};
    final patient = json['patients'] as Map<String, dynamic>? ?? {};
    final service = json['services'] as Map<String, dynamic>? ?? {};

    final now = DateTime.now();
    return Appointment(
      id: json['id'] as String? ?? '',
      clinicId: json['clinic_id'] as String? ?? '',
      doctorId: json['doctor_id'] as String? ?? '',
      doctorName: (doctor['full_name'] as String?) ??
          (json['doctor_name'] as String? ?? 'Doktor'),
      patientId: json['patient_id'] as String? ?? '',
      patientName: (patient['full_name'] as String?) ??
          (json['patient_name'] as String? ?? 'Hasta'),
      patientPhone: (patient['phone'] as String?) ??
          (json['patient_phone'] as String? ?? ''),
      serviceName: (service['name'] as String?) ??
          (json['service_name'] as String? ?? 'Genel Muayene'),
      startTime: _parseDate(json['start_time']) ?? now,
      endTime: _parseDate(json['end_time']) ?? now.add(const Duration(minutes: 30)),
      status: AppointmentStatus.fromString(json['status'] as String? ?? 'scheduled'),
      clinicalNote: json['clinical_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'service_name': serviceName,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'status': status.name,
      'clinical_note': clinicalNote,
    };
  }

  @override
  List<Object?> get props => [
        id,
        clinicId,
        doctorId,
        doctorName,
        patientId,
        patientName,
        patientPhone,
        serviceName,
        startTime,
        endTime,
        status,
        clinicalNote,
      ];
}
