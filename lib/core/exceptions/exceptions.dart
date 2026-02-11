/// Custom exception for authentication-related errors.
class AuthenticationException implements Exception {

  AuthenticationException(this.message);
  final String message;

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Custom exception for storage-related errors.
class StorageException implements Exception {

  StorageException(this.message);
  final String message;

  @override
  String toString() => 'StorageException: $message';
}

/// Custom exception for general application errors.
class AppException implements Exception {

  AppException(this.message);
  final String message;

  @override
  String toString() => 'AppException: $message';
}
