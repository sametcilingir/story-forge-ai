# StoryForge AI: Building a Multi-Modal AI Story Creator with Clean Architecture

## The Beginning: From Single-Model to Multi-Modal AI

After completing Week 1 of the LLM Engineering course, I built AI Job Booster—my first full-stack application with a Python backend and Flutter frontend. It was a huge milestone: I learned FastAPI, CORS, environment variables, and how to integrate OpenAI's API.

But Week 1 used a single model (GPT) for a single task (text analysis). Week 2 challenged me to go further: multiple LLMs, tool calling, and multi-modal AI. I needed a project that would demonstrate all of these concepts while building on what I learned.

**StoryForge AI** became that project. It's not just another chatbot—it's a complete multi-modal story creation platform where users can:
- Generate stories with multiple AI models (GPT-4, Gemini, Claude)
- Create DALL-E illustrations for story scenes
- Generate voice narrations with OpenAI TTS
- Experience AI-powered tool calling for enhanced storytelling

But this time, I also challenged myself architecturally: I implemented **Clean Architecture** with proper separation of concerns, dependency injection, and use cases. This article is the complete story of how I built it.

---

## The Problem: Interactive Storytelling with AI

Storytelling is universal, but creating immersive stories is hard. Writers face creative blocks. Readers want visual and audio experiences. Traditional text-based AI chatbots feel flat.

I wanted to build something that would:
1. **Generate engaging stories** in multiple genres (fantasy, sci-fi, mystery, etc.)
2. **Create visual illustrations** that bring scenes to life
3. **Produce voice narrations** for an audiobook experience
4. **Support multiple AI models** so users can compare and choose
5. **Use tool calling** for intelligent story enhancements
6. **Follow Clean Architecture** for maintainability and testability

This wasn't just a learning project—it was an attempt to create a truly multi-modal AI experience.

---

## Architecture Overview: Clean Architecture

Before diving into code, let me explain the architecture. This is crucial because Week 2 introduced complexity that needed structure.

### System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐ │
│  │   Screens   │──│   Widgets   │──│      BLoC State Mgmt        │ │
│  │             │  │             │  │                             │ │
│  │ StoryScreen │  │MessageBubble│  │  Events → Use Cases → State │ │
│  │HistoryScreen│  │GenreSelector│  │                             │ │
│  └─────────────┘  └─────────────┘  └──────────────┬──────────────┘ │
│                                                    │                │
└────────────────────────────────────────────────────┼────────────────┘
                                                     │
┌────────────────────────────────────────────────────▼────────────────┐
│                       DOMAIN LAYER                                  │
│  ┌─────────────────┐  ┌─────────────────────────────────────────┐  │
│  │    Entities     │  │              Use Cases                  │  │
│  │                 │  │                                         │  │
│  │ • Story         │  │ • GenerateStory    • GetStoryHistory    │  │
│  │ • ChatMessage   │  │ • StreamStory      • SaveStory          │  │
│  │ • AIModel       │  │ • IllustrateScene  • DeleteStory        │  │
│  └─────────────────┘  │ • NarrateText      • GetAvailableModels │  │
│                       └─────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              Repository Interface (Contract)                │   │
│  └─────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────┬────────────────┘
                                                     │
┌────────────────────────────────────────────────────▼────────────────┐
│                        DATA LAYER                                   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                Repository Implementation                     │   │
│  │  • Converts Models ↔ Entities                                │   │
│  │  • Orchestrates data sources                                 │   │
│  └──────────────────────────┬──────────────────────────────────┘   │
│                             │                                       │
│  ┌──────────────────────────▼──────────────────────────────────┐   │
│  │                   Remote Data Source                         │   │
│  │  • Dio HTTP Client                                           │   │
│  │  • JSON parsing                                              │   │
│  │  • Error handling                                            │   │
│  └──────────────────────────┬──────────────────────────────────┘   │
│                             │                                       │
└─────────────────────────────┼───────────────────────────────────────┘
                              │ HTTP/JSON
