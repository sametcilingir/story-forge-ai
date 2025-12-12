import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/models.dart';

/// Story Remote Data Source Interface
abstract class StoryRemoteDataSource {
  Future<List<AIModelModel>> getAvailableModels();
  Future<StoryGenerationResponseModel> generateStory({
    required String prompt,
    required List<ChatMessageModel> history,
    String model,
    String genre,
  });
  Stream<String> streamStory({
    required String prompt,
    required List<ChatMessageModel> history,
    String model,
    String genre,
  });
  Future<ImageGenerationResponseModel> illustrateScene({
    required String sceneDescription,
    String style,
  });
  Future<AudioNarrationResponseModel> narrateText({required String text, String voice});
  Future<int> saveStory(StoryModel story);
  Future<List<StoryModel>> getStoryHistory();
  Future<StoryModel> getStory(int storyId);
  Future<bool> deleteStory(int storyId);
}

/// Story Remote Data Source Implementation using Dio
class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final Dio _dio;

  StoryRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );

    return dio;
  }

  @override
  Future<List<AIModelModel>> getAvailableModels() async {
    try {
      final response = await _dio.get(ApiConstants.models);
      final models = (response.data['models'] as List)
          .map((m) => AIModelModel.fromJson(m as Map<String, dynamic>))
          .toList();
      return models;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<StoryGenerationResponseModel> generateStory({
    required String prompt,
    required List<ChatMessageModel> history,
    String model = 'gpt-4o-mini',
    String genre = 'fantasy',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.generateStory,
        data: {
          'prompt': prompt,
          'history': history.map((m) => m.toJson()).toList(),
          'model': model,
          'genre': genre,
        },
      );
      return StoryGenerationResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Stream<String> streamStory({
    required String prompt,
    required List<ChatMessageModel> history,
    String model = 'gpt-4o-mini',
    String genre = 'fantasy',
  }) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        ApiConstants.generateStoryStream,
        data: {
          'prompt': prompt,
          'history': history.map((m) => m.toJson()).toList(),
          'model': model,
          'genre': genre,
        },
        options: Options(responseType: ResponseType.stream),
      );

      await for (final chunk in response.data!.stream) {
        final data = String.fromCharCodes(chunk);
        for (final line in data.split('\n')) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            if (jsonStr == '[DONE]') {
              return;
            }
            try {
              final json = _parseJson(jsonStr);
              if (json != null && json['content'] != null) {
                yield json['content'] as String;
              }
            } catch (_) {
              // Skip invalid JSON
            }
          }
        }
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ImageGenerationResponseModel> illustrateScene({
    required String sceneDescription,
    String style = 'digital fantasy art, vibrant colors',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.illustrateStory,
        data: {'scene_description': sceneDescription, 'style': style},
      );
      return ImageGenerationResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AudioNarrationResponseModel> narrateText({
    required String text,
    String voice = 'onyx',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.narrateStory,
        data: {'text': text, 'voice': voice},
      );
      return AudioNarrationResponseModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<int> saveStory(StoryModel story) async {
    try {
      final response = await _dio.post(
        ApiConstants.saveStory,
        data: {
          'title': story.title,
          'content': story.content,
          'genre': story.genre,
          'model_used': story.modelUsed,
        },
      );
      return response.data['story_id'] as int;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<StoryModel>> getStoryHistory() async {
    try {
      final response = await _dio.get(ApiConstants.storyHistory);
      final stories = (response.data['stories'] as List)
          .map((s) => StoryModel.fromJson(s as Map<String, dynamic>))
          .toList();
      return stories;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<StoryModel> getStory(int storyId) async {
    try {
      final response = await _dio.get('/api/story/$storyId');
      return StoryModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<bool> deleteStory(int storyId) async {
    try {
      final response = await _dio.delete('/api/story/$storyId');
      return response.data['success'] as bool;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic>? _parseJson(String jsonStr) {
    try {
      if (jsonStr.contains('"content"')) {
        final match = RegExp(r'"content"\s*:\s*"([^"]*)"').firstMatch(jsonStr);
        if (match != null) {
          return {'content': match.group(1)};
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutException(
            message: 'Connection timed out. Please try again.',
          );
        case DioExceptionType.connectionError:
          return const NetworkException(
            message:
                'Cannot connect to server. Make sure the backend is running on port 5001.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 403) {
            final serverHeader = error.response?.headers.value('server');
            if (serverHeader?.contains('AirTunes') == true) {
              return const NetworkException(
                message:
                    'Network routing error. The request was intercepted. Please check your network configuration.',
              );
            }
            return ServerException(
              message: 'Access forbidden. Please check backend CORS settings.',
              statusCode: statusCode,
            );
          }
          dynamic errorData = error.response?.data;
          String message = 'Unknown error';
          if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
            message = errorData['error'].toString();
          } else if (errorData is String) {
            message = errorData;
          }
          return ServerException(message: message, statusCode: statusCode);
        default:
          return NetworkException(message: 'Network error: ${error.message}');
      }
    }
    return ServerException(message: 'Unexpected error: $error');
  }
}
