import 'package:equatable/equatable.dart';

/// Story Events for Bloc Pattern
/// Clean Architecture - Events trigger state changes through use cases
abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load available AI models
class LoadModelsEvent extends StoryEvent {
  const LoadModelsEvent();
}

/// Change selected AI model
class SelectModelEvent extends StoryEvent {
  final String modelId;

  const SelectModelEvent(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

/// Change story genre
class SelectGenreEvent extends StoryEvent {
  final String genre;

  const SelectGenreEvent(this.genre);

  @override
  List<Object?> get props => [genre];
}

/// Generate story continuation
class GenerateStoryEvent extends StoryEvent {
  final String prompt;

  const GenerateStoryEvent(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

/// Stream story generation (real-time)
class StreamStoryEvent extends StoryEvent {
  final String prompt;

  const StreamStoryEvent(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

/// Generate illustration for current scene
class GenerateIllustrationEvent extends StoryEvent {
  final String sceneDescription;
  final String? style;

  const GenerateIllustrationEvent(this.sceneDescription, {this.style});

  @override
  List<Object?> get props => [sceneDescription, style];
}

/// Generate audio narration
class GenerateNarrationEvent extends StoryEvent {
  final String text;
  final String? voice;

  const GenerateNarrationEvent(this.text, {this.voice});

  @override
  List<Object?> get props => [text, voice];
}

/// Save current story
class SaveStoryEvent extends StoryEvent {
  final String title;

  const SaveStoryEvent(this.title);

  @override
  List<Object?> get props => [title];
}

/// Load story history
class LoadHistoryEvent extends StoryEvent {
  const LoadHistoryEvent();
}

/// Load a specific story
class LoadStoryEvent extends StoryEvent {
  final int storyId;

  const LoadStoryEvent(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

/// Delete a story
class DeleteStoryEvent extends StoryEvent {
  final int storyId;

  const DeleteStoryEvent(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

/// Clear current conversation
class ClearConversationEvent extends StoryEvent {
  const ClearConversationEvent();
}

/// Start a new story
class NewStoryEvent extends StoryEvent {
  const NewStoryEvent();
}

/// Update streaming content (internal)
class UpdateStreamingContentEvent extends StoryEvent {
  final String content;

  const UpdateStreamingContentEvent(this.content);

  @override
  List<Object?> get props => [content];
}

/// Streaming completed (internal)
class StreamingCompleteEvent extends StoryEvent {
  const StreamingCompleteEvent();
}

/// Change TTS voice
class SelectVoiceEvent extends StoryEvent {
  final String voice;

  const SelectVoiceEvent(this.voice);

  @override
  List<Object?> get props => [voice];
}

/// Change image style
class SelectImageStyleEvent extends StoryEvent {
  final String style;

  const SelectImageStyleEvent(this.style);

  @override
  List<Object?> get props => [style];
}
