import 'package:equatable/equatable.dart';

enum UserRole {
  admin,
  staff;

  static UserRole fromString(String value) {
    return switch (value.toLowerCase()) {
      'admin' => UserRole.admin,
      _ => UserRole.staff,
    };
  }

  String get label => switch (this) {
        UserRole.admin => 'Klinik Yöneticisi',
        UserRole.staff => 'Klinik Çalışanı',
      };
}

/// Clinic Staff/Doctor profile entity.
class UserProfile extends Equatable {
  final String id;
  final String clinicId;
  final String fullName;
  final String email;
  final UserRole role;
  final bool isActive;

  const UserProfile({
    required this.id,
    required this.clinicId,
    required this.fullName,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  bool get isAdmin => role == UserRole.admin;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'staff'),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'full_name': fullName,
      'email': email,
      'role': role.name,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, clinicId, fullName, email, role, isActive];
}
