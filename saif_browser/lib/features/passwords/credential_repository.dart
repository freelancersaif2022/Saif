import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';
import 'vault_cipher.dart';

/// A saved login. The password is never held here; see [CredentialRepository.revealPassword].
@immutable
class Credential {
  const Credential({required this.id, required this.origin, required this.username, required this.updatedAt});

  final int id;
  final String origin;
  final String username;
  final DateTime updatedAt;

  String get host => Uri.tryParse(origin)?.host ?? origin;
}

/// Saved website logins. Passwords are encrypted with AES-256-GCM using a
/// Keystore key; the associated data binds each ciphertext to its origin and
/// username. Plaintext passwords are never written to the database.
class CredentialRepository {
  CredentialRepository(this._database, this._cipher);

  final AppDatabase _database;
  final VaultCipher _cipher;
  Database get _db => _database.db;

  static String _aad(String origin, String username) => 'credential|$origin|$username';

  Future<List<Credential>> all({String query = ''}) async {
    final q = query.trim();
    final rows = await _db.query(
      'credentials',
      columns: ['id', 'origin', 'username', 'updated_at'],
      where: q.isEmpty ? null : 'origin LIKE ? OR username LIKE ?',
      whereArgs: q.isEmpty ? null : ['%$q%', '%$q%'],
      orderBy: 'origin ASC, username ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<List<Credential>> forOrigin(String origin) async {
    final rows = await _db.query(
      'credentials',
      columns: ['id', 'origin', 'username', 'updated_at'],
      where: 'origin = ?',
      whereArgs: [origin],
      orderBy: 'updated_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Credential _fromRow(Map<String, Object?> r) => Credential(
    id: r['id']! as int,
    origin: r['origin']! as String,
    username: r['username']! as String,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(r['updated_at']! as int),
  );

  /// Saves or replaces the password for (origin, username).
  Future<int> save({required String origin, required String username, required String password}) async {
    final blob = await _cipher.encrypt(password, _aad(origin, username));
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db.transaction((txn) async {
      final existing = await txn.query(
        'credentials',
        columns: ['id'],
        where: 'origin = ? AND username = ?',
        whereArgs: [origin, username],
      );
      if (existing.isNotEmpty) {
        final id = existing.first['id']! as int;
        await txn.update('credentials', {'password_blob': blob, 'updated_at': now}, where: 'id = ?', whereArgs: [id]);
        return id;
      }
      return txn.insert('credentials', {
        'origin': origin,
        'username': username,
        'password_blob': blob,
        'created_at': now,
        'updated_at': now,
      });
    });
  }

  /// Changes a saved login, re-encrypting because the associated data changes.
  Future<void> update(int id, {required String origin, required String username, required String password}) async {
    final blob = await _cipher.encrypt(password, _aad(origin, username));
    await _db.update(
      'credentials',
      {
        'origin': origin,
        'username': username,
        'password_blob': blob,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Decrypts a password. Callers must authenticate the user first.
  Future<String?> revealPassword(int id) async {
    final rows = await _db.query('credentials', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return _cipher.decrypt(
      row['password_blob']! as Uint8List,
      _aad(row['origin']! as String, row['username']! as String),
    );
  }

  Future<void> delete(int id) => _db.delete('credentials', where: 'id = ?', whereArgs: [id]);

  Future<void> clear() => _db.delete('credentials');

  Future<int> count() async => Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM credentials')) ?? 0;
}
