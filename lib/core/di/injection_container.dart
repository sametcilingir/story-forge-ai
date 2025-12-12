import 'package:get_it/get_it.dart';

import '../../data/datasources/story_remote_datasource.dart';
import '../../data/repositories/story_repository_impl.dart';
import '../../domain/repositories/story_repository.dart';
import '../../domain/usecases/usecases.dart';
import '../../presentation/blocs/story/story_bloc.dart';

/// Service Locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // BLoC
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

  // Use Cases
  sl.registerLazySingleton(() => GetAvailableModels(sl()));
  sl.registerLazySingleton(() => GenerateStory(sl()));
  sl.registerLazySingleton(() => StreamStory(sl()));
  sl.registerLazySingleton(() => IllustrateScene(sl()));
  sl.registerLazySingleton(() => NarrateText(sl()));
  sl.registerLazySingleton(() => SaveStory(sl()));
  sl.registerLazySingleton(() => GetStoryHistory(sl()));
  sl.registerLazySingleton(() => GetStory(sl()));
  sl.registerLazySingleton(() => DeleteStory(sl()));

  // Repository
  sl.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<StoryRemoteDataSource>(() => StoryRemoteDataSourceImpl());
}
