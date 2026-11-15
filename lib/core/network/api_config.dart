import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base host: Default to 127.0.0.1 for USB-connected Android (via adb reverse), Web, and iOS.
  /// For Android emulator without adb reverse, can use 10.0.2.2.
  static String get defaultHost {
    if (kIsWeb) {
      return '127.0.0.1';
    }
    return '127.0.0.1';
  }

  static const int port = 8000;

  static String baseUrl = 'http://$defaultHost:$port';

  /// GraphQL endpoint
  static String get graphqlUrl => '$baseUrl/graphql/';

  /// Health check endpoint
  static String get healthUrl => '$baseUrl/api/health/';

  /// Image upload REST endpoint
  static String get imageUploadUrl => '$baseUrl/api/listings/upload-image/';

  /// AI customer-support chat endpoint (Ollama-backed)
  static String get aiChatUrl => '$baseUrl/api/ai/chat/';

  /// AI project / business analysis endpoint
  static String get aiAnalyzeUrl => '$baseUrl/api/ai/analyze/';

  /// Helper to convert relative media paths from backend to full URLs
  static String resolveMediaUrl(String path) {
    if (path.isEmpty || path == 'placeholder.jpg') return '';

    // Badilisha localhost/127.0.0.1/10.0.2.2 ili zilingane na baseUrl halisi ya simu
    if (path.contains('127.0.0.1:8000') ||
        path.contains('localhost:8000') ||
        path.contains('10.0.2.2:8000')) {
      try {
        final uri = Uri.parse(path);
        return '$baseUrl${uri.path}';
      } catch (_) {}
    }

    // Ikiwa ni URL kamili ya nje (kama Unsplash CDN au Cloudinary)
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Ikiwa ni relative media path kutoka Django backend (mfano /media/listings/...)
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }

  /// Override host when testing on physical device over Wi-Fi
  static void setCustomHost(String ipAddress) {
    baseUrl = 'http://$ipAddress:$port';
  }
}
