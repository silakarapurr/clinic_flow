import 'package:equatable/equatable.dart';

/// Doctor / Specialist model.
class Doctor extends Equatable {
  final String id;
  final String clinicId;
  final String fullName;
  final String specialty;
  final String phone;
  final List<int> workDays; // 1 = Pazartesi, 7 = Pazar
  final String startHour; // '09:00'
  final String endHour; // '18:00'
  final int slotDurationMinutes;
  final bool isActive;

  const Doctor({
    required this.id,
    required this.clinicId,
    required this.fullName,
    required this.specialty,
    required this.phone,
    this.workDays = const [1, 2, 3, 4, 5],
    this.startHour = '09:00',
    this.endHour = '18:00',
    this.slotDurationMinutes = 30,
    this.isActive = true,
  });

  Doctor copyWith({
    String? id,
    String? clinicId,
    String? fullName,
    String? specialty,
    String? phone,
    List<int>? workDays,
    String? startHour,
    String? endHour,
    int? slotDurationMinutes,
    bool? isActive,
  }) {
    return Doctor(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      workDays: workDays ?? this.workDays,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final wh = json['working_hours'] as Map<String, dynamic>? ?? {};
    final days = (wh['work_days'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [1, 2, 3, 4, 5];

    return Doctor(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      fullName: json['full_name'] as String,
      specialty: json['specialty'] as String? ?? 'Genel Uzman',
      phone: json['phone'] as String? ?? '',
      workDays: days,
      startHour: wh['start'] as String? ?? '09:00',
      endHour: wh['end'] as String? ?? '18:00',
      slotDurationMinutes: (wh['slot_duration'] as num?)?.toInt() ?? 30,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'full_name': fullName,
      'specialty': specialty,
      'phone': phone,
      'working_hours': {
        'work_days': workDays,
        'start': startHour,
        'end': endHour,
        'slot_duration': slotDurationMinutes,
      },
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        clinicId,
        fullName,
        specialty,
        phone,
        workDays,
        startHour,
        endHour,
        slotDurationMinutes,
        isActive,
      ];
}
