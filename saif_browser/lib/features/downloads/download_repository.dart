import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';
import 'download_item.dart';

class DownloadRepository {
  DownloadRepository(this._database);

  final AppDatabase _database;
  Database get _db => _database.db;

  Future<List<DownloadItem>> all() async {
    final rows = await _db.query('downloads', orderBy: 'created_at DESC');
    return rows.map(DownloadItem.fromRow).toList();
  }

  Future<int> insert(DownloadItem item) => _db.insert('downloads', item.toRow());

  Future<void> update(DownloadItem item) =>
      _db.update('downloads', item.toRow(), where: 'id = ?', whereArgs: [item.id]);

  Future<void> delete(int id) => _db.delete('downloads', where: 'id = ?', whereArgs: [id]);

  Future<void> deleteIncognito() => _db.delete('downloads', where: 'incognito = 1');

  Future<void> clearFinished() => _db.delete('downloads', where: "status IN ('completed', 'failed', 'canceled')");

  /// App-engine transfers cannot survive a process restart; mark them failed
  /// so the user can retry (which resumes when the server supports ranges).
  Future<void> markInterrupted() => _db.update('downloads', {
    'status': DownloadStatus.failed.name,
    'error': 'Interrupted when the app closed',
  }, where: "engine != 'system' AND status IN ('queued', 'running', 'paused')");
}
