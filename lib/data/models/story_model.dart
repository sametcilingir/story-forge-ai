import '../../domain/entities/story.dart';

/// Story Model - Data layer representation
/// Handles JSON serialization and conversion to/from domain entity
class StoryModel {
  final int? id;
  final String title;
  final String content;
  final String genre;
  final String modelUsed;
  final DateTime? createdAt;
  final int wordCount;
  final bool isFavorite;

  const StoryModel({
    this.id,
    required this.title,
    required this.content,
    this.genre = 'fantasy',
    this.modelUsed = 'gpt-4o-mini',
    this.createdAt,
    this.wordCount = 0,
    this.isFavorite = false,
  });

  /// Convert from JSON
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as int?,
      title: json['title'] as String? ?? 'Untitled',
      content: json['content'] as String? ?? '',
      genre: json['genre'] as String? ?? 'fantasy',
      modelUsed: json['model_used'] as String? ?? 'unknown',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      wordCount: json['word_count'] as int? ?? 0,
      isFavorite: (json['is_favorite'] as int? ?? 0) == 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'genre': genre,
      'model_used': modelUsed,
      'word_count': wordCount,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// Convert from domain entity
  factory StoryModel.fromEntity(Story entity) {
    return StoryModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      genre: entity.genre,
      modelUsed: entity.modelUsed,
      createdAt: entity.createdAt,
      wordCount: entity.wordCount,
      isFavorite: entity.isFavorite,
    );
  }

  /// Convert to domain entity
  Story toEntity() {
    return Story(
      id: id,
      title: title,
      content: content,
      genre: genre,
      modelUsed: modelUsed,
      createdAt: createdAt,
      wordCount: wordCount,
      isFavorite: isFavorite,
    );
  }
}
