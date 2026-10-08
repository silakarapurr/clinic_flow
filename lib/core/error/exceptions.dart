/// Custom exceptions thrown by data sources and remote clients.
class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({required this.message, this.code});

  @override
  String toString() => 'ServerException(code: $code, message: $message)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException(message: $message)';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}

class ConflictException implements Exception {
  final String message;

  const ConflictException({required this.message});

  @override
  String toString() => 'ConflictException(message: $message)';
}

class StorageException implements Exception {
  final String message;

  const StorageException({required this.message});

  @override
  String toString() => 'StorageException(message: $message)';
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({required this.message});

  @override
  String toString() => 'ValidationException(message: $message)';
}