┌─────────────────────────────▼───────────────────────────────────────┐
│                       FLASK BACKEND                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐  │
│  │   LiteLLM   │  │   DALL-E 3  │  │  OpenAI TTS │  │  SQLite   │  │
│  │  (Multi-LLM)│  │  (Images)   │  │   (Audio)   │  │ (Storage) │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Tool Calling                              │   │
│  │  • Character Name Generator                                  │   │
│  │  • Plot Twist Suggester                                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### The Flow

1. User enters story prompt in Flutter app
2. BLoC dispatches event to use case
3. Use case calls repository interface
4. Repository implementation calls remote data source
5. Data source sends HTTP request to Flask backend
6. Flask uses LiteLLM to call appropriate AI model
7. Response flows back through layers
8. UI updates with generated content

This separation is intentional: each layer has one responsibility, making the code testable and maintainable.

---

## Part 1: Building the Domain Layer (Pure Business Logic)

### Why Domain Layer First?

In Clean Architecture, the domain layer is the core. It has **zero dependencies** on external frameworks—no Flutter, no Dio, no databases. Just pure Dart code that defines your business logic.

**The Benefit**: You can test business logic without mocking HTTP clients or databases. The domain layer is eternal—it doesn't change when you switch from Dio to http or from SQLite to Firebase.

### Entities: The Core Business Objects

Entities are the heart of your application. They represent your business concepts:

**Story Entity**:

```dart
class Story extends Equatable {
  final int? id;
  final String title;
  final String content;
  final String genre;
  final String modelUsed;
  final DateTime? createdAt;
  final int wordCount;
  final bool isFavorite;

  const Story({
    this.id,
    required this.title,
    required this.content,
    this.genre = 'fantasy',
    this.modelUsed = 'gpt-4o-mini',
    this.createdAt,
    this.wordCount = 0,
    this.isFavorite = false,
  });

  // copyWith for immutability
  Story copyWith({...}) {...}

  @override
  List<Object?> get props => [...];
}
```

**Key Decisions**:
- **Equatable**: Makes comparison easy (important for BLoC state management)
- **Immutable**: Use `copyWith` instead of setters
- **No JSON methods**: Entities don't know about serialization—that's the data layer's job

**ChatMessage Entity**:

```dart
class ChatMessage extends Equatable {
  final String role;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;
  final String? audioBase64;

  // Factory constructors for convenience
  factory ChatMessage.user(String content) {...}
  factory ChatMessage.assistant(String content, {...}) {...}

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get hasImage => imageUrl != null;
  bool get hasAudio => audioBase64 != null;
}
```

**Design Insight**: The `hasImage` and `hasAudio` getters encapsulate null checks. UI code can use `message.hasImage` instead of `message.imageUrl != null`. Small detail, big readability win.

### Repository Interface: The Contract

The repository interface defines what operations exist without specifying how they're implemented:

```dart
abstract class StoryRepository {
  Future<List<AIModel>> getAvailableModels();
  
  Future<StoryGenerationResult> generateStory({
    required String prompt,
    required List<ChatMessage> history,
    String model = 'gpt-4o-mini',
    String genre = 'fantasy',
  });
  
  Stream<String> streamStory({...});
  
  Future<ImageGenerationResult> illustrateScene({
    required String sceneDescription,
    String style = 'digital fantasy art, vibrant colors',
  });
  
  Future<AudioNarrationResult> narrateText({
    required String text,
    String voice = 'onyx',
  });
  
  Future<int> saveStory(Story story);
  Future<List<Story>> getStoryHistory();
  Future<Story> getStory(int storyId);
  Future<bool> deleteStory(int storyId);
}
```

**Why Abstract?**: The domain layer defines the contract. The data layer provides the implementation. This means:
- You can swap implementations (mock for testing, real for production)
- Business logic doesn't care where data comes from
- Changes to API don't affect domain layer

### Use Cases: Single-Responsibility Actions

Use cases encapsulate single business actions. Each use case does one thing:

**GenerateStory Use Case**:

