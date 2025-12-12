import 'package:equatable/equatable.dart';

/// ChatMessage Entity - Represents a conversation message
/// Domain layer - pure business logic
class ChatMessage extends Equatable {
  final String role;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;
  final String? audioBase64;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.imageUrl,
    this.audioBase64,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String content) {
    return ChatMessage(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.assistant(
    String content, {
    String? imageUrl,
    String? audioBase64,
  }) {
    return ChatMessage(
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      audioBase64: audioBase64,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get hasImage => imageUrl != null;
  bool get hasAudio => audioBase64 != null;

  @override
  List<Object?> get props => [role, content, timestamp, imageUrl, audioBase64];
}

