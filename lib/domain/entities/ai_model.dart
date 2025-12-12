import 'package:equatable/equatable.dart';

/// AIModel Entity - Represents an available AI model
/// Domain layer - pure business object
class AIModel extends Equatable {
  final String id;
  final String name;
  final String provider;

  const AIModel({
    required this.id,
    required this.name,
    required this.provider,
  });

  @override
  List<Object?> get props => [id, name, provider];
}

