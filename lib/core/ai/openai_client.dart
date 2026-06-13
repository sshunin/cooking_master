import 'dart:convert';
import 'dart:async';

import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/ai/ai_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Optional source-level override for the OpenAI API key.
/// Set this to a non-empty string during development if you want to hard-code
/// a key in the source (not recommended for production). Leave null by default.
String? openAIApiKeyOverride = null;
class OpenAIClient implements AIClient {
  final Storage _storage;

  OpenAIClient._(this._storage);
  factory OpenAIClient.create(Storage storage) => OpenAIClient._(storage);
  static OpenAIClient? _instance;

  /// Backwards-compatible singleton getter (not used when registered via ServiceLocator)
  static OpenAIClient get instance {
    _instance ??= OpenAIClient._(ServiceLocator.instance.get<Storage>());
    return _instance!;
  }

  Future<String?> _getApiKey() async {
    // Prefer source-level override if provided
    if (openAIApiKeyOverride != null && openAIApiKeyOverride!.isNotEmpty) {
      debugPrint('[OpenAI] Using source-level override API key.');
      return openAIApiKeyOverride;
    }

    final key = await _storage.getString('openai_api_key');
    debugPrint('[OpenAI] Retrieved API key from storage: ${key != null && key.isNotEmpty ? 'present' : 'missing'}');
    return key;
  }

  /// Return true if an API key is available (either override or stored)
  Future<bool> hasApiKey() async {
    final key = await _getApiKey();
    debugPrint('[OpenAI] hasApiKey -> ${key != null && key.isNotEmpty}');
    return key != null && key.isNotEmpty;
  }

  Future<void> setApiKey(String key) async {
    await _storage.saveString('openai_api_key', key);
    debugPrint('[OpenAI] API key saved to storage (value not logged).');
  }

  Future<int?> suggestCalories(String ingredient, {String model = 'gpt-3.5-turbo'}) async {
    debugPrint('[OpenAI] suggestCalories() start for "${ingredient}" with model=$model');

    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('[OpenAI] suggestCalories aborted: no API key');
      throw Exception('NO_API_KEY');
    }

    final prompt =
        'Provide an approximate integer number of kilocalories (kcal) for a typical serving of "${ingredient}". Reply with only the number, no units.';

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant that returns only numbers.'},
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 10,
      'temperature': 0.0,
    });

    debugPrint('[OpenAI] Sending request to $url');

    try {
      final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'};
      final maskedHeaders = Map<String, String>.from(headers);
      if (maskedHeaders.containsKey('Authorization')) {
        maskedHeaders['Authorization'] = 'Bearer [REDACTED]';
      }
      debugPrint('[OpenAI] Request headers: $maskedHeaders');

      final resp = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 15));

      debugPrint('[OpenAI] HTTP status: ${resp.statusCode}');
      debugPrint('[OpenAI] HTTP body: ${resp.body}');

      if (resp.statusCode != 200) {
        debugPrint('[OpenAI] Non-200 response, throwing');
        throw Exception('API_ERROR: ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;
      debugPrint('[OpenAI] Raw assistant content: ${content?.trim()}');
      if (content == null) {
        debugPrint('[OpenAI] No content in response');
        throw Exception('NO_CONTENT');
      }

      final match = RegExp(r'(-?\d+)').firstMatch(content.replaceAll(',', ''));
      if (match != null) {
        final parsed = int.tryParse(match.group(1)!);
        debugPrint('[OpenAI] Parsed integer: $parsed');
        return parsed;
      }

      debugPrint('[OpenAI] No integer found in assistant content');
      return null;
    } catch (e, st) {
      debugPrint('[OpenAI] suggestCalories error: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }
}
