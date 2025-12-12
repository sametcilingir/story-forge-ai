/// App Constants for StoryForge AI
class AppConstants {
  // App Info
  static const String appName = 'StoryForge AI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Multi-modal AI Story Creator';

  // Story Genres
  static const List<String> genres = [
    'fantasy',
    'sci-fi',
    'mystery',
    'romance',
    'horror',
    'adventure',
  ];

  // Genre Display Names
  static const Map<String, String> genreDisplayNames = {
    'fantasy': 'Fantasy',
    'sci-fi': 'Sci-Fi',
    'mystery': 'Mystery',
    'romance': 'Romance',
    'horror': 'Horror',
    'adventure': 'Adventure',
  };

  // Genre Icons
  static const Map<String, int> genreIcons = {
    'fantasy': 0xe900, // Icons.auto_fix_high
    'sci-fi': 0xe569, // Icons.rocket_launch
    'mystery': 0xef4e, // Icons.search
    'romance': 0xe87d, // Icons.favorite
    'horror': 0xf04c3, // Icons.nights_stay
    'adventure': 0xe52f, // Icons.explore
  };

  // TTS Voices
  static const List<Map<String, String>> ttsVoices = [
    {'id': 'alloy', 'name': 'Alloy', 'description': 'Neutral and balanced'},
    {'id': 'echo', 'name': 'Echo', 'description': 'Warm and conversational'},
    {'id': 'fable', 'name': 'Fable', 'description': 'Expressive and dramatic'},
    {'id': 'onyx', 'name': 'Onyx', 'description': 'Deep and authoritative'},
    {'id': 'nova', 'name': 'Nova', 'description': 'Friendly and upbeat'},
    {'id': 'shimmer', 'name': 'Shimmer', 'description': 'Clear and gentle'},
  ];

  // Image Styles
  static const List<String> imageStyles = [
    'digital fantasy art, vibrant colors',
    'watercolor illustration',
    'oil painting style',
    'anime style',
    'classic storybook illustration',
    'cinematic, dramatic lighting',
  ];
}
