import 'dart:convert';
import 'dart:async';

import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/core/di/service_locator.dart';
import 'package:http/http.dart' as http;

class OpenAIClient {
  final Storage _storage;

  OpenAIClient._(this._storage);
  static OpenAIClient? _instance;

  static OpenAIClient instance() {
    _instance ??= OpenAIClient._(ServiceLocator.instance.get<Storage>());
    return _instance!;
  }

  Future<String?> _getApiKey() async => await _storage.getString('openai_api_key');

  Future<void> setApiKey(String key) async {
    await _storage.saveString('openai_api_key', key);
  }

  Future<int?> suggestCalories(String ingredient, {String model = 'gpt-3.5-turbo'}) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) throw Exception('NO_API_KEY');

    final prompt =
        'Provide an approximate integer number of kilocalories (kcal) for a typical serving of "$ingredient". Reply with only the number, no units.';

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant that returns only numbers.'},
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 10,
      'temperature': 0.0,
    });

    final resp = await http
        .post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'}, body: body)
        .timeout(const Duration(seconds: 15));

    if (resp.statusCode != 200) throw Exception('API_ERROR: ${resp.statusCode}');

    final data = jsonDecode(resp.body);
    final content = data['choices']?[0]?['message']?['content'] as String?;
    if (content == null) throw Exception('NO_CONTENT');

    final match = RegExp(r'(-?\d+)').firstMatch(content.replaceAll(',', ''));
    if (match != null) return int.tryParse(match.group(1)!);
    return null;
  }
}
