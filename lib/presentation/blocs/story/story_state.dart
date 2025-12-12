import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

/// Story State for Bloc Pattern
/// Immutable state with copyWith for easy updates
class StoryState extends Equatable {
  // Status flags
  final StoryStatus status;
  final String? errorMessage;

  // AI Models
  final List<AIModel> availableModels;
  final String selectedModel;

  // Story settings
  final String selectedGenre;
  final String selectedVoice;
  final String selectedImageStyle;

  // Conversation
  final List<ChatMessage> messages;
  final String streamingContent;
  final bool isStreaming;

  // Generated content
  final String? currentImageBase64;
  final String? currentAudioBase64;

  // History
  final List<Story> storyHistory;

  const StoryState({
    this.status = StoryStatus.initial,
    this.errorMessage,
    this.availableModels = const [],
    this.selectedModel = 'gpt-4o-mini',
    this.selectedGenre = 'fantasy',
    this.selectedVoice = 'onyx',
    this.selectedImageStyle = 'digital fantasy art, vibrant colors',
    this.messages = const [],
    this.streamingContent = '',
    this.isStreaming = false,
    this.currentImageBase64,
    this.currentAudioBase64,
    this.storyHistory = const [],
  });

  /// Get the full story content from all assistant messages
  String get fullStoryContent {
    return messages.where((m) => m.isAssistant).map((m) => m.content).join('\n\n');
  }

  /// Get word count of the full story
  int get wordCount {
    return fullStoryContent.split(RegExp(r'\s+')).length;
  }

  /// Check if there's an active conversation
  bool get hasConversation => messages.isNotEmpty;

  /// Check if models are loaded
  bool get hasModels => availableModels.isNotEmpty;

  /// Get the last assistant message
  ChatMessage? get lastAssistantMessage {
    try {
      return messages.lastWhere((m) => m.isAssistant);
    } catch (_) {
      return null;
    }
  }

  StoryState copyWith({
    StoryStatus? status,
    String? errorMessage,
    List<AIModel>? availableModels,
    String? selectedModel,
    String? selectedGenre,
    String? selectedVoice,
    String? selectedImageStyle,
    List<ChatMessage>? messages,
    String? streamingContent,
    bool? isStreaming,
    String? currentImageBase64,
    String? currentAudioBase64,
    List<Story>? storyHistory,
    bool clearError = false,
    bool clearImage = false,
    bool clearAudio = false,
  }) {
    return StoryState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      availableModels: availableModels ?? this.availableModels,
      selectedModel: selectedModel ?? this.selectedModel,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      selectedImageStyle: selectedImageStyle ?? this.selectedImageStyle,
      messages: messages ?? this.messages,
      streamingContent: streamingContent ?? this.streamingContent,
      isStreaming: isStreaming ?? this.isStreaming,
      currentImageBase64: clearImage
          ? null
          : (currentImageBase64 ?? this.currentImageBase64),
      currentAudioBase64: clearAudio
          ? null
          : (currentAudioBase64 ?? this.currentAudioBase64),
      storyHistory: storyHistory ?? this.storyHistory,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    availableModels,
    selectedModel,
    selectedGenre,
    selectedVoice,
    selectedImageStyle,
    messages,
    streamingContent,
    isStreaming,
    currentImageBase64,
    currentAudioBase64,
    storyHistory,
  ];
}

/// Story Status enum
enum StoryStatus {
  initial,
  loading,
  loadingModels,
  generating,
  streaming,
  generatingImage,
  generatingAudio,
  saving,
  loadingHistory,
  success,
  error,
}

/// Extension for status checks
extension StoryStatusX on StoryStatus {
  bool get isLoading =>
      this == StoryStatus.loading ||
      this == StoryStatus.loadingModels ||
      this == StoryStatus.generating ||
      this == StoryStatus.streaming ||
      this == StoryStatus.generatingImage ||
      this == StoryStatus.generatingAudio ||
      this == StoryStatus.saving ||
      this == StoryStatus.loadingHistory;

  bool get isGenerating =>
      this == StoryStatus.generating || this == StoryStatus.streaming;

  bool get isIdle => this == StoryStatus.initial || this == StoryStatus.success;
}
