import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'storage.dart';

/// SQLite-based storage implementation
class SqliteStorageImpl implements Storage {
  SqliteStorageImpl._(this._db);

  final Database _db;

  static Future<SqliteStorageImpl> getInstance() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'cooking_master.db');
    final db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS kv (key TEXT PRIMARY KEY, value TEXT)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS ingredients (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, calories INTEGER, photo_path TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS ingredients (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, calories INTEGER, photo_path TEXT)',
          );
        }
      },
    );

    return SqliteStorageImpl._(db);
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _db.insert(
      'kv',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<String?> getString(String key) async {
    final rows = await _db.query(
      'kv',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  @override
  Future<void> removeString(String key) async {
    await _db.delete('kv', where: 'key = ?', whereArgs: [key]);
  }

  @override
  Future<void> clear() async {
    await _db.delete('kv');
  }

  @override
  Future<bool> containsKey(String key) async {
    final rows = await _db.query('kv', columns: ['key'], where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isNotEmpty;
  }

  @override
  Future<List<String>> getKeys() async {
    final rows = await _db.query('kv', columns: ['key']);
    return rows.map((r) => r['key'] as String).toList();
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    return await _db.insert(table, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {int? limit, int? offset, String? orderBy}) async {
    return await _db.query(table, limit: limit, offset: offset, orderBy: orderBy);
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) async {
    return await _db.update(table, values, where: where, whereArgs: whereArgs);
  }
}
