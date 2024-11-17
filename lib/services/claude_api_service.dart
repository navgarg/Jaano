import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';

class ClaudeApiService {
  final String apiKey;

  ClaudeApiService({required this.apiKey});

  Future<Map<String, dynamic>> sendMessage({
    required String content,
    String model="claude-3-sonnet-20240229",
    // String model = 'claude-3-opus-20240229',
    double temperature = 1.0, //controls randomness of responses
    int? maxTokens,
  }) async {
    try {
      final headers = {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      };

      final body = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': content,
          }
        ],
        'temperature': temperature,
        'max_tokens': maxTokens ?? 500,
        'system':"You are a helpful assistant that specializes in explaining news to children."
      };

      final response = await http.post(
        Uri.parse(Claude_baseUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

}