/// API Constants for StoryForge AI
///
/// Configure the base URL based on your testing environment.
/// Note: Using port 5001 to avoid macOS AirPlay Receiver conflict on port 5000
class ApiConstants {
  // For Android emulator
  static const String baseUrl = 'http://10.0.2.2:5001';

  // For iOS simulator
  // static const String baseUrl = 'http://127.0.0.1:5001';

  // For physical device (use your computer's LAN IP)
  // static const String baseUrl = 'http://192.168.1.XXX:5001';

  // API Endpoints
  static const String models = '/api/models';
  static const String generateStory = '/api/story/generate';
  static const String generateStoryStream = '/api/story/generate/stream';
  static const String illustrateStory = '/api/story/illustrate';
  static const String narrateStory = '/api/story/narrate';
  static const String saveStory = '/api/story/save';
  static const String storyHistory = '/api/story/history';

  // Request timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 120000; // 2 minutes (for generation)
}
