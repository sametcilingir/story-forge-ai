import 'package:equatable/equatable.dart';

/// Failure classes for error handling
/// Used with Either type for functional error handling

abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = 'An error occurred'});

  @override
  List<Object?> get props => [message];
}

/// Server Failure
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({super.message = 'Server error', this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network error'});
}

/// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error'});
}

/// Timeout Failure
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out'});
}

/// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation failed'});
}

/// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Unknown error occurred'});
}

