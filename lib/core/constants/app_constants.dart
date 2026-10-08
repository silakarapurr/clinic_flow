/// Global application constants.
class AppConstants {
  AppConstants._();

  static const int defaultPageSize = 20;
  static const int minPasswordLength = 6;
  static const int appointmentSlotMinutes = 30;

  // Cache & Session keys
  static const String keyAuthToken = 'cf_auth_token';
  static const String keyRefreshToken = 'cf_refresh_token';
  static const String keyClinicId = 'cf_clinic_id';
  static const String keyUserId = 'cf_user_id';
  static const String keyUserRole = 'cf_user_role';

  // Validation Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(
    r'^(05\d{9}|\+905\d{9}|5\d{9})$',
  );
}
