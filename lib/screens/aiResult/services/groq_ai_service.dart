import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Exception thrown when Groq AI API calls fail
class GroqAIException implements Exception {
  final String message;
  final int? statusCode;

  GroqAIException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'GroqAIException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

/// Response model for Groq AI chat completions
class GroqAIResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<GroqChoice> choices;
  final GroqUsage usage;

  GroqAIResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory GroqAIResponse.fromJson(Map<String, dynamic> json) {
    return GroqAIResponse(
      id: json['id'] ?? '',
      object: json['object'] ?? '',
      created: json['created'] ?? 0,
      model: json['model'] ?? '',
      choices:
          (json['choices'] as List?)
              ?.map((choice) => GroqChoice.fromJson(choice))
              .toList() ??
          [],
      usage: GroqUsage.fromJson(json['usage'] ?? {}),
    );
  }
}

class GroqChoice {
  final int index;
  final GroqMessage message;
  final String finishReason;

  GroqChoice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory GroqChoice.fromJson(Map<String, dynamic> json) {
    return GroqChoice(
      index: json['index'] ?? 0,
      message: GroqMessage.fromJson(json['message'] ?? {}),
      finishReason: json['finish_reason'] ?? '',
    );
  }
}

class GroqMessage {
  final String role;
  final String content;

  GroqMessage({required this.role, required this.content});

  factory GroqMessage.fromJson(Map<String, dynamic> json) {
    return GroqMessage(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }
}

class GroqUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  GroqUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory GroqUsage.fromJson(Map<String, dynamic> json) {
    return GroqUsage(
      promptTokens: json['prompt_tokens'] ?? 0,
      completionTokens: json['completion_tokens'] ?? 0,
      totalTokens: json['total_tokens'] ?? 0,
    );
  }
}

/// Service for interacting with Groq AI API
class GroqAIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _chatCompletionsEndpoint = '/chat/completions';

  /// Get API key (hardcoded)
  static String get _apiKey {
    return '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';
  }

  /// Analyze floor plan image and get construction cost estimate
  ///
  /// [imageDataUrl] - Base64 encoded image data URL (e.g., "data:image/jpeg;base64,...")
  /// [customPrompt] - Optional custom text prompt to include with the image
  /// [model] - AI model to use (default: meta-llama/llama-4-scout-17b-16e-instruct)
  /// [temperature] - Creativity level (0.0 to 2.0, default: 1.0)
  /// [maxTokens] - Maximum tokens in response (default: 1024)
  static Future<GroqAIResponse> analyzeFloorPlan({
    required String imageDataUrl,
    String? customPrompt,
    String model = 'meta-llama/llama-4-scout-17b-16e-instruct',
    double temperature = 1.0,
    int maxTokens = 1024,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$_chatCompletionsEndpoint');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      final systemPrompt =
          '''You are a professional architect and cost estimator. Your task is to analyze the floor plan image provided by the user. Carefully examine the layout, dimensions, wall structures, rooms, materials, furniture, and overall design elements. Based on these details, provide a clear and well-structured prediction of the construction cost. If certain details are missing, make reasonable professional assumptions and state them explicitly in your response.''';

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text':
                  customPrompt ??
                  'Please analyze this floor plan and provide a construction cost estimate.',
            },
            {
              'type': 'image_url',
              'image_url': {'url': imageDataUrl},
            },
          ],
        },
      ];

      final body = {
        'messages': messages,
        'model': model,
        'temperature': temperature,
        'max_completion_tokens': maxTokens,
        'top_p': 1,
        'stream': false,
        'stop': null,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return GroqAIResponse.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        throw GroqAIException(
          'API request failed: $errorBody',
          response.statusCode,
        );
      }
    } on SocketException {
      throw GroqAIException(
        'Network error: Please check your internet connection',
      );
    } on FormatException catch (e) {
      throw GroqAIException('Invalid response format: ${e.message}');
    } catch (e) {
      throw GroqAIException('Unexpected error: $e');
    }
  }

  /// Send a general chat completion request to Groq AI
  ///
  /// [messages] - List of messages in the conversation
  /// [model] - AI model to use (default: meta-llama/llama-4-scout-17b-16e-instruct)
  /// [temperature] - Creativity level (0.0 to 2.0, default: 1.0)
  /// [maxTokens] - Maximum tokens in response (default: 1024)
  static Future<GroqAIResponse> chatCompletion({
    required List<GroqMessage> messages,
    String model = 'meta-llama/llama-4-scout-17b-16e-instruct',
    double temperature = 1.0,
    int maxTokens = 1024,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$_chatCompletionsEndpoint');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      final body = {
        'messages': messages.map((msg) => msg.toJson()).toList(),
        'model': model,
        'temperature': temperature,
        'max_completion_tokens': maxTokens,
        'top_p': 1,
        'stream': false,
        'stop': null,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return GroqAIResponse.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        throw GroqAIException(
          'API request failed: $errorBody',
          response.statusCode,
        );
      }
    } on SocketException {
      throw GroqAIException(
        'Network error: Please check your internet connection',
      );
    } on FormatException catch (e) {
      throw GroqAIException('Invalid response format: ${e.message}');
    } catch (e) {
      throw GroqAIException('Unexpected error: $e');
    }
  }

  /// Convert a File to base64 data URL for image analysis
  ///
  /// [imageFile] - The image file to convert
  /// Returns a data URL string in format: "data:image/[type];base64,[data]"
  static Future<String> fileToDataUrl(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      // Determine the MIME type from file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      String mimeType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg'; // Default to JPEG
      }

      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw GroqAIException('Failed to convert file to data URL: $e');
    }
  }

  /// Analyze floor plan from File directly
  ///
  /// [imageFile] - The image file to analyze
  /// [customPrompt] - Optional custom text prompt to include with the image
  /// [model] - AI model to use (default: meta-llama/llama-4-scout-17b-16e-instruct)
  /// [temperature] - Creativity level (0.0 to 2.0, default: 1.0)
  /// [maxTokens] - Maximum tokens in response (default: 1024)
  static Future<GroqAIResponse> analyzeFloorPlanFromFile({
    required File imageFile,
    String? customPrompt,
    String model = 'meta-llama/llama-4-scout-17b-16e-instruct',
    double temperature = 1.0,
    int maxTokens = 1024,
  }) async {
    final imageDataUrl = await fileToDataUrl(imageFile);
    return analyzeFloorPlan(
      imageDataUrl: imageDataUrl,
      customPrompt: customPrompt,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }
}
