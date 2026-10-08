/// Centralized Turkish strings for the application to prevent magic strings.
class AppStrings {
  AppStrings._();

  // App & General
  static const String appName = 'ClinicFlow';
  static const String appTagline = 'Klinik & Randevu Yönetim Sistemi';
  static const String ok = 'Tamam';
  static const String cancel = 'İptal';
  static const String save = 'Kaydet';
  static const String delete = 'Sil';
  static const String edit = 'Düzenle';
  static const String close = 'Kapat';
  static const String retry = 'Tekrar Dene';
  static const String search = 'Ara';
  static const String select = 'Seçiniz';
  static const String all = 'Tümü';

  // Auth
  static const String loginTitle = 'Giriş Yap';
  static const String loginSubtitle = 'Klinik yönetim paneline erişmek için giriş yapın.';
  static const String emailLabel = 'E-posta Adresi';
  static const String passwordLabel = 'Şifre';
  static const String forgotPassword = 'Şifremi Unuttum';
  static const String loginButton = 'Giriş Yap';
  static const String logout = 'Çıkış Yap';
  static const String logoutConfirmTitle = 'Çıkış Yapılsın mı?';
  static const String logoutConfirmMessage = 'Oturumunuz kapatılacaktır.';

  // Dashboard
  static const String dashboard = 'Özet';
  static const String todayAppointments = 'Bugünkü Randevular';
  static const String pendingAppointments = 'Bekleyen';
  static const String arrivedAppointments = 'Geldi';
  static const String completedAppointments = 'Tamamlanan';
  static const String cancelledAppointments = 'İptal Edilen';
  static const String noShowAppointments = 'Gelmedi';
  static const String upcomingAppointments = 'Yaklaşan Randevular';
  static const String noAppointmentsToday = 'Bugün için planlanmış randevu bulunmuyor.';

  // Appointments
  static const String appointments = 'Randevular';
  static const String newAppointment = 'Yeni Randevu';
  static const String editAppointment = 'Randevuyu Düzenle';
  static const String selectPatient = 'Hasta Seçin';
  static const String selectDoctor = 'Doktor Seçin';
  static const String selectService = 'İşlem / Hizmet Seçin';
  static const String appointmentDate = 'Randevu Tarihi';
  static const String appointmentTime = 'Randevu Saati';
  static const String clinicalNote = 'Klinik Notu';
  static const String statusUpdated = 'Randevu durumu güncellendi.';
  static const String appointmentCreated = 'Randevu başarıyla oluşturuldu.';

  // Patients
  static const String patients = 'Hastalar';
  static const String newPatient = 'Yeni Hasta';
  static const String searchPatient = 'Hasta adı veya telefon ara...';
  static const String patientDetail = 'Hasta Detayı';
  static const String patientHistory = 'Randevu Geçmişi';
  static const String patientName = 'Ad Soyad';
  static const String patientPhone = 'Telefon';
  static const String patientBirthDate = 'Doğum Tarihi';
  static const String noPatientsFound = 'Kayıtlı hasta bulunamadı.';
  static const String patientCreated = 'Hasta kaydı oluşturuldu.';

  // Doctors
  static const String doctors = 'Hekimler & Çalışanlar';
  static const String doctorDetail = 'Hekim Detayı';
  static const String workingHours = 'Çalışma Saatleri';
  static const String specialty = 'Uzmanlık';
  static const String activeStatus = 'Aktif';
  static const String inactiveStatus = 'Pasif';

  // Settings
  static const String settings = 'Ayarlar';
  static const String clinicProfile = 'Klinik Bilgileri';
  static const String userProfile = 'Hesap Bilgileri';
  static const String security = 'Güvenlik';
  static const String deleteAccount = 'Hesabımı Sil';
  static const String deleteAccountWarning = 'Hesabınızı ve klinik bağlantınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';

  // Error Messages
  static const String genericError = 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
  static const String networkError = 'İnternet bağlantısı kurulamadı. Lütfen bağlantınızı kontrol edin.';
  static const String authInvalidCredentials = 'E-posta adresi veya şifre hatalı.';
  static const String authSessionExpired = 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.';
  static const String conflictError = 'Seçilen saatte doktorun başka bir randevusu bulunmaktadır.';
  static const String validationError = 'Lütfen formdaki zorunlu alanları eksiksiz doldurun.';
  static const String duplicatePhoneError = 'Bu telefon numarası ile kayıtlı bir hasta zaten mevcut.';
  static const String notFoundError = 'Aranan kayıt bulunamadı.';
}
