import 'package:cooking_master/core/storage/storage.dart';

/// Generic AI client interface used by the UI and use-cases.
/// Implementations include OpenAI and GitHub Copilot adapters.
abstract class AIClient {
  Future<bool> hasApiKey();
  Future<void> setApiKey(String key);
  Future<int?> suggestCalories(String ingredient, {String model});
}
