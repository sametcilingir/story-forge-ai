import '../../core/usecases/usecase.dart';
import '../entities/story.dart';
import '../repositories/story_repository.dart';

/// Save Story Use Case
class SaveStory implements UseCase<int, Story> {
  final StoryRepository repository;

  SaveStory(this.repository);

  @override
  Future<int> call(Story story) {
    return repository.saveStory(story);
  }
}

