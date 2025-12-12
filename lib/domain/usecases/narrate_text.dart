import 'package:equatable/equatable.dart';
import '../../core/usecases/usecase.dart';
import '../entities/generation_response.dart';
import '../repositories/story_repository.dart';

/// Narrate Text Use Case
class NarrateText implements UseCase<AudioNarrationResult, NarrateTextParams> {
  final StoryRepository repository;

  NarrateText(this.repository);

  @override
  Future<AudioNarrationResult> call(NarrateTextParams params) {
    return repository.narrateText(
      text: params.text,
      voice: params.voice,
    );
  }
}

class NarrateTextParams extends Equatable {
  final String text;
  final String voice;

  const NarrateTextParams({
    required this.text,
    this.voice = 'onyx',
  });

  @override
  List<Object?> get props => [text, voice];
}

