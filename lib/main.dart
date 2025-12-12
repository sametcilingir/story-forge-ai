import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'presentation/blocs/story/story_bloc.dart';
import 'presentation/screens/story_screen.dart';

/// StoryForge AI - Main Entry Point
/// Clean Architecture Implementation
///
/// A multi-modal AI story creation app featuring:
/// - Multiple LLM support (GPT-4, Gemini, Claude) via LiteLLM
/// - DALL-E image generation
/// - OpenAI TTS narration
/// - Tool calling for story enhancement
///
/// Architecture:
/// - Domain Layer: Entities, Use Cases, Repository Interfaces
/// - Data Layer: Models, Data Sources, Repository Implementations
/// - Presentation Layer: BLoC, Screens, Widgets
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await di.initDependencies();

  runApp(const StoryForgeApp());
}

class StoryForgeApp extends StatelessWidget {
  const StoryForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<StoryBloc>(),
      child: MaterialApp(
        title: 'StoryForge AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const StoryScreen(),
      ),
    );
  }
}
