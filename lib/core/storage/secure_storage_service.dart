import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Resilient SecureStorageService with timeout and memory fallback
/// to guarantee the app NEVER hangs on splash/launch in iOS Simulator or production.
class SecureStorageService {
  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryFallback = {};

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility:
                    KeychainAccessibility.first_unlock_this_device,
              ),
            );

  Future<void> saveAuthToken(String token) async {
    _memoryFallback[AppConstants.keyAuthToken] = token;
    try {
      await _storage
          .write(key: AppConstants.keyAuthToken, value: token)
          .timeout(const Duration(seconds: 1));
    } catch (_) {
      // Fallback in memory
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final val = await _storage
          .read(key: AppConstants.keyAuthToken)
          .timeout(const Duration(seconds: 1));
      return val ?? _memoryFallback[AppConstants.keyAuthToken];
    } catch (_) {
      return _memoryFallback[AppConstants.keyAuthToken];
    }
  }

  Future<void> saveClinicId(String clinicId) async {
    _memoryFallback[AppConstants.keyClinicId] = clinicId;
    try {
      await _storage
          .write(key: AppConstants.keyClinicId, value: clinicId)
          .timeout(const Duration(seconds: 1));
    } catch (_) {
      // Fallback in memory
    }
  }

  Future<String?> getClinicId() async {
    try {
      final val = await _storage
          .read(key: AppConstants.keyClinicId)
          .timeout(const Duration(seconds: 1));
      return val ?? _memoryFallback[AppConstants.keyClinicId];
    } catch (_) {
      return _memoryFallback[AppConstants.keyClinicId];
    }
  }

  Future<void> clearAll() async {
    _memoryFallback.clear();
    try {
      await _storage.deleteAll().timeout(const Duration(seconds: 1));
    } catch (_) {
      // Cleared in memory
    }
  }
}