```dart
class GenerateStory implements UseCase<StoryGenerationResult, GenerateStoryParams> {
  final StoryRepository repository;

  GenerateStory(this.repository);

  @override
  Future<StoryGenerationResult> call(GenerateStoryParams params) {
    return repository.generateStory(
      prompt: params.prompt,
      history: params.history,
      model: params.model,
      genre: params.genre,
    );
  }
}

class GenerateStoryParams extends Equatable {
  final String prompt;
  final List<ChatMessage> history;
  final String model;
  final String genre;

  const GenerateStoryParams({
    required this.prompt,
    required this.history,
    this.model = 'gpt-4o-mini',
    this.genre = 'fantasy',
  });

  @override
  List<Object?> get props => [prompt, history, model, genre];
}
```

**Why Use Cases?**:
- **Single Responsibility**: Each use case does one thing
- **Testable**: Test business logic without UI
- **Reusable**: Same use case can be called from different places
- **Explicit Dependencies**: Constructor injection makes dependencies clear

**The Base Use Case Interface**:

```dart
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
```

This interface ensures all use cases follow the same pattern. `NoParams` is used for use cases that don't need parameters (like `GetStoryHistory`).

---

## Part 2: Building the Data Layer (Implementation Details)

### Models: The Data Transfer Objects

Models handle serialization and conversion. They're the "translators" between JSON and entities:

**StoryModel**:

```dart
class StoryModel {
  final int? id;
  final String title;
  // ... other fields

  // From JSON (API response)
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as int?,
      title: json['title'] as String? ?? 'Untitled',
      content: json['content'] as String? ?? '',
      genre: json['genre'] as String? ?? 'fantasy',
      modelUsed: json['model_used'] as String? ?? 'unknown',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      wordCount: json['word_count'] as int? ?? 0,
      isFavorite: (json['is_favorite'] as int? ?? 0) == 1,
    );
  }

  // To JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'genre': genre,
      'model_used': modelUsed,
      'word_count': wordCount,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  // From Entity (Domain → Data)
  factory StoryModel.fromEntity(Story entity) {
    return StoryModel(
      id: entity.id,
      title: entity.title,
      // ... map all fields
    );
  }

  // To Entity (Data → Domain)
  Story toEntity() {
    return Story(
      id: id,
      title: title,
      // ... map all fields
    );
  }
}
```

**Key Pattern**: `fromEntity` and `toEntity` methods create a clean bridge between layers. The domain layer never sees JSON; the data layer never exposes models to the UI.

### Remote Data Source: The API Client

The data source handles all HTTP communication:

```dart
abstract class StoryRemoteDataSource {
  Future<List<AIModelModel>> getAvailableModels();
  Future<StoryGenerationResponseModel> generateStory({...});
  Stream<String> streamStory({...});
  Future<ImageGenerationResponseModel> illustrateScene({...});
  Future<AudioNarrationResponseModel> narrateText({...});
  Future<int> saveStory(StoryModel story);
  Future<List<StoryModel>> getStoryHistory();
  Future<StoryModel> getStory(int storyId);
  Future<bool> deleteStory(int storyId);
}
```

**Implementation with Dio**:

```dart
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
}
```

**Error Handling**: I created custom exceptions for different error types:

```dart
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
          message: 'Cannot connect to server. Make sure the backend is running.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        // ... parse error message
        return ServerException(message: message, statusCode: statusCode);
      default:
        return NetworkException(message: 'Network error: ${error.message}');
    }
  }
  return ServerException(message: 'Unexpected error: $error');
}
```

### Repository Implementation: The Bridge

The repository implementation connects everything:

```dart
class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource remoteDataSource;

  StoryRepositoryImpl({StoryRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? StoryRemoteDataSourceImpl();

  @override
  Future<StoryGenerationResult> generateStory({
    required String prompt,
    required List<ChatMessage> history,
    String model = 'gpt-4o-mini',
    String genre = 'fantasy',
  }) async {
    // Convert domain entities to data models
    final historyModels = history.map((m) => ChatMessageModel.fromEntity(m)).toList();
    
    // Call data source
    final response = await remoteDataSource.generateStory(
      prompt: prompt,
      history: historyModels,
      model: model,
      genre: genre,
    );
    
    // Convert data model to domain entity
    return response.toEntity();
  }

  @override
  Future<List<Story>> getStoryHistory() async {
    final stories = await remoteDataSource.getStoryHistory();
    return stories.map((s) => s.toEntity()).toList();
  }
}
```

