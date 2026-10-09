import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../constants/app_strings.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Centralized error handler that ensures no raw technical errors
/// are ever shown to the clinic staff or users.
class ErrorHandler {
  ErrorHandler._();

  /// Converts any caught exception into a clean, typed [Failure]
  static Failure handleException(Object error) {
    if (error is SocketException || error is TimeoutException) {
      return const NetworkFailure(message: AppStrings.networkError);
    }

    if (error is fb.FirebaseAuthException) {
      return AuthFailure(
        message: _mapFirebaseAuthCode(error.code),
        code: error.code,
      );
    }

    if (error is AuthException) {
      return AuthFailure(
        message: _mapAuthError(error.message),
        code: error.code,
      );
    }

    if (error is ConflictException) {
      return ConflictFailure(message: error.message);
    }

    if (error is ValidationException) {
      return ValidationFailure(message: error.message);
    }

    if (error is StorageException) {
      return StorageFailure(message: error.message);
    }

    if (error is ServerException) {
      return ServerFailure(
        message: error.message.isNotEmpty
            ? error.message
            : AppStrings.genericError,
        code: error.code,
      );
    }

    return const ServerFailure(message: AppStrings.genericError);
  }

  static String _mapFirebaseAuthCode(String code) {
    return switch (code) {
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'invalid-email' =>
        AppStrings.authInvalidCredentials,
      'email-already-in-use' => 'Bu e-posta adresi zaten kayıtlıdır.',
      'user-disabled' => 'Bu hesap devre dışı bırakılmıştır.',
      'too-many-requests' =>
        'Çok fazla başarısız deneme yapıldı. Lütfen biraz bekleyin.',
      'network-request-failed' => AppStrings.networkError,
      'configuration-not-found' ||
      'operation-not-allowed' ||
      'api-key-not-valid' =>
        'Kimlik doğrulama servisi henüz yapılandırılmamış veya devre dışı.',
      _ => AppStrings.genericError,
    };
  }

  /// Maps Supabase/Auth technical error strings to clear Turkish text.
  static String _mapAuthError(String rawMessage) {
    final lower = rawMessage.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid grant')) {
      return AppStrings.authInvalidCredentials;
    }
    if (lower.contains('session expired') || lower.contains('jwt expired')) {
      return AppStrings.authSessionExpired;
    }
    if (lower.contains('network') || lower.contains('connection')) {
      return AppStrings.networkError;
    }
    return AppStrings.authInvalidCredentials;
  }
}
