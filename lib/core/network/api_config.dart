import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base host determining if running on Android emulator, iOS simulator, or Web
  static String get defaultHost {
    if (kIsWeb) {
      return '127.0.0.1';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 connects from Android emulator to host localhost
      return '10.0.2.2';
    }
    return '127.0.0.1';
  }

  static const int port = 8000;

  static String baseUrl = 'http://$defaultHost:$port';

  /// GraphQL endpoint
  static String get graphqlUrl => '$baseUrl/graphql/';

  /// Image upload REST endpoint
  static String get imageUploadUrl => '$baseUrl/api/listings/upload-image/';

  /// Helper to convert relative media paths from backend to full URLs
  static String resolveMediaUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }

  /// Override host when testing on physical device over Wi-Fi
  static void setCustomHost(String ipAddress) {
    baseUrl = 'http://$ipAddress:$port';
  }
}
