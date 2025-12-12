import '../../domain/entities/entities.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/story_remote_datasource.dart';
import '../models/models.dart';

/// Story Repository Implementation
/// Data layer - implements the domain repository interface
class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource remoteDataSource;

  StoryRepositoryImpl({StoryRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? StoryRemoteDataSourceImpl();

  @override
  Future<List<AIModel>> getAvailableModels() async {
    final models = await remoteDataSource.getAvailableModels();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<StoryGenerationResult> generateStory({
    required String prompt,
    required List<ChatMessage> history,
    String model = 'gpt-4o-mini',
    String genre = 'fantasy',
  }) async {
    final historyModels =
        history.map((m) => ChatMessageModel.fromEntity(m)).toList();
    final response = await remoteDataSource.generateStory(
      prompt: prompt,
      history: historyModels,
      model: model,
      genre: genre,
    );
    return response.toEntity();
  }

  @override
  Stream<String> streamStory({
    required String prompt,
    required List<ChatMessage> history,
    String model = 'gpt-4o-mini',
    String genre = 'fantasy',
  }) {
    final historyModels =
        history.map((m) => ChatMessageModel.fromEntity(m)).toList();
    return remoteDataSource.streamStory(
      prompt: prompt,
      history: historyModels,
      model: model,
      genre: genre,
    );
  }

  @override
  Future<ImageGenerationResult> illustrateScene({
    required String sceneDescription,
    String style = 'digital fantasy art, vibrant colors',
  }) async {
    final response = await remoteDataSource.illustrateScene(
      sceneDescription: sceneDescription,
      style: style,
    );
    return response.toEntity();
  }

  @override
  Future<AudioNarrationResult> narrateText({
    required String text,
    String voice = 'onyx',
  }) async {
    final response = await remoteDataSource.narrateText(
      text: text,
      voice: voice,
    );
    return response.toEntity();
  }

  @override
  Future<int> saveStory(Story story) async {
    final storyModel = StoryModel.fromEntity(story);
    return remoteDataSource.saveStory(storyModel);
  }

  @override
  Future<List<Story>> getStoryHistory() async {
    final stories = await remoteDataSource.getStoryHistory();
    return stories.map((s) => s.toEntity()).toList();
  }

  @override
  Future<Story> getStory(int storyId) async {
    final story = await remoteDataSource.getStory(storyId);
    return story.toEntity();
  }

  @override
  Future<bool> deleteStory(int storyId) {
    return remoteDataSource.deleteStory(storyId);
  }
}

