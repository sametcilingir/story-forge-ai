import '../../domain/entities/generation_response.dart';

/// Story Generation Response Model
class StoryGenerationResponseModel {
  final bool success;
  final String? content;
  final String? error;
  final String model;
  final List<String>? toolsUsed;
  final Map<String, int>? usage;

  const StoryGenerationResponseModel({
    required this.success,
    this.content,
    this.error,
    required this.model,
    this.toolsUsed,
    this.usage,
  });

  factory StoryGenerationResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, int>? usageMap;
    if (json['usage'] != null) {
      final usageData = json['usage'] as Map<String, dynamic>?;
      if (usageData != null) {
        usageMap = usageData.map((key, value) => MapEntry(
              key,
              value is int ? value : (value is num ? value.toInt() : 0),
            ));
      }
    }

    return StoryGenerationResponseModel(
      success: json['success'] as bool? ?? false,
      content: json['content'] as String?,
      error: json['error'] as String?,
      model: json['model'] as String? ?? 'unknown',
      toolsUsed: (json['tools_used'] as List<dynamic>?)?.cast<String>(),
      usage: usageMap,
    );
  }

  StoryGenerationResult toEntity() {
    return StoryGenerationResult(
      success: success,
      content: content,
      error: error,
      model: model,
      toolsUsed: toolsUsed,
      usage: usage,
    );
  }
}

/// Image Generation Response Model
class ImageGenerationResponseModel {
  final bool success;
  final String? imageBase64;
  final String? error;
  final String? revisedPrompt;
  final String? style;

  const ImageGenerationResponseModel({
    required this.success,
    this.imageBase64,
    this.error,
    this.revisedPrompt,
    this.style,
  });

  factory ImageGenerationResponseModel.fromJson(Map<String, dynamic> json) {
    return ImageGenerationResponseModel(
      success: json['success'] as bool? ?? false,
      imageBase64: json['image_base64'] as String?,
      error: json['error'] as String?,
      revisedPrompt: json['revised_prompt'] as String?,
      style: json['style'] as String?,
    );
  }

  ImageGenerationResult toEntity() {
    return ImageGenerationResult(
      success: success,
      imageBase64: imageBase64,
      error: error,
      revisedPrompt: revisedPrompt,
      style: style,
    );
  }
}

/// Audio Narration Response Model
class AudioNarrationResponseModel {
  final String audioBase64;
  final String format;

  const AudioNarrationResponseModel({
    required this.audioBase64,
    this.format = 'mp3',
  });

  factory AudioNarrationResponseModel.fromJson(Map<String, dynamic> json) {
    return AudioNarrationResponseModel(
      audioBase64: json['audio_base64'] as String,
      format: json['format'] as String? ?? 'mp3',
    );
  }

  AudioNarrationResult toEntity() {
    return AudioNarrationResult(
      audioBase64: audioBase64,
      format: format,
    );
  }
}

