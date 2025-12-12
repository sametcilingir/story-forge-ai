import '../entities/entities.dart';

/// Story Repository Interface - Domain layer contract
/// This defines what operations are available without specifying how they are implemented
abstract class StoryRepository {
  /// Get available AI models
  Future<List<AIModel>> getAvailableModels();

  /// Generate story continuation (non-streaming)
  Future<StoryGenerationResult> generateStory({
    required String prompt,
    required List<ChatMessage> history,
    String model = 'gpt-4o-mini',
    String genre = 'fantasy',
  });

  /// Stream story generation
  Stream<String> streamStory({
    required String prompt,
    required List<ChatMessage> history,
    String model = 'gpt-4o-mini',
    String genre = 'fantasy',
  });

  /// Generate illustration for a scene
  Future<ImageGenerationResult> illustrateScene({
    required String sceneDescription,
    String style = 'digital fantasy art, vibrant colors',
  });

  /// Generate audio narration
  Future<AudioNarrationResult> narrateText({required String text, String voice = 'onyx'});

  /// Save story to database
  Future<int> saveStory(Story story);

  /// Get story history
  Future<List<Story>> getStoryHistory();

  /// Get specific story
  Future<Story> getStory(int storyId);

  /// Delete story
  Future<bool> deleteStory(int storyId);
}
