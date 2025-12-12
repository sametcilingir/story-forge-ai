import 'package:equatable/equatable.dart';

/// Base Use Case interface
/// Following Clean Architecture principles
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Use this when use case doesn't need any parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
