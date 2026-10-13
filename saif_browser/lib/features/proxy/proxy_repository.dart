import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../../core/storage/app_database.dart';
import '../passwords/vault_cipher.dart';
import 'proxy_models.dart';

/// Saved proxies. Passwords are encrypted with the Keystore-backed cipher.
class ProxyRepository {
  ProxyRepository(this._database, this._cipher);

  final AppDatabase _database;
  final VaultCipher _cipher;
  Database get _db => _database.db;

  static String _aad(String host, int port, String? username) => 'proxy|$host|$port|${username ?? ''}';

  ProxyProfile _fromRow(Map<String, Object?> r) => ProxyProfile(
    id: r['id']! as int,
    name: r['name']! as String,
    type: ProxyType.fromName(r['type']! as String),
    host: r['host']! as String,
    port: r['port']! as int,
    username: r['username'] as String?,
    hasPassword: r['password_blob'] != null,
  );

  Future<List<ProxyProfile>> all() async {
    final rows = await _db.query('proxies', orderBy: 'created_at ASC');
    return rows.map(_fromRow).toList();
  }

  Future<ProxyProfile?> byId(int id) async {
    final rows = await _db.query('proxies', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<int> add({
    required String name,
    required ProxyType type,
    required String host,
    required int port,
    String? username,
    String? password,
  }) async {
    final user = (username ?? '').isEmpty ? null : username;
    final blob = (password ?? '').isEmpty ? null : await _cipher.encrypt(password!, _aad(host, port, user));
    return _db.insert('proxies', {
      'name': name.trim().isEmpty ? '$host:$port' : name.trim(),
      'type': type.name,
      'host': host,
      'port': port,
      'username': user,
      'password_blob': blob,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Updates a proxy. A null [password] keeps the existing one; an empty
  /// string removes it.
  Future<void> update(
    int id, {
    required String name,
    required ProxyType type,
    required String host,
    required int port,
    String? username,
    String? password,
  }) async {
    final user = (username ?? '').isEmpty ? null : username;
    Uint8List? blob;
    var keepBlob = false;
    if (password == null) {
      final current = await this.password(id);
      if (current != null) {
        blob = await _cipher.encrypt(current, _aad(host, port, user));
      } else {
        keepBlob = true;
      }
    } else if (password.isNotEmpty) {
      blob = await _cipher.encrypt(password, _aad(host, port, user));
    }
    await _db.update(
      'proxies',
      {
        'name': name.trim().isEmpty ? '$host:$port' : name.trim(),
        'type': type.name,
        'host': host,
        'port': port,
        'username': user,
        if (!keepBlob) 'password_blob': blob,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String?> password(int id) async {
    final rows = await _db.query('proxies', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final blob = rows.first['password_blob'] as Uint8List?;
    if (blob == null) return null;
    return _cipher.decrypt(
      blob,
      _aad(rows.first['host']! as String, rows.first['port']! as int, rows.first['username'] as String?),
    );
  }

  Future<UpstreamProxy?> upstreamFor(int id) async {
    final profile = await byId(id);
    if (profile == null) return null;
    return UpstreamProxy(
      type: profile.type,
      host: profile.host,
      port: profile.port,
      username: profile.username,
      password: profile.hasPassword ? await password(id) : null,
    );
  }

  Future<void> delete(int id) => _db.delete('proxies', where: 'id = ?', whereArgs: [id]);
}
