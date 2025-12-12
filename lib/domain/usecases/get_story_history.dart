import '../../core/usecases/usecase.dart';
import '../entities/story.dart';
import '../repositories/story_repository.dart';

/// Get Story History Use Case
class GetStoryHistory implements UseCase<List<Story>, NoParams> {
  final StoryRepository repository;

  GetStoryHistory(this.repository);

  @override
  Future<List<Story>> call(NoParams params) {
    return repository.getStoryHistory();
  }
}

