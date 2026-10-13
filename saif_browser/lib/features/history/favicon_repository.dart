import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';

/// Site icons of regular tabs, keyed by host, with a small in-memory cache.
class FaviconRepository {
  FaviconRepository(this._database);

  final AppDatabase _database;
  final Map<String, Uint8List?> _cache = {};
  Database get _db => _database.db;

  Future<void> save(String host, Uint8List data) async {
    if (host.isEmpty || data.isEmpty) return;
    _cache[host] = data;
    await _db.insert('favicons', {
      'host': host,
      'data': data,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Uint8List? cached(String host) => _cache[host];

  Future<Uint8List?> load(String host) async {
    if (_cache.containsKey(host)) return _cache[host];
    final rows = await _db.query('favicons', columns: ['data'], where: 'host = ?', whereArgs: [host]);
    final data = rows.isEmpty ? null : rows.first['data'] as Uint8List?;
    _cache[host] = data;
    return data;
  }

  /// Removes icons of sites that no longer appear in history or bookmarks.
  Future<void> prune() async {
    _cache.clear();
    await _db.rawDelete(
      'DELETE FROM favicons WHERE host NOT IN (SELECT DISTINCT host FROM history) '
      "AND NOT EXISTS (SELECT 1 FROM bookmarks b WHERE b.url LIKE '%' || favicons.host || '%')",
    );
  }

  Future<void> clear() async {
    _cache.clear();
    await _db.delete('favicons');
  }
}
