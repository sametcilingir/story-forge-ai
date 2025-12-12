import 'package:equatable/equatable.dart';
import '../entities/chat_message.dart';
import '../repositories/story_repository.dart';

/// Stream Story Use Case
/// Returns a Stream instead of Future for real-time updates
class StreamStory {
  final StoryRepository repository;

  StreamStory(this.repository);

  Stream<String> call(StreamStoryParams params) {
    return repository.streamStory(
      prompt: params.prompt,
      history: params.history,
      model: params.model,
      genre: params.genre,
    );
  }
}

class StreamStoryParams extends Equatable {
  final String prompt;
  final List<ChatMessage> history;
  final String model;
  final String genre;

  const StreamStoryParams({
    required this.prompt,
    required this.history,
    this.model = 'gpt-4o-mini',
    this.genre = 'fantasy',
  });

  @override
  List<Object?> get props => [prompt, history, model, genre];
}

