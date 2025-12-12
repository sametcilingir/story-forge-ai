import '../../core/usecases/usecase.dart';
import '../repositories/story_repository.dart';

/// Delete Story Use Case
class DeleteStory implements UseCase<bool, int> {
  final StoryRepository repository;

  DeleteStory(this.repository);

  @override
  Future<bool> call(int storyId) {
    return repository.deleteStory(storyId);
  }
}

