/// Custom Exceptions for the application
/// Core layer - shared across all layers

/// Server Exception - thrown when server returns an error
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({this.message = 'Server error occurred', this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Network Exception - thrown when network is unavailable
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Network error occurred'});

  @override
  String toString() => 'NetworkException: $message';
}

/// Cache Exception - thrown when cache operation fails
class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

/// Timeout Exception - thrown when operation times out
class TimeoutException implements Exception {
  final String message;

  const TimeoutException({this.message = 'Operation timed out'});

  @override
  String toString() => 'TimeoutException: $message';
}

/// Validation Exception - thrown when validation fails
class ValidationException implements Exception {
  final String message;

  const ValidationException({this.message = 'Validation failed'});

  @override
  String toString() => 'ValidationException: $message';
}
