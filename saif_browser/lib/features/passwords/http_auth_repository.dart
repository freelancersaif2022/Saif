import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';
import 'vault_cipher.dart';

@immutable
class HttpAuthLogin {
  const HttpAuthLogin({
    required this.host,
    required this.realm,
    required this.isProxy,
    required this.username,
    required this.password,
  });

  final String host;
  final String realm;
  final bool isProxy;
  final String username;
  final String password;
}

@immutable
class HttpAuthEntry {
  const HttpAuthEntry({required this.host, required this.realm, required this.isProxy, required this.username});

  final String host;
  final String realm;
  final bool isProxy;
  final String username;
}

/// Saved answers to "sign in" prompts from websites and network proxies
/// (for example a Wi-Fi manual proxy). Passwords are encrypted with the
/// Keystore-backed cipher, bound to host and realm.
class HttpAuthRepository {
  HttpAuthRepository(this._database, this._cipher);

  final AppDatabase _database;
  final VaultCipher _cipher;
  Database get _db => _database.db;

  static String _aad(String host, String realm) => 'httpauth|$host|$realm';

  Future<HttpAuthLogin?> find(String host, String realm) async {
    final rows = await _db.query('http_auth', where: 'host = ? AND realm = ?', whereArgs: [host, realm]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final password = await _cipher.decrypt(row['password_blob']! as Uint8List, _aad(host, realm));
    return HttpAuthLogin(
      host: host,
      realm: realm,
      isProxy: row['is_proxy'] == 1,
      username: row['username']! as String,
      password: password,
    );
  }

  Future<void> save(HttpAuthLogin login) async {
    final blob = await _cipher.encrypt(login.password, _aad(login.host, login.realm));
    await _db.insert('http_auth', {
      'host': login.host,
      'realm': login.realm,
      'is_proxy': login.isProxy ? 1 : 0,
      'username': login.username,
      'password_blob': blob,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HttpAuthEntry>> all() async {
    final rows = await _db.query('http_auth', orderBy: 'host ASC');
    return [
      for (final r in rows)
        HttpAuthEntry(
          host: r['host']! as String,
          realm: r['realm']! as String,
          isProxy: r['is_proxy'] == 1,
          username: r['username']! as String,
        ),
    ];
  }

  Future<void> delete(String host, String realm) =>
      _db.delete('http_auth', where: 'host = ? AND realm = ?', whereArgs: [host, realm]);

  Future<void> clear() => _db.delete('http_auth');
}