**The Pattern**: 
1. Convert input (entities → models)
2. Call data source
3. Convert output (models → entities)

This keeps each layer focused on its responsibility.

---

## Part 3: Dependency Injection with GetIt

### Why Dependency Injection?

Without DI, you create dependencies directly:

```dart
// Without DI - Hard to test, tightly coupled
class StoryBloc {
  final repository = StoryRepositoryImpl(); // Hardcoded!
}
```

With DI, dependencies are injected:

```dart
// With DI - Testable, loosely coupled
class StoryBloc {
  final StoryRepository repository; // Interface!
  
  StoryBloc({required this.repository});
}
```

### Setting Up GetIt

GetIt is a service locator that manages all dependencies:

```dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // BLoC - Factory (new instance each time)
  sl.registerFactory<StoryBloc>(
    () => StoryBloc(
      getAvailableModels: sl(),
      generateStory: sl(),
      streamStory: sl(),
      illustrateScene: sl(),
      narrateText: sl(),
      saveStory: sl(),
      getStoryHistory: sl(),
      getStory: sl(),
      deleteStory: sl(),
    ),
  );

  // Use Cases - Lazy Singleton (created once when first used)
  sl.registerLazySingleton(() => GetAvailableModels(sl()));
  sl.registerLazySingleton(() => GenerateStory(sl()));
  sl.registerLazySingleton(() => StreamStory(sl()));
  sl.registerLazySingleton(() => IllustrateScene(sl()));
  sl.registerLazySingleton(() => NarrateText(sl()));
  sl.registerLazySingleton(() => SaveStory(sl()));
  sl.registerLazySingleton(() => GetStoryHistory(sl()));
  sl.registerLazySingleton(() => GetStory(sl()));
  sl.registerLazySingleton(() => DeleteStory(sl()));

  // Repository - Lazy Singleton
  sl.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources - Lazy Singleton
  sl.registerLazySingleton<StoryRemoteDataSource>(() => StoryRemoteDataSourceImpl());
}
```

**Registration Types**:
- **Factory**: Creates new instance each time (used for BLoC)
- **LazySingleton**: Creates once when first accessed (used for repositories, use cases)
- **Singleton**: Creates immediately at registration

### Using DI in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await di.initDependencies();
  
  runApp(const StoryForgeApp());
}

class StoryForgeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<StoryBloc>(), // Get from service locator
      child: MaterialApp(...),
    );
  }
}
```

**The Magic**: `sl<StoryBloc>()` automatically resolves all dependencies. GetIt knows that `StoryBloc` needs use cases, use cases need repository, repository needs data source. Everything is wired automatically.

---

## Part 4: Building the Presentation Layer (BLoC)

### Why BLoC Over Provider?

In Week 1, I used Provider. For Week 2, I chose BLoC because:
- **Explicit Events**: Every state change is triggered by an event
- **Predictable**: Given the same events, you get the same states
- **Testable**: Test events and states without UI
- **Scalable**: Complex apps benefit from structured event handling

### The Story BLoC

```dart
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

  StoryBloc({
    required GetAvailableModels getAvailableModels,
    required GenerateStory generateStory,
    // ... all use cases injected
  }) : _getAvailableModels = getAvailableModels,
       _generateStory = generateStory,
       // ... store all use cases
       super(const StoryState()) {
    // Register event handlers
    on<LoadModelsEvent>(_onLoadModels);
    on<GenerateStoryEvent>(_onGenerateStory);
    on<GenerateIllustrationEvent>(_onGenerateIllustration);
    on<GenerateNarrationEvent>(_onGenerateNarration);
    // ... register all handlers
  }
}
```

**Key Insight**: The BLoC doesn't know about HTTP, Dio, or JSON. It only knows about use cases. This is Clean Architecture in action.

### Event Handlers: Using Use Cases

```dart
Future<void> _onGenerateStory(GenerateStoryEvent event, Emitter<StoryState> emit) async {
  emit(state.copyWith(status: StoryStatus.generating, clearError: true));

  // Add user message
  final userMessage = ChatMessage.user(event.prompt);
  final updatedMessages = [...state.messages, userMessage];
  emit(state.copyWith(messages: updatedMessages));

  try {
    // Call use case (not repository directly!)
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
```

**The Flow**:
1. Emit loading state
2. Add user message to conversation
3. Call use case
4. Handle success or error
5. Emit final state

### Multi-Modal Features

**Image Generation**:

```dart
Future<void> _onGenerateIllustration(
  GenerateIllustrationEvent event,
  Emitter<StoryState> emit,
) async {
  emit(state.copyWith(
    status: StoryStatus.generatingImage,
    clearError: true,
    clearImage: true,
  ));

  try {
    final response = await _illustrateScene(
      IllustrateSceneParams(
        sceneDescription: event.sceneDescription,
        style: event.style ?? state.selectedImageStyle,
      ),
    );

    if (response.success && response.imageBase64 != null) {
      emit(state.copyWith(
        status: StoryStatus.success,
        currentImageBase64: response.imageBase64,
      ));
    } else {
      emit(state.copyWith(
        status: StoryStatus.error,
        errorMessage: response.error ?? 'Failed to generate image',
      ));
    }
  } catch (e) {
    emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
  }
}
```

**Audio Narration**:

```dart
Future<void> _onGenerateNarration(
  GenerateNarrationEvent event,
  Emitter<StoryState> emit,
) async {
  emit(state.copyWith(
    status: StoryStatus.generatingAudio,
    clearError: true,
    clearAudio: true,
  ));

  try {
    final response = await _narrateText(
      NarrateTextParams(text: event.text, voice: event.voice ?? state.selectedVoice),
    );

    emit(state.copyWith(
      status: StoryStatus.success,
      currentAudioBase64: response.audioBase64,
    ));
  } catch (e) {
    emit(state.copyWith(status: StoryStatus.error, errorMessage: e.toString()));
  }
}
```

### The State

```dart
class StoryState extends Equatable {
  final StoryStatus status;
  final String? errorMessage;
  final List<AIModel> availableModels;
  final String selectedModel;
  final String selectedGenre;
  final String selectedVoice;
  final String selectedImageStyle;
  final List<ChatMessage> messages;
  final String streamingContent;
  final bool isStreaming;
  final String? currentImageBase64;
  final String? currentAudioBase64;
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

  // Computed properties
  String get fullStoryContent {
    return messages.where((m) => m.isAssistant).map((m) => m.content).join('\n\n');
  }

  int get wordCount => fullStoryContent.split(RegExp(r'\s+')).length;

  bool get hasConversation => messages.isNotEmpty;

  ChatMessage? get lastAssistantMessage {
    try {
      return messages.lastWhere((m) => m.isAssistant);
    } catch (_) {
      return null;
    }
  }

  StoryState copyWith({...}) {...}
}
```

**Design Insight**: Computed properties like `fullStoryContent` and `wordCount` derive values from state. The UI doesn't need to calculate these—they're always correct based on current state.

---

## Part 5: The Flask Backend (Multi-Modal AI)

### LiteLLM: Unified Multi-Model Access

LiteLLM is the key to supporting multiple AI providers:

```python
from litellm import completion

def generate_story(prompt, history, model, genre):
    messages = [
        {"role": "system", "content": get_system_prompt(genre)},
        *history,
        {"role": "user", "content": prompt}
    ]
    
    response = completion(
        model=model,  # "gpt-4o-mini", "gemini/gemini-pro", "claude-3-sonnet"
        messages=messages,
        temperature=0.8,
    )
    
    return response.choices[0].message.content
```

**The Magic**: Same code works with GPT-4, Gemini, and Claude. Just change the model name.

### DALL-E 3 Image Generation

```python
from openai import OpenAI

client = OpenAI()

def illustrate_scene(scene_description, style):
    prompt = f"{style}: {scene_description}"
    
    response = client.images.generate(
        model="dall-e-3",
        prompt=prompt,
        size="1024x1024",
        quality="standard",
        response_format="b64_json",  # Base64 for mobile
        n=1,
    )
    
    return {
        "success": True,
        "image_base64": response.data[0].b64_json,
        "revised_prompt": response.data[0].revised_prompt,
    }
```

**Why Base64?**: Mobile apps can display base64 images directly without downloading. Reduces complexity and improves UX.

### OpenAI TTS Narration

```python
def narrate_text(text, voice):
    response = client.audio.speech.create(
        model="tts-1",
        voice=voice,  # alloy, echo, fable, onyx, nova, shimmer
        input=text[:4096],  # Limit for API
    )
    
    audio_bytes = response.content
    audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
    
    return {
        "audio_base64": audio_base64,
        "format": "mp3",
    }
```

**Voice Options**: The app lets users choose from 6 voices, each with different characteristics (warm, dramatic, authoritative, etc.).

### Tool Calling for Story Enhancement

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "generate_character_name",
            "description": "Generate a unique character name for the story",
            "parameters": {
                "type": "object",
                "properties": {
                    "gender": {"type": "string", "enum": ["male", "female", "neutral"]},
                    "genre": {"type": "string"},
                    "personality": {"type": "string"}
                },
                "required": ["genre"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "suggest_plot_twist",
            "description": "Suggest an unexpected plot twist",
            "parameters": {
                "type": "object",
                "properties": {
                    "current_situation": {"type": "string"},
                    "genre": {"type": "string"}
                },
                "required": ["current_situation", "genre"]
            }
        }
    }
]

def generate_with_tools(prompt, history, model, genre):
    response = completion(
        model=model,
        messages=[...],
        tools=tools,
        tool_choice="auto",  # Let AI decide when to use tools
    )
    
    # Handle tool calls if present
    if response.choices[0].message.tool_calls:
        for tool_call in response.choices[0].message.tool_calls:
            if tool_call.function.name == "generate_character_name":
                # Execute tool and get result
                result = generate_character_name(...)
                # Continue conversation with tool result
    
    return response.choices[0].message.content
```

**The Power**: The AI can autonomously decide to generate character names or suggest plot twists. It's not just responding—it's using tools intelligently.

---

## Part 6: Challenges and Solutions

### Challenge 1: Port Conflict on macOS

**The Problem**: Port 5000 is used by macOS AirPlay Receiver. My Flask server couldn't start.

**What I Tried**:
1. Disabling AirPlay (inconvenient)
2. Using different ports each time (confusing)

**The Solution**: Use port 5001 consistently:

```python
# app.py
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
```

```dart
// api_constants.dart
static const String baseUrl = 'http://10.0.2.2:5001';  // Android emulator
```

Documented this in README to save others the debugging time.

### Challenge 2: Clean Architecture Overhead

**The Problem**: So many files! For one feature, I needed:
- Entity
- Use case
- Use case params
- Model
- Repository interface method
- Repository implementation method
- Data source method
- BLoC event
- BLoC handler

**The Realization**: This overhead pays off in:
- **Testability**: Each piece can be tested in isolation
- **Maintainability**: Changes are localized
- **Scalability**: Adding features follows a clear pattern
- **Team collaboration**: Different developers can work on different layers

For a large app or team, this structure is essential. For a learning project, it teaches you how enterprise apps are built.

### Challenge 3: Streaming Story Generation

**The Problem**: Story generation takes time. Users stare at a spinner for 10+ seconds.

**The Solution**: Streaming with Server-Sent Events (SSE):

```python
# Flask endpoint
@app.route('/api/story/generate/stream', methods=['POST'])
def stream_story():
    def generate():
        for chunk in completion_stream(...):
            yield f"data: {json.dumps({'content': chunk})}\n\n"
        yield "data: [DONE]\n\n"
    
    return Response(generate(), mimetype='text/event-stream')
```

```dart
// Flutter handling
Stream<String> streamStory({...}) async* {
  final response = await _dio.post<ResponseBody>(
    ApiConstants.generateStoryStream,
    data: {...},
    options: Options(responseType: ResponseType.stream),
  );

  await for (final chunk in response.data!.stream) {
    final data = String.fromCharCodes(chunk);
    for (final line in data.split('\n')) {
      if (line.startsWith('data: ')) {
        final jsonStr = line.substring(6);
        if (jsonStr == '[DONE]') return;
        // Parse and yield content
        yield json['content'] as String;
      }
    }
  }
}
```

Now users see the story appear word by word. Much better UX!

### Challenge 4: Audio Player State Management

**The Problem**: The audio player has complex state: loading, playing, paused, position, duration.

**The Solution**: Local state with `StatefulWidget`:

```dart
class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });
  }
}
```

**Why Not BLoC?**: The audio player state is local to this widget. It doesn't need to be shared. Using `setState` is simpler and appropriate here.

---

## Part 7: What I Learned

### 1. Clean Architecture is Worth the Investment

Initially, the layer separation felt like overkill. But as the project grew, I appreciated:
- **Clear boundaries**: I always knew where to put code
- **Easy debugging**: Errors were easy to locate
- **Confident refactoring**: Changing one layer didn't break others

### 2. Use Cases Are Powerful

Before: BLoC called repository directly
After: BLoC calls use cases that call repository

The difference? Use cases can:
- Combine multiple repository calls
- Add business logic validation
- Be reused across multiple BLoCs
- Be tested independently

### 3. Multi-Modal AI is Transformative

Text-only AI is useful. Multi-modal AI is magical. The combination of:
- Generated story (GPT)
- Visual illustration (DALL-E)
- Voice narration (TTS)

Creates an experience that's more than the sum of its parts.

### 4. Tool Calling Changes Everything

Without tools: AI can only respond
With tools: AI can take actions

Tool calling enables AI to:
- Generate context-aware character names
- Suggest plot twists based on story state
- Access external data when needed

This is the future of AI applications.

### 5. Dependency Injection is Essential

Manual dependency creation leads to:
- Tight coupling
- Hard-to-test code
- Inflexible architecture

DI with GetIt provides:
- Loose coupling
- Easy mocking for tests
- Flexible configuration

---

## Part 8: Code Walkthrough - The Complete Flow

Let me trace a complete user journey through the architecture:

### User Journey: Generating a Story with Illustration

**1. User enters prompt and taps "Send"**

```dart
// story_screen.dart
void _sendMessage() {
  final prompt = _promptController.text.trim();
  if (prompt.isEmpty) return;

  context.read<StoryBloc>().add(GenerateStoryEvent(prompt));
}
```

**2. BLoC receives event, calls use case**

```dart
// story_bloc.dart
Future<void> _onGenerateStory(GenerateStoryEvent event, Emitter<StoryState> emit) async {
  emit(state.copyWith(status: StoryStatus.generating));

  final response = await _generateStory(GenerateStoryParams(
    prompt: event.prompt,
    history: state.messages,
    model: state.selectedModel,
    genre: state.selectedGenre,
  ));
  
  // ... handle response
}
```

**3. Use case calls repository**

```dart
// generate_story.dart
@override
Future<StoryGenerationResult> call(GenerateStoryParams params) {
  return repository.generateStory(
    prompt: params.prompt,
    history: params.history,
    model: params.model,
    genre: params.genre,
  );
}
```

**4. Repository converts entities to models, calls data source**

```dart
// story_repository_impl.dart
@override
Future<StoryGenerationResult> generateStory({...}) async {
  final historyModels = history.map((m) => ChatMessageModel.fromEntity(m)).toList();
  final response = await remoteDataSource.generateStory(...);
  return response.toEntity();
}
```

**5. Data source makes HTTP request**

```dart
// story_remote_datasource.dart
@override
Future<StoryGenerationResponseModel> generateStory({...}) async {
  final response = await _dio.post(
    ApiConstants.generateStory,
    data: {'prompt': prompt, 'history': history.map((m) => m.toJson()).toList(), ...},
  );
  return StoryGenerationResponseModel.fromJson(response.data);
}
```

**6. Flask backend processes request**

```python
# app.py
@app.post("/api/story/generate")
def generate_story(request):
    content = llm_service.generate(
        prompt=request.prompt,
        history=request.history,
        model=request.model,
        genre=request.genre,
    )
    return {"success": True, "content": content}
```

**7. Response flows back through layers**

- Flask returns JSON → Data source parses to model → Repository converts to entity → Use case returns result → BLoC updates state → UI rebuilds

**8. User taps "Illustrate" button**

```dart
// story_screen.dart
void _showIllustrationDialog(BuildContext context, StoryState state) {
  final sceneDescription = state.lastAssistantMessage?.content.substring(...);
  
  context.read<StoryBloc>().add(GenerateIllustrationEvent(sceneDescription));
  _showImageViewer(context);
}
```

**9. Same flow for image generation**

BLoC → IllustrateScene use case → Repository → Data source → Flask → DALL-E → Response → UI shows image

This architecture ensures every operation follows the same predictable pattern.

---

## Future Enhancements

### Short-Term
- [ ] Story export (PDF, EPUB)
- [ ] Image gallery for generated illustrations
- [ ] Voice selection UI with preview
- [ ] Story sharing via deep links

### Medium-Term
- [ ] Collaborative storytelling (multiple users)
- [ ] Custom character profiles with consistent appearance
- [ ] Story templates and genres expansion
- [ ] Offline mode with local cache

### Long-Term
- [ ] Fine-tuned story models for specific genres
- [ ] Community story sharing platform
- [ ] AR story reading experience
- [ ] Real-time multiplayer story creation

---

## Conclusion: From Learning to Mastery

This project represents my Week 2 milestone in LLM Engineering. Here's what changed:

**Before Week 2**:
- Used single AI model
- Basic state management
- Simple layered architecture
- Text-only AI interactions

**After Week 2**:
- Multi-model support via LiteLLM
- BLoC with Clean Architecture
- Domain-driven design with use cases
- Multi-modal AI (text + image + audio)
- Tool calling for intelligent enhancements
- Dependency injection with GetIt

**The Key Insight**: Clean Architecture isn't about adding complexity—it's about managing complexity. As features grew (multi-modal, tool calling, streaming), the architecture kept everything organized.

**For Fellow Learners**: Start simple, then refactor. I didn't build Clean Architecture from day one. I started with a working app, then extracted layers as patterns emerged. Don't let architecture paralyze you—ship first, refactor second.

This project isn't just code—it's proof that you can learn complex concepts and build real applications. The journey continues.

---

## Technical Specifications

### Frontend Stack
- **Framework**: Flutter 3.10+
- **State Management**: flutter_bloc 8.1
- **Dependency Injection**: get_it 7.7
- **HTTP Client**: dio 5.7
- **Audio**: audioplayers 6.1
- **UI**: Material Design 3, google_fonts

### Backend Stack
- **Framework**: Flask 3.0
- **AI**: LiteLLM (OpenAI, Google, Anthropic)
- **Image Generation**: DALL-E 3
- **Audio**: OpenAI TTS
- **Database**: SQLite

### Architecture
- **Pattern**: Clean Architecture
- **State**: BLoC Pattern
- **DI**: Service Locator (GetIt)
- **API**: RESTful with SSE streaming

---

## Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Documentation](https://bloclibrary.dev)
- [GetIt Package](https://pub.dev/packages/get_it)
- [LiteLLM Documentation](https://docs.litellm.ai)
- [OpenAI API](https://platform.openai.com/docs)
- [LLM Engineering Course](https://edwarddonner.com)

---

**Built with ❤️ using Flutter, Flask, Clean Architecture, and Multi-Modal AI**

*Week 2 LLM Engineering Project - From single-model to multi-modal AI with enterprise architecture*

