import '../../domain/entities/chat_message.dart';

/// ChatMessage Model - Data layer representation
/// Handles JSON serialization and conversion to/from domain entity
class ChatMessageModel {
  final String role;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;
  final String? audioBase64;

  ChatMessageModel({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.imageUrl,
    this.audioBase64,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convert from JSON
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : DateTime.now(),
      imageUrl: json['image_url'] as String?,
      audioBase64: json['audio_base64'] as String?,
    );
  }

  /// Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  /// Convert from domain entity
  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      role: entity.role,
      content: entity.content,
      timestamp: entity.timestamp,
      imageUrl: entity.imageUrl,
      audioBase64: entity.audioBase64,
    );
  }

  /// Convert to domain entity
  ChatMessage toEntity() {
    return ChatMessage(
      role: role,
      content: content,
      timestamp: timestamp,
      imageUrl: imageUrl,
      audioBase64: audioBase64,
    );
  }
}

