import '../../core/usecases/usecase.dart';
import '../entities/story.dart';
import '../repositories/story_repository.dart';

/// Get Story Use Case
class GetStory implements UseCase<Story, int> {
  final StoryRepository repository;

  GetStory(this.repository);

  @override
  Future<Story> call(int storyId) {
    return repository.getStory(storyId);
  }
}

