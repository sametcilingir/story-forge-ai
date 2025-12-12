import '../../domain/entities/ai_model.dart';

/// AIModel Model - Data layer representation
/// Handles JSON serialization and conversion to/from domain entity
class AIModelModel {
  final String id;
  final String name;
  final String provider;

  const AIModelModel({
    required this.id,
    required this.name,
    required this.provider,
  });

  /// Convert from JSON
  factory AIModelModel.fromJson(Map<String, dynamic> json) {
    return AIModelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
    };
  }

  /// Convert to domain entity
  AIModel toEntity() {
    return AIModel(
      id: id,
      name: name,
      provider: provider,
    );
  }

  /// Convert from domain entity
  factory AIModelModel.fromEntity(AIModel entity) {
    return AIModelModel(
      id: entity.id,
      name: entity.name,
      provider: entity.provider,
    );
  }
}

