import 'package:equatable/equatable.dart';

/// Story Entity - Core business object
/// Domain layer - independent of any external framework
class Story extends Equatable {
  final int? id;
  final String title;
  final String content;
  final String genre;
  final String modelUsed;
  final DateTime? createdAt;
  final int wordCount;
  final bool isFavorite;

  const Story({
    this.id,
    required this.title,
    required this.content,
    this.genre = 'fantasy',
    this.modelUsed = 'gpt-4o-mini',
    this.createdAt,
    this.wordCount = 0,
    this.isFavorite = false,
  });

  Story copyWith({
    int? id,
    String? title,
    String? content,
    String? genre,
    String? modelUsed,
    DateTime? createdAt,
    int? wordCount,
    bool? isFavorite,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      genre: genre ?? this.genre,
      modelUsed: modelUsed ?? this.modelUsed,
      createdAt: createdAt ?? this.createdAt,
      wordCount: wordCount ?? this.wordCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    genre,
    modelUsed,
    createdAt,
    wordCount,
    isFavorite,
  ];
}
