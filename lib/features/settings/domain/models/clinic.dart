import 'package:equatable/equatable.dart';

/// Clinic entity (Tenant).
class Clinic extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String address;

  const Clinic({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  @override
  List<Object?> get props => [id, name, phone, address];
}
