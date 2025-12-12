import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/story/story_bloc.dart';
import '../blocs/story/story_event.dart';
import '../blocs/story/story_state.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/genre_selector.dart';
import '../widgets/image_viewer.dart';
import '../widgets/message_bubble.dart';
import '../widgets/model_selector.dart';
import 'history_screen.dart';

/// Story Screen - Main chat interface for story creation
/// Presentation Layer - Clean Architecture
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load available models on startup
    context.read<StoryBloc>().add(const LoadModelsEvent());
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    context.read<StoryBloc>().add(GenerateStoryEvent(prompt));
    _promptController.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StoryForge AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            tooltip: 'Story History',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.read<StoryBloc>().add(const NewStoryEvent()),
            tooltip: 'New Story',
          ),
        ],
      ),
      body: BlocConsumer<StoryBloc, StoryState>(
        listener: (context, state) {
          // Show error snackbar
          if (state.status == StoryStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }

          // Scroll to bottom when new message arrives
          if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Settings bar
              _buildSettingsBar(context, state),

              // Chat messages
              Expanded(child: _buildMessageList(context, state)),

              // Multi-modal actions (image, audio)
              if (state.hasConversation) _buildMultiModalBar(context, state),

              // Input area
              _buildInputArea(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsBar(BuildContext context, StoryState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Genre selector
          Expanded(
            child: GenreSelector(
              selectedGenre: state.selectedGenre,
              onGenreSelected: (genre) {
                context.read<StoryBloc>().add(SelectGenreEvent(genre));
              },
            ),
          ),
          const SizedBox(width: 8),
          // Model selector
          Expanded(
            child: ModelSelector(
              models: state.availableModels,
              selectedModel: state.selectedModel,
              isLoading: state.status == StoryStatus.loadingModels,
              onModelSelected: (modelId) {
                context.read<StoryBloc>().add(SelectModelEvent(modelId));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, StoryState state) {
    if (state.messages.isEmpty && !state.isStreaming) {
      return _buildEmptyState(context, state);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length + (state.isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        // Show streaming content
        if (state.isStreaming && index == state.messages.length) {
          return MessageBubble(
            isUser: false,
            content: state.streamingContent,
            isStreaming: true,
          );
        }

        final message = state.messages[index];
        return MessageBubble(
          isUser: message.isUser,
          content: message.content,
          timestamp: message.timestamp,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, StoryState state) {
    final genre = state.selectedGenre;
    final genreColor = AppTheme.getGenreColor(genre);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 80, color: genreColor.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              'Start Your ${AppConstants.genreDisplayNames[genre]} Story',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a prompt below to begin your adventure.\nThe AI will continue your story with vivid descriptions.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Example prompts
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _getExamplePrompts(genre).map((prompt) {
                return ActionChip(
                  label: Text(prompt),
                  onPressed: () {
                    _promptController.text = prompt;
                    _sendMessage();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getExamplePrompts(String genre) {
    final prompts = {
      'fantasy': [
        'A young mage discovers a forbidden spell...',
        'The ancient dragon awakens after centuries...',
        'In a kingdom where magic is outlawed...',
      ],
      'sci-fi': [
        'The first human colony on Mars faces...',
        'An AI becomes self-aware and must decide...',
        'A time traveler arrives with a warning...',
      ],
      'mystery': [
        'A detective receives an anonymous letter...',
        'The mansion holds secrets from decades past...',
        'A witness goes missing before the trial...',
      ],
      'romance': [
        'Two strangers meet during a storm...',
        'A letter arrives from a lost love...',
        'Rivals must work together on a project...',
      ],
      'horror': [
        'The old house at the end of the street...',
        'Strange sounds come from the basement...',
        'The mirror shows something different...',
      ],
      'adventure': [
        'A treasure map leads to an uncharted island...',
        'The explorer discovers a hidden passage...',
        'A challenge awaits at the mountain summit...',
      ],
    };
    return prompts[genre] ?? prompts['fantasy']!;
  }

  Widget _buildMultiModalBar(BuildContext context, StoryState state) {
    final isGenerating = state.status.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Generate illustration
          _MultiModalButton(
            icon: Icons.image,
            label: 'Illustrate',
            isLoading: state.status == StoryStatus.generatingImage,
            isDisabled: isGenerating,
            onPressed: () => _showIllustrationDialog(context, state),
          ),
          // Generate narration
          _MultiModalButton(
            icon: Icons.record_voice_over,
            label: 'Narrate',
            isLoading: state.status == StoryStatus.generatingAudio,
            isDisabled: isGenerating,
            onPressed: () => _generateNarration(context, state),
          ),
          // Save story
          _MultiModalButton(
            icon: Icons.save,
            label: 'Save',
            isLoading: state.status == StoryStatus.saving,
            isDisabled: isGenerating,
            onPressed: () => _showSaveDialog(context, state),
          ),
        ],
      ),
    );
  }

  void _showIllustrationDialog(BuildContext context, StoryState state) {
    final lastMessage = state.lastAssistantMessage;
    if (lastMessage == null) return;

    // Use last 200 characters as scene description
    final sceneDescription = lastMessage.content.length > 200
        ? lastMessage.content.substring(lastMessage.content.length - 200)
        : lastMessage.content;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Generate Illustration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scene to illustrate:', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sceneDescription,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<StoryBloc>().add(GenerateIllustrationEvent(sceneDescription));
              _showImageViewer(context);
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showImageViewer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ImageViewer(),
    );
  }

  void _generateNarration(BuildContext context, StoryState state) {
    final lastMessage = state.lastAssistantMessage;
    if (lastMessage == null) return;

    // Limit text for TTS
    final text = lastMessage.content.length > 4000
        ? lastMessage.content.substring(0, 4000)
        : lastMessage.content;

    context.read<StoryBloc>().add(GenerateNarrationEvent(text));
    _showAudioPlayer(context);
  }

  void _showAudioPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AudioPlayerWidget(),
    );
  }

  void _showSaveDialog(BuildContext context, StoryState state) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save Story'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Story Title',
            hintText: 'Enter a title for your story',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                Navigator.pop(dialogContext);
                context.read<StoryBloc>().add(SaveStoryEvent(title));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Story saved!')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, StoryState state) {
    final isGenerating = state.status.isGenerating;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promptController,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              enabled: !isGenerating,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: isGenerating ? 'Generating story...' : 'Continue the story...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: isGenerating
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Multi-modal action button
class _MultiModalButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  const _MultiModalButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
