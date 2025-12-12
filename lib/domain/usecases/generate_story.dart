import 'package:equatable/equatable.dart';
import '../../core/usecases/usecase.dart';
import '../entities/chat_message.dart';
import '../entities/generation_response.dart';
import '../repositories/story_repository.dart';

/// Generate Story Use Case
class GenerateStory implements UseCase<StoryGenerationResult, GenerateStoryParams> {
  final StoryRepository repository;

  GenerateStory(this.repository);

  @override
  Future<StoryGenerationResult> call(GenerateStoryParams params) {
    return repository.generateStory(
      prompt: params.prompt,
      history: params.history,
      model: params.model,
      genre: params.genre,
    );
  }
}

class GenerateStoryParams extends Equatable {
  final String prompt;
  final List<ChatMessage> history;
  final String model;
  final String genre;

  const GenerateStoryParams({
    required this.prompt,
    required this.history,
    this.model = 'gpt-4o-mini',
    this.genre = 'fantasy',
  });

  @override
  List<Object?> get props => [prompt, history, model, genre];
}

