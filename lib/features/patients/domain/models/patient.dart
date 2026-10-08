import 'package:equatable/equatable.dart';

/// Patient model adhering to KVKK minimal personal data principles.
class Patient extends Equatable {
  final String id;
  final String clinicId;
  final String fullName;
  final String phone;
  final DateTime? birthDate;
  final String? notes; // Allergy, special attention
  final DateTime createdAt;

  const Patient({
    required this.id,
    required this.clinicId,
    required this.fullName,
    required this.phone,
    this.birthDate,
    this.notes,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'full_name': fullName,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        clinicId,
        fullName,
        phone,
        birthDate,
        notes,
        createdAt,
      ];
}
