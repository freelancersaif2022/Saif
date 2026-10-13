import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_progress_model.dart';

/// Persists [PlayerProgress] as JSON in SharedPreferences.
///
/// The progress is written to a primary key and mirrored to a backup key; if
/// the primary copy is ever unreadable the backup is used, so a single
/// corrupted write can never wipe a player's progression.
class StorageService {
  StorageService(this._prefs);

  static const _key = 'dragon_land.progress.v1';
  static const _backupKey = 'dragon_land.progress.v1.backup';

  final SharedPreferences _prefs;

  static Future<StorageService> create() async => StorageService(await SharedPreferences.getInstance());

  PlayerProgress load() {
    for (final k in const [_key, _backupKey]) {
      final raw = _prefs.getString(k);
      if (raw == null) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return PlayerProgress.fromJson(decoded);
      } catch (e) {
        debugPrint('StorageService: failed to read $k: $e');
      }
    }
    return PlayerProgress();
  }

  Future<void> save(PlayerProgress p) async {
    final raw = jsonEncode(p.toJson());
    final ok = await _prefs.setString(_key, raw);
    if (ok) await _prefs.setString(_backupKey, raw);
  }
}
