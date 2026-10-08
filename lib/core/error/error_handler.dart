import 'dart:async';
import 'dart:io';

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

    if (error is AuthException) {
      return AuthFailure(
        message: _mapAuthError(error.message),
        code: error.code,
      );
    }

    if (error is ConflictException) {
      return ConflictFailure(message: error.message);
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
