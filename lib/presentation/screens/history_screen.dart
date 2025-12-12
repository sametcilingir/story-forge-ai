import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/story.dart';
import '../blocs/story/story_bloc.dart';
import '../blocs/story/story_event.dart';
import '../blocs/story/story_state.dart';

/// History Screen - View and manage saved stories
/// Presentation Layer - Clean Architecture
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when screen opens
    context.read<StoryBloc>().add(const LoadHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StoryBloc>().add(const LoadHistoryEvent()),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          if (state.status == StoryStatus.loadingHistory) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.storyHistory.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildStoryList(context, state.storyHistory);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'No Stories Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Your saved stories will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.add),
            label: const Text('Create a Story'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryList(BuildContext context, List<Story> stories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return _StoryCard(
          story: story,
          onTap: () => _loadStory(context, story),
          onDelete: () => _deleteStory(context, story),
        );
      },
    );
  }

  void _loadStory(BuildContext context, Story story) {
    if (story.id != null) {
      context.read<StoryBloc>().add(LoadStoryEvent(story.id!));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Loaded: ${story.title}')));
    }
  }

  void _deleteStory(BuildContext context, Story story) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Story?'),
        content: Text('Are you sure you want to delete "${story.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (story.id != null) {
                context.read<StoryBloc>().add(DeleteStoryEvent(story.id!));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Story deleted')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Story Card Widget
class _StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StoryCard({required this.story, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final genreColor = AppTheme.getGenreColor(story.genre);
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate = story.createdAt != null
        ? dateFormat.format(story.createdAt!)
        : 'Unknown date';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Genre badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: genreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getGenreIcon(story.genre), size: 14, color: genreColor),
                        const SizedBox(width: 4),
                        Text(
                          AppConstants.genreDisplayNames[story.genre] ?? story.genre,
                          style: TextStyle(
                            color: genreColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: Colors.grey,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                story.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Preview (first 100 chars of content)
              if (story.content.isNotEmpty)
                Text(
                  story.content.length > 100
                      ? '${story.content.substring(0, 100)}...'
                      : story.content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  // Date
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  ),

                  const SizedBox(width: 16),

                  // Word count
                  Icon(Icons.article, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${story.wordCount} words',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  ),

                  const Spacer(),

                  // Model used
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatModelName(story.modelUsed),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGenreIcon(String genre) {
    switch (genre) {
      case 'fantasy':
        return Icons.auto_fix_high;
      case 'sci-fi':
        return Icons.rocket_launch;
      case 'mystery':
        return Icons.search;
      case 'romance':
        return Icons.favorite;
      case 'horror':
        return Icons.nights_stay;
      case 'adventure':
        return Icons.explore;
      default:
        return Icons.book;
    }
  }

  String _formatModelName(String model) {
    // Shorten model names for display
    if (model.contains('gpt-4o-mini')) return 'GPT-4o Mini';
    if (model.contains('gpt-4o')) return 'GPT-4o';
    if (model.contains('gemini')) return 'Gemini';
    if (model.contains('claude')) return 'Claude';
    return model;
  }
}
