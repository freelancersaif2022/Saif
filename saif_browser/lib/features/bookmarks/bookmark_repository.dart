import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';
import 'bookmark.dart';

/// Bookmarks and bookmark folders. `parentId == null` is the root folder.
class BookmarkRepository {
  BookmarkRepository(this._database);

  final AppDatabase _database;
  Database get _db => _database.db;

  Future<List<Bookmark>> children(int? parentId) async {
    final rows = await _db.query(
      'bookmarks',
      where: parentId == null ? 'parent_id IS NULL' : 'parent_id = ?',
      whereArgs: parentId == null ? null : [parentId],
      orderBy: 'is_folder DESC, position ASC, id ASC',
    );
    return rows.map(Bookmark.fromRow).toList();
  }

  Future<Bookmark?> byId(int id) async {
    final rows = await _db.query('bookmarks', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Bookmark.fromRow(rows.first);
  }

  Future<List<Bookmark>> folders() async {
    final rows = await _db.query('bookmarks', where: 'is_folder = 1', orderBy: 'title COLLATE NOCASE');
    return rows.map(Bookmark.fromRow).toList();
  }

  Future<List<Bookmark>> recent({int limit = 8}) async {
    final rows = await _db.query('bookmarks', where: 'is_folder = 0', orderBy: 'created_at DESC', limit: limit);
    return rows.map(Bookmark.fromRow).toList();
  }

  Future<List<Bookmark>> search(String query, {int limit = 100}) async {
    final like = '%${_escape(query.trim())}%';
    final rows = await _db.query(
      'bookmarks',
      where: "is_folder = 0 AND (title LIKE ? ESCAPE '\\' OR url LIKE ? ESCAPE '\\')",
      whereArgs: [like, like],
      orderBy: 'title COLLATE NOCASE',
      limit: limit,
    );
    return rows.map(Bookmark.fromRow).toList();
  }

  Future<Bookmark?> findByUrl(String url) async {
    final rows = await _db.query('bookmarks', where: 'is_folder = 0 AND url = ?', whereArgs: [url], limit: 1);
    return rows.isEmpty ? null : Bookmark.fromRow(rows.first);
  }

  Future<int> add({required String title, required String url, int? parentId}) {
    return _insert(title: title, url: url, parentId: parentId, isFolder: false);
  }

  Future<int> addFolder(String title, {int? parentId}) {
    return _insert(title: title, url: null, parentId: parentId, isFolder: true);
  }

  Future<int> _insert({required String title, required String? url, required int? parentId, required bool isFolder}) {
    return _db.transaction((txn) async {
      final maxRow = await txn.rawQuery(
        'SELECT COALESCE(MAX(position), -1) AS m FROM bookmarks WHERE '
        '${parentId == null ? 'parent_id IS NULL' : 'parent_id = ?'}',
        parentId == null ? null : [parentId],
      );
      final position = (maxRow.first['m'] as int) + 1;
      final now = DateTime.now().millisecondsSinceEpoch;
      return txn.insert('bookmarks', {
        'title': title.trim().isEmpty ? (url ?? 'Folder') : title.trim(),
        'url': url,
        'parent_id': parentId,
        'is_folder': isFolder ? 1 : 0,
        'position': position,
        'created_at': now,
        'updated_at': now,
      });
    });
  }

  Future<void> update(int id, {required String title, String? url, int? parentId}) async {
    if (parentId != null && await _isDescendantOrSelf(parentId, id)) {
      throw ArgumentError('A folder cannot be moved into itself');
    }
    await _db.update(
      'bookmarks',
      {'title': title.trim(), 'url': ?url, 'parent_id': parentId, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> _isDescendantOrSelf(int candidate, int ancestor) async {
    int? current = candidate;
    var guard = 0;
    while (current != null && guard++ < 64) {
      if (current == ancestor) return true;
      final rows = await _db.query('bookmarks', columns: ['parent_id'], where: 'id = ?', whereArgs: [current]);
      current = rows.isEmpty ? null : rows.first['parent_id'] as int?;
    }
    return false;
  }

  /// Rewrites positions of [orderedIds] inside one folder.
  Future<void> reorder(List<int> orderedIds) async {
    await _db.transaction((txn) async {
      for (var i = 0; i < orderedIds.length; i++) {
        await txn.update('bookmarks', {'position': i}, where: 'id = ?', whereArgs: [orderedIds[i]]);
      }
    });
  }

  /// Deletes a bookmark, or a folder with everything inside it.
  Future<void> delete(int id) => _db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);

  Future<void> deleteByUrl(String url) => _db.delete('bookmarks', where: 'is_folder = 0 AND url = ?', whereArgs: [url]);

  static String _escape(String s) => s.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');
}
