import '../../features/auth/domain/models/user_profile.dart';
import '../../features/doctors/domain/models/doctor.dart';
import '../../features/patients/domain/models/patient.dart';
import '../../features/appointments/domain/models/appointment.dart';
import '../../features/settings/domain/models/clinic.dart';
import '../../shared/models/appointment_status.dart';

/// Seed data providing realistic initial clinic data for preview and local testing.
class SeedData {
  SeedData._();

  static const String clinicId = 'c101-clinic-001';

  static const Clinic clinic = Clinic(
    id: clinicId,
    name: 'DentCare & Sağlık Kliniği',
    phone: '+90 (212) 555 01 23',
    address: 'Bağdat Caddesi No: 142/4, Kadıköy / İstanbul',
  );

  static const UserProfile userProfile = UserProfile(
    id: 'u101-user-001',
    clinicId: clinicId,
    fullName: 'Dr. Zeynep Kaya',
    email: 'zeynep@clinicflow.com',
    role: UserRole.admin,
  );

  static final List<Doctor> doctors = [
    const Doctor(
      id: 'doc-001',
      clinicId: clinicId,
      fullName: 'Dr. Zeynep Kaya',
      specialty: 'Ortodonti Uzmanı',
      phone: '0532 100 20 30',
      workDays: [1, 2, 3, 4, 5],
      startHour: '09:00',
      endHour: '18:00',
      slotDurationMinutes: 30,
    ),
    const Doctor(
      id: 'doc-002',
      clinicId: clinicId,
      fullName: 'Dr. Emre Demir',
      specialty: 'Diş Hekimi & İmplantolog',
      phone: '0542 200 30 40',
      workDays: [1, 2, 3, 4, 6],
      startHour: '10:00',
      endHour: '19:00',
      slotDurationMinutes: 45,
    ),
    const Doctor(
      id: 'doc-003',
      clinicId: clinicId,
      fullName: 'Dt. Seda Yıldız',
      specialty: 'Pedodonti (Çocuk Diş Hekimi)',
      phone: '0555 300 40 50',
      workDays: [2, 3, 4, 5, 6],
      startHour: '09:00',
      endHour: '17:00',
      slotDurationMinutes: 30,
    ),
  ];

  static final List<Patient> patients = [
    Patient(
      id: 'pat-001',
      clinicId: clinicId,
      fullName: 'Ahmet Yılmaz',
      phone: '0533 111 22 33',
      birthDate: DateTime(1988, 5, 14),
      notes: 'Penisilin alerjisi bulunmaktadır. Hassas diş eti yapısı.',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Patient(
      id: 'pat-002',
      clinicId: clinicId,
      fullName: 'Merve Çelik',
      phone: '0544 222 33 44',
      birthDate: DateTime(1995, 11, 22),
      notes: 'Braket takıldı, aylık kontrol hastası.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Patient(
      id: 'pat-003',
      clinicId: clinicId,
      fullName: 'Burak Şahin',
      phone: '0555 333 44 55',
      birthDate: DateTime(2001, 3, 8),
      notes: '20lik diş çekimi planlanıyor.',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Patient(
      id: 'pat-004',
      clinicId: clinicId,
      fullName: 'Ayşe Öztürk',
      phone: '0532 444 55 66',
      birthDate: DateTime(1982, 8, 19),
      notes: 'İmplant protez provası.',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  static List<Appointment> getAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      Appointment(
        id: 'apt-001',
        clinicId: clinicId,
        doctorId: 'doc-001',
        doctorName: 'Dr. Zeynep Kaya',
        patientId: 'pat-001',
        patientName: 'Ahmet Yılmaz',
        patientPhone: '0533 111 22 33',
        serviceName: 'Aylik Ortodonti Kontrolü',
        startTime: today.add(const Duration(hours: 9, minutes: 30)),
        endTime: today.add(const Duration(hours: 10, minutes: 0)),
        status: AppointmentStatus.completed,
        clinicalNote: 'Alt tel arkı değiştirildi. Elastik kullanımına devam edilecek.',
      ),
      Appointment(
        id: 'apt-002',
        clinicId: clinicId,
        doctorId: 'doc-001',
        doctorName: 'Dr. Zeynep Kaya',
        patientId: 'pat-002',
        patientName: 'Merve Çelik',
        patientPhone: '0544 222 33 44',
        serviceName: 'Tel Kontrolü & Ayarlama',
        startTime: today.add(const Duration(hours: 10, minutes: 30)),
        endTime: today.add(const Duration(hours: 11, minutes: 0)),
        status: AppointmentStatus.arrived,
        clinicalNote: 'Hasta bekleme salonunda.',
      ),
      Appointment(
        id: 'apt-003',
        clinicId: clinicId,
        doctorId: 'doc-002',
        doctorName: 'Dr. Emre Demir',
        patientId: 'pat-003',
        patientName: 'Burak Şahin',
        patientPhone: '0555 333 44 55',
        serviceName: 'Gömülü Diş Muayenesi',
        startTime: today.add(const Duration(hours: 14, minutes: 0)),
        endTime: today.add(const Duration(hours: 14, minutes: 45)),
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: 'apt-004',
        clinicId: clinicId,
        doctorId: 'doc-003',
        doctorName: 'Dt. Seda Yıldız',
        patientId: 'pat-004',
        patientName: 'Ayşe Öztürk',
        patientPhone: '0532 444 55 66',
        serviceName: 'Diş Taşı Temizliği',
        startTime: today.add(const Duration(hours: 15, minutes: 30)),
        endTime: today.add(const Duration(hours: 16, minutes: 0)),
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: 'apt-005',
        clinicId: clinicId,
        doctorId: 'doc-002',
        doctorName: 'Dr. Emre Demir',
        patientId: 'pat-001',
        patientName: 'Ahmet Yılmaz',
        patientPhone: '0533 111 22 33',
        serviceName: 'Konsültasyon',
        startTime: today.subtract(const Duration(days: 1)).add(const Duration(hours: 11)),
        endTime: today.subtract(const Duration(days: 1)).add(const Duration(hours: 11, minutes: 30)),
        status: AppointmentStatus.completed,
        clinicalNote: 'Genel kontrol yapıldı.',
      ),
    ];
  }
}
