import 'package:equatable/equatable.dart';
import '../../core/usecases/usecase.dart';
import '../entities/generation_response.dart';
import '../repositories/story_repository.dart';

/// Illustrate Scene Use Case
class IllustrateScene implements UseCase<ImageGenerationResult, IllustrateSceneParams> {
  final StoryRepository repository;

  IllustrateScene(this.repository);

  @override
  Future<ImageGenerationResult> call(IllustrateSceneParams params) {
    return repository.illustrateScene(
      sceneDescription: params.sceneDescription,
      style: params.style,
    );
  }
}

class IllustrateSceneParams extends Equatable {
  final String sceneDescription;
  final String style;

  const IllustrateSceneParams({
    required this.sceneDescription,
    this.style = 'digital fantasy art, vibrant colors',
  });

  @override
  List<Object?> get props => [sceneDescription, style];
}
