/// Configuration constants for Roboflow API integration
class RoboflowConfig {
  // Roboflow API configuration
  static const String baseUrl =
      'https://serverless.roboflow.com/infer/workflows/test-cmoub/terra-price';
  static const String apiKey = 'Zub42A5wGM8poDgcI18Q';

  // Image processing settings
  static const int maxWidth = 1800;
  static const int maxHeight = 1800;
  static const int imageQuality = 85;
  static const int maxImages = 5;

  // Request configuration
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Cache settings
  static const String cacheControl = '3600';
  static const String bucketName = 'ai_results';
}
