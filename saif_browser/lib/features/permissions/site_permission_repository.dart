import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';

/// Website capabilities the browser asks the user about.
enum SitePermission {
  camera('Camera'),
  microphone('Microphone'),
  location('Location'),
  protectedMedia('Protected content');

  const SitePermission(this.label);
  final String label;

  static SitePermission? fromName(String name) {
    for (final p in values) {
      if (p.name == name) return p;
    }
    return null;
  }
}

enum PermissionDecision { allow, block }

@immutable
class SitePermissionEntry {
  const SitePermissionEntry(this.origin, this.permission, this.decision);

  final String origin;
  final SitePermission permission;
  final PermissionDecision decision;
}

/// Remembered allow/block decisions of regular browsing.
class SitePermissionRepository {
  SitePermissionRepository(this._database);

  final AppDatabase _database;
  Database get _db => _database.db;

  Future<PermissionDecision?> decision(String origin, SitePermission permission) async {
    final rows = await _db.query(
      'site_permissions',
      columns: ['decision'],
      where: 'origin = ? AND permission = ?',
      whereArgs: [origin, permission.name],
    );
    if (rows.isEmpty) return null;
    return rows.first['decision'] == 'allow' ? PermissionDecision.allow : PermissionDecision.block;
  }

  Future<void> set(String origin, SitePermission permission, PermissionDecision decision) =>
      _db.insert('site_permissions', {
        'origin': origin,
        'permission': permission.name,
        'decision': decision.name,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<SitePermissionEntry>> all() async {
    final rows = await _db.query('site_permissions', orderBy: 'origin ASC');
    return [
      for (final r in rows)
        if (SitePermission.fromName(r['permission']! as String) case final p?)
          SitePermissionEntry(
            r['origin']! as String,
            p,
            r['decision'] == 'allow' ? PermissionDecision.allow : PermissionDecision.block,
          ),
    ];
  }

  Future<void> remove(String origin, SitePermission permission) =>
      _db.delete('site_permissions', where: 'origin = ? AND permission = ?', whereArgs: [origin, permission.name]);

  Future<void> clear() => _db.delete('site_permissions');
}
