import 'package:shared_preferences/shared_preferences.dart';

/// Abstract interface for storage operations.
/// Allows multiple implementations (local, cloud, etc.)
abstract class Storage {
  /// Save a string value with a given key
  Future<void> saveString(String key, String value);

  /// Retrieve a string value by key
  Future<String?> getString(String key);

  /// Remove a value by key
  Future<void> removeString(String key);

  /// Clear all stored data
  Future<void> clear();

  /// Check if a key exists
  Future<bool> containsKey(String key);

  /// Get all keys
  Future<List<String>> getKeys();

  /// Insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> values);

  /// Query a table
  Future<List<Map<String, dynamic>>> query(String table, {int? limit, int? offset, String? orderBy});

  /// Update records in a table
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs});
}

/// In-memory implementation of Storage for development/testing
class LocalStorageImpl implements Storage {

  factory LocalStorageImpl() => _instance;

  LocalStorageImpl._internal();
  static final LocalStorageImpl _instance = LocalStorageImpl._internal();
  final Map<String, String> _data = {};

  @override
  Future<void> saveString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> removeString(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);

  @override
  Future<List<String>> getKeys() async => _data.keys.toList();

  @override
  Future<int> insert(String table, Map<String, dynamic> values) {
    // Not suitable for this storage type
    throw UnimplementedError('Table operations not supported by LocalStorageImpl');
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {int? limit, int? offset, String? orderBy}) {
    // Not suitable for this storage type
    throw UnimplementedError('Table operations not supported by LocalStorageImpl');
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) {
    // Not suitable for this storage type
    throw UnimplementedError('Table operations not supported by LocalStorageImpl');
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
  Future<String?> getString(String key) async {
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
  Future<bool> containsKey(String key) async {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }
  @override
  Future<List<String>> getKeys() async {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {int? limit, int? offset, String? orderBy}) {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) {
    // TODO: Implement cloud storage
    throw UnimplementedError('Cloud storage not yet implemented');
  }
}

/// Persistent implementation using SharedPreferences
class SharedPreferencesStorageImpl implements Storage {
  SharedPreferencesStorageImpl._(this._prefs);

  final SharedPreferences _prefs;

  /// Create instance (must be awaited)
  static Future<SharedPreferencesStorageImpl> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesStorageImpl._(prefs);
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> removeString(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async => _prefs.containsKey(key);

  @override
  Future<List<String>> getKeys() async => _prefs.getKeys().toList();

  @override
  Future<int> insert(String table, Map<String, dynamic> values) {
    // Not suitable for this storage type
    throw UnimplementedError('Table operations not supported by SharedPreferencesStorageImpl');
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {int? limit, int? offset, String? orderBy}) {
    // Not suitable for this storage type
    throw UnimplementedError('Table operations not supported by SharedPreferencesStorageImpl');
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) {
    // Not suitable for this storage type
    throw UnimplementedError('Table operations not supported by SharedPreferencesStorageImpl');
  }
}
