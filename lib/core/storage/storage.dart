/// Abstract interface for storage operations.
/// Allows multiple implementations (local, cloud, etc.)
abstract class Storage {
  /// Save a string value with a given key
  Future<void> saveString(String key, String value);

  /// Retrieve a string value by key
  String? getString(String key);

  /// Remove a value by key
  Future<void> removeString(String key);

  /// Clear all stored data
  Future<void> clear();

  /// Check if a key exists
  bool containsKey(String key);

  /// Get all keys
  List<String> getKeys();
}

/// In-memory implementation of Storage for development/testing
class LocalStorageImpl implements Storage {
  static final LocalStorageImpl _instance = LocalStorageImpl._internal();
  final Map<String, String> _data = {};

  LocalStorageImpl._internal();

  factory LocalStorageImpl() {
    return _instance;
  }

  @override
  Future<void> saveString(String key, String value) async {
    _data[key] = value;
  }

  @override
  String? getString(String key) {
    return _data[key];
  }

  @override
  Future<void> removeString(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  bool containsKey(String key) {
    return _data.containsKey(key);
  }

  @override
  List<String> getKeys() {
    return _data.keys.toList();
  }
}

/// Template for cloud storage implementation (Firebase, AWS, etc.)
class CloudStorageImpl implements Storage {
  @override
  Future<void> saveString(String key, String value) async {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }

  @override
  String? getString(String key) {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }

  @override
  Future<void> removeString(String key) async {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }

  @override
  Future<void> clear() async {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }

  @override
  bool containsKey(String key) {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }

  @override
  List<String> getKeys() {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }
}
