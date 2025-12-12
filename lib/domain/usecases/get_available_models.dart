import '../../core/usecases/usecase.dart';
import '../entities/ai_model.dart';
import '../repositories/story_repository.dart';

/// Get Available Models Use Case
class GetAvailableModels implements UseCase<List<AIModel>, NoParams> {
  final StoryRepository repository;

  GetAvailableModels(this.repository);

  @override
  Future<List<AIModel>> call(NoParams params) {
    return repository.getAvailableModels();
  }
}

