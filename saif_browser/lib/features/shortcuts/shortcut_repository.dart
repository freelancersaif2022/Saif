import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';

@immutable
class Shortcut {
  const Shortcut({required this.id, required this.title, required this.url, required this.position});

  final int id;
  final String title;
  final String url;
  final int position;
}

/// User-defined shortcuts on the new tab page.
class ShortcutRepository {
  ShortcutRepository(this._database);

  final AppDatabase _database;
  Database get _db => _database.db;

  Future<List<Shortcut>> all() async {
    final rows = await _db.query('shortcuts', orderBy: 'position ASC, id ASC');
    return rows
        .map(
          (r) => Shortcut(
            id: r['id']! as int,
            title: r['title']! as String,
            url: r['url']! as String,
            position: r['position']! as int,
          ),
        )
        .toList();
  }

  Future<int> add(String title, String url) async {
    final max = Sqflite.firstIntValue(await _db.rawQuery('SELECT COALESCE(MAX(position), -1) FROM shortcuts')) ?? -1;
    return _db.insert('shortcuts', {'title': title.trim(), 'url': url, 'position': max + 1});
  }

  Future<void> update(int id, String title, String url) =>
      _db.update('shortcuts', {'title': title.trim(), 'url': url}, where: 'id = ?', whereArgs: [id]);

  Future<void> delete(int id) => _db.delete('shortcuts', where: 'id = ?', whereArgs: [id]);
}
