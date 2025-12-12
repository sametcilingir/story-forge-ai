import 'package:equatable/equatable.dart';

/// StoryGenerationResult - Result of story generation
class StoryGenerationResult extends Equatable {
  final bool success;
  final String? content;
  final String? error;
  final String model;
  final List<String>? toolsUsed;
  final Map<String, int>? usage;

  const StoryGenerationResult({
    required this.success,
    this.content,
    this.error,
    required this.model,
    this.toolsUsed,
    this.usage,
  });

  @override
  List<Object?> get props => [success, content, error, model, toolsUsed, usage];
}

/// ImageGenerationResult - Result of image generation
class ImageGenerationResult extends Equatable {
  final bool success;
  final String? imageBase64;
  final String? error;
  final String? revisedPrompt;
  final String? style;

  const ImageGenerationResult({
    required this.success,
    this.imageBase64,
    this.error,
    this.revisedPrompt,
    this.style,
  });

  @override
  List<Object?> get props => [success, imageBase64, error, revisedPrompt, style];
}

/// AudioNarrationResult - Result of audio narration generation
class AudioNarrationResult extends Equatable {
  final String audioBase64;
  final String format;

  const AudioNarrationResult({required this.audioBase64, this.format = 'mp3'});

  @override
  List<Object?> get props => [audioBase64, format];
}
