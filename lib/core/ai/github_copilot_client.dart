import 'dart:async';
import 'package:cooking_master/core/ai/ai_client.dart';
import 'package:cooking_master/core/storage/storage.dart';
import 'package:flutter/foundation.dart';

/// Lightweight GitHub Copilot adapter (stubbed).
/// This is a local adapter that follows the `AIClient` interface.
/// Currently it does not call any external Copilot API — it stores an API key
/// and provides a simple heuristic/fallback for calorie suggestions.
class GitHubCopilotClient implements AIClient {
  final Storage _storage;

  GitHubCopilotClient(this._storage);

  static const _key = 'copilot_api_key';

  @override
  Future<bool> hasApiKey() async {
    final key = await _storage.getString(_key);
    debugPrint('[Copilot] hasApiKey -> ${key != null && key.isNotEmpty}');
    return key != null && key.isNotEmpty;
  }

  @override
  Future<void> setApiKey(String key) async {
    await _storage.saveString(_key, key);
    debugPrint('[Copilot] API key saved (value not logged)');
  }

  @override
  Future<int?> suggestCalories(String ingredient, {String model = ''}) async {
    debugPrint('[Copilot] suggestCalories heuristic for: $ingredient');
    // Simple deterministic heuristic: common keywords mapping
    final lowered = ingredient.toLowerCase();
    final map = {
      'egg': 78,
      'banana': 105,
      'apple': 95,
      'bread': 80,
      'milk': 122,
      'butter': 102,
      'cheese': 113,
      'chicken': 165,
      'rice': 206,
      'potato': 163,
    };

    for (final entry in map.entries) {
      if (lowered.contains(entry.key)) return entry.value;
    }

    // Fallback: estimate by word length to provide a plausible value
    final base = (ingredient.length * 7) + 50;
    debugPrint('[Copilot] heuristic fallback value: $base');
    return base;
  }
}
