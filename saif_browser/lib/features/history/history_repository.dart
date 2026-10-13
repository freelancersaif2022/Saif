import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';
import '../../core/utils/url_resolver.dart';
import 'history_entry.dart';

/// Browsing history of regular tabs. Private tabs never write here.
class HistoryRepository {
  HistoryRepository(this._database, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;
  Database get _db => _database.db;

  /// Visits to the same URL within this window update one entry.
  static const mergeWindow = Duration(minutes: 30);

  Future<void> recordVisit(String url, String title) async {
    if (!UrlResolver.isWebUrl(url)) return;
    final now = _clock().millisecondsSinceEpoch;
    await _db.transaction((txn) async {
      final latest = await txn.query('history', orderBy: 'visited_at DESC', limit: 1);
      if (latest.isNotEmpty &&
          latest.first['url'] == url &&
          now - (latest.first['visited_at']! as int) < mergeWindow.inMilliseconds) {
        await txn.update(
          'history',
          {'visited_at': now, if (title.isNotEmpty) 'title': title},
          where: 'id = ?',
          whereArgs: [latest.first['id']],
        );
        return;
      }
      await txn.insert('history', {
        'url': url,
        'title': title,
        'host': UrlResolver.hostOf(url) ?? '',
        'visited_at': now,
      });
    });
  }

  /// Updates the title of the latest visit to [url] once the page reports it.
  Future<void> updateTitle(String url, String title) async {
    if (title.isEmpty) return;
    await _db.rawUpdate(
      'UPDATE history SET title = ? WHERE id = (SELECT id FROM history WHERE url = ? '
      'ORDER BY visited_at DESC LIMIT 1)',
      [title, url],
    );
  }

  Future<List<HistoryEntry>> page({String query = '', int limit = 100, int offset = 0}) async {
    final trimmed = query.trim();
    final rows = await _db.query(
      'history',
      where: trimmed.isEmpty ? null : "title LIKE ? ESCAPE '\\' OR url LIKE ? ESCAPE '\\'",
      whereArgs: trimmed.isEmpty ? null : ['%${_escape(trimmed)}%', '%${_escape(trimmed)}%'],
      orderBy: 'visited_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(HistoryEntry.fromRow).toList();
  }

  /// Distinct URLs matching [prefix] for address-bar suggestions.
  Future<List<HistoryEntry>> suggestions(String text, {int limit = 6}) async {
    final t = text.trim();
    if (t.isEmpty) return const [];
    final like = '%${_escape(t)}%';
    final rows = await _db.rawQuery(
      'SELECT MAX(id) AS id, url, title, MAX(visited_at) AS visited_at, COUNT(*) AS c FROM history '
      "WHERE url LIKE ? ESCAPE '\\' OR title LIKE ? ESCAPE '\\' "
      'GROUP BY url ORDER BY c DESC, visited_at DESC LIMIT ?',
      [like, like, limit],
    );
    return rows.map(HistoryEntry.fromRow).toList();
  }

  Future<List<TopSite>> topSites({int limit = 8}) async {
    final since = _clock().subtract(const Duration(days: 60)).millisecondsSinceEpoch;
    final rows = await _db.rawQuery(
      'SELECT host, COUNT(*) AS visits, MAX(visited_at) AS last, '
      '(SELECT h2.url FROM history h2 WHERE h2.host = h.host ORDER BY h2.visited_at DESC LIMIT 1) AS url, '
      '(SELECT h3.title FROM history h3 WHERE h3.host = h.host ORDER BY h3.visited_at DESC LIMIT 1) AS title '
      "FROM history h WHERE visited_at >= ? AND host != '' GROUP BY host "
      'ORDER BY visits DESC, last DESC LIMIT ?',
      [since, limit],
    );
    return rows.map((r) {
      final host = r['host']! as String;
      final url = r['url']! as String;
      final scheme = Uri.tryParse(url)?.scheme ?? 'https';
      return TopSite(
        url: '$scheme://$host/',
        title: (r['title'] as String?)?.isNotEmpty == true ? r['title']! as String : host,
        host: host,
        visits: r['visits']! as int,
      );
    }).toList();
  }

  Future<void> delete(int id) => _db.delete('history', where: 'id = ?', whereArgs: [id]);

  /// Deletes visits newer than [since] (or everything when null).
  Future<int> clear({DateTime? since}) {
    if (since == null) return _db.delete('history');
    return _db.delete('history', where: 'visited_at >= ?', whereArgs: [since.millisecondsSinceEpoch]);
  }

  Future<int> count() async => Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM history')) ?? 0;

  static String _escape(String s) => s.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');
}
