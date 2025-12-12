import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';
import 'story_event.dart';
import 'story_state.dart';

/// Story Bloc - State Management with Clean Architecture
/// Uses Use Cases to interact with domain layer
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final GetAvailableModels _getAvailableModels;
  final GenerateStory _generateStory;
  final StreamStory _streamStory;
  final IllustrateScene _illustrateScene;
  final NarrateText _narrateText;
  final SaveStory _saveStory;
  final GetStoryHistory _getStoryHistory;
  final GetStory _getStory;
  final DeleteStory _deleteStory;

  StreamSubscription<String>? _streamSubscription;

  StoryBloc({
    required GetAvailableModels getAvailableModels,
    required GenerateStory generateStory,
    required StreamStory streamStory,
    required IllustrateScene illustrateScene,
    required NarrateText narrateText,
    required SaveStory saveStory,
    required GetStoryHistory getStoryHistory,
    required GetStory getStory,
    required DeleteStory deleteStory,
  }) : _getAvailableModels = getAvailableModels,
       _generateStory = generateStory,
       _streamStory = streamStory,
       _illustrateScene = illustrateScene,
       _narrateText = narrateText,
       _saveStory = saveStory,
       _getStoryHistory = getStoryHistory,
       _getStory = getStory,
       _deleteStory = deleteStory,
       super(const StoryState()) {
    // Register event handlers
    on<LoadModelsEvent>(_onLoadModels);
    on<SelectModelEvent>(_onSelectModel);
    on<SelectGenreEvent>(_onSelectGenre);
    on<SelectVoiceEvent>(_onSelectVoice);
    on<SelectImageStyleEvent>(_onSelectImageStyle);
    on<GenerateStoryEvent>(_onGenerateStory);
    on<StreamStoryEvent>(_onStreamStory);
    on<UpdateStreamingContentEvent>(_onUpdateStreamingContent);
    on<StreamingCompleteEvent>(_onStreamingComplete);
    on<GenerateIllustrationEvent>(_onGenerateIllustration);
    on<GenerateNarrationEvent>(_onGenerateNarration);
    on<SaveStoryEvent>(_onSaveStory);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<LoadStoryEvent>(_onLoadStory);
    on<DeleteStoryEvent>(_onDeleteStory);
    on<ClearConversationEvent>(_onClearConversation);
    on<NewStoryEvent>(_onNewStory);
  }

  /// Load available AI models
  Future<void> _onLoadModels(LoadModelsEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(status: StoryStatus.loadingModels, clearError: true));

    try {
      final models = await _getAvailableModels(const NoParams());
      emit(
        state.copyWith(
          status: StoryStatus.success,
          availableModels: models,
          selectedModel: models.isNotEmpty ? models.first.id : 'gpt-4o-mini',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
    }
  }

  /// Select AI model
  void _onSelectModel(SelectModelEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(selectedModel: event.modelId));
  }

  /// Select genre
  void _onSelectGenre(SelectGenreEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(selectedGenre: event.genre));
  }

  /// Select TTS voice
  void _onSelectVoice(SelectVoiceEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(selectedVoice: event.voice));
  }

  /// Select image style
  void _onSelectImageStyle(SelectImageStyleEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(selectedImageStyle: event.style));
  }

  /// Generate story (non-streaming)
  Future<void> _onGenerateStory(
    GenerateStoryEvent event,
    Emitter<StoryState> emit,
  ) async {
    emit(state.copyWith(status: StoryStatus.generating, clearError: true));

    // Add user message
    final userMessage = ChatMessage.user(event.prompt);
    final updatedMessages = [...state.messages, userMessage];
    emit(state.copyWith(messages: updatedMessages));

    try {
      final response = await _generateStory(
        GenerateStoryParams(
          prompt: event.prompt,
          history: state.messages,
          model: state.selectedModel,
          genre: state.selectedGenre,
        ),
      );

      if (response.success && response.content != null) {
        final assistantMessage = ChatMessage.assistant(response.content!);
        emit(
          state.copyWith(
            status: StoryStatus.success,
            messages: [...updatedMessages, assistantMessage],
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: StoryStatus.error,
            errorMessage: response.error ?? 'Failed to generate story',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
    }
  }

  /// Stream story generation
  Future<void> _onStreamStory(StreamStoryEvent event, Emitter<StoryState> emit) async {
    // Cancel any existing stream
    await _streamSubscription?.cancel();

    emit(
      state.copyWith(
        status: StoryStatus.streaming,
        isStreaming: true,
        streamingContent: '',
        clearError: true,
      ),
    );

    // Add user message
    final userMessage = ChatMessage.user(event.prompt);
    final updatedMessages = [...state.messages, userMessage];
    emit(state.copyWith(messages: updatedMessages));

    try {
      final stream = _streamStory(
        StreamStoryParams(
          prompt: event.prompt,
          history: state.messages,
          model: state.selectedModel,
          genre: state.selectedGenre,
        ),
      );

      String fullContent = '';

      _streamSubscription = stream.listen(
        (chunk) {
          fullContent += chunk;
          add(UpdateStreamingContentEvent(fullContent));
        },
        onDone: () {
          add(const StreamingCompleteEvent());
        },
        onError: (error) {
          emit(
            state.copyWith(
              status: StoryStatus.error,
              isStreaming: false,
              errorMessage: error.toString(),
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StoryStatus.error,
          isStreaming: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update streaming content
  void _onUpdateStreamingContent(
    UpdateStreamingContentEvent event,
    Emitter<StoryState> emit,
  ) {
    emit(state.copyWith(streamingContent: event.content));
  }

  /// Streaming completed
  void _onStreamingComplete(StreamingCompleteEvent event, Emitter<StoryState> emit) {
    if (state.streamingContent.isNotEmpty) {
      final assistantMessage = ChatMessage.assistant(state.streamingContent);
      emit(
        state.copyWith(
          status: StoryStatus.success,
          isStreaming: false,
          messages: [...state.messages, assistantMessage],
          streamingContent: '',
        ),
      );
    } else {
      emit(state.copyWith(status: StoryStatus.success, isStreaming: false));
    }
  }

  /// Generate illustration
  Future<void> _onGenerateIllustration(
    GenerateIllustrationEvent event,
    Emitter<StoryState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StoryStatus.generatingImage,
        clearError: true,
        clearImage: true,
      ),
    );

    try {
      final response = await _illustrateScene(
        IllustrateSceneParams(
          sceneDescription: event.sceneDescription,
          style: event.style ?? state.selectedImageStyle,
        ),
      );

      if (response.success && response.imageBase64 != null) {
        emit(
          state.copyWith(
            status: StoryStatus.success,
            currentImageBase64: response.imageBase64,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: StoryStatus.error,
            errorMessage: response.error ?? 'Failed to generate image',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
    }
  }

  /// Generate narration
  Future<void> _onGenerateNarration(
    GenerateNarrationEvent event,
    Emitter<StoryState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StoryStatus.generatingAudio,
        clearError: true,
        clearAudio: true,
      ),
    );

    try {
      final response = await _narrateText(
        NarrateTextParams(text: event.text, voice: event.voice ?? state.selectedVoice),
      );

      emit(
        state.copyWith(
          status: StoryStatus.success,
          currentAudioBase64: response.audioBase64,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
    }
  }

  /// Save story
  Future<void> _onSaveStory(SaveStoryEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(status: StoryStatus.saving, clearError: true));

    try {
      final story = Story(
        title: event.title,
        content: state.fullStoryContent,
        genre: state.selectedGenre,
        modelUsed: state.selectedModel,
        wordCount: state.wordCount,
      );

      await _saveStory(story);

      emit(state.copyWith(status: StoryStatus.success));

      // Reload history
      add(const LoadHistoryEvent());
    } catch (e) {
      emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
    }
  }

  /// Load history
  Future<void> _onLoadHistory(LoadHistoryEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(status: StoryStatus.loadingHistory, clearError: true));

    try {
      final stories = await _getStoryHistory(const NoParams());
      emit(state.copyWith(status: StoryStatus.success, storyHistory: stories));
    } catch (e) {
      emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
    }
  }

  /// Load specific story
  Future<void> _onLoadStory(LoadStoryEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(status: StoryStatus.loading, clearError: true));

    try {
      final story = await _getStory(event.storyId);

      // Convert story to messages
      final messages = [ChatMessage.assistant(story.content)];

      emit(
        state.copyWith(
          status: StoryStatus.success,
          messages: messages,
          selectedGenre: story.genre,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
    }
  }

  /// Delete story
  Future<void> _onDeleteStory(DeleteStoryEvent event, Emitter<StoryState> emit) async {
    try {
      await _deleteStory(event.storyId);
      add(const LoadHistoryEvent());
    } catch (e) {
      emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
    }
  }

  /// Clear conversation
  void _onClearConversation(ClearConversationEvent event, Emitter<StoryState> emit) {
    emit(
      state.copyWith(
        messages: [],
        streamingContent: '',
        isStreaming: false,
        clearImage: true,
        clearAudio: true,
      ),
    );
  }

  /// Start new story
  void _onNewStory(NewStoryEvent event, Emitter<StoryState> emit) {
    emit(const StoryState());
    add(const LoadModelsEvent());
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
