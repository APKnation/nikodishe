import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/network/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class GraphQLClient {
  static final GraphQLClient _instance = GraphQLClient._internal();
  factory GraphQLClient() => _instance;
  GraphQLClient._internal();

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Sends a GraphQL query or mutation to the backend
  Future<Map<String, dynamic>> execute({
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    final uri = Uri.parse(ApiConfig.graphqlUrl);
    final payload = jsonEncode({
      'query': query,
      if (variables != null) 'variables': variables,
    });

    try {
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(),
            body: payload,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException(
          'Seva imeleta hitilafu (${response.statusCode}): ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }

      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      if (body.containsKey('errors')) {
        final List errors = body['errors'] as List;
        if (errors.isNotEmpty) {
          final firstError = errors.first;
          final errorMsg = firstError is Map ? firstError['message'] : errors.toString();
          throw ApiException(errorMsg.toString());
        }
      }

      return (body['data'] as Map<String, dynamic>?) ?? {};
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Haikuweza kuunganisha na seva ($uri): $e');
    }
  }
}

