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

  Patient copyWith({
    String? id,
    String? clinicId,
    String? fullName,
    String? phone,
    DateTime? birthDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return Patient(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      // ignore: avoid_dynamic_calls
      return value.toDate() as DateTime;
    } catch (_) {}
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String? ?? '',
      clinicId: json['clinic_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      birthDate: _parseDate(json['birth_date']),
      notes: json['notes'] as String?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
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
