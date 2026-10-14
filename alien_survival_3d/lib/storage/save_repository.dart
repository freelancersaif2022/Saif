import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Local persistence (shared_preferences). Each record is written to its key
/// and to a backup key; if the main copy is unreadable the backup is used, and
/// if both are damaged the game starts from defaults instead of crashing.
/// Nothing leaves the device.
class SaveRepository {
  SaveRepository(this._prefs);

  static const saveKey = 'save_v1';
  static const settingsKey = 'settings_v1';
  static const _backup = '_backup';

  final SharedPreferences _prefs;

  /// Set when a damaged record had to be recovered or reset during load.
  bool recovered = false;

  static Future<SaveRepository> open() async => SaveRepository(await SharedPreferences.getInstance());

  Object? _readJson(String key) {
    for (final k in [key, key + _backup]) {
      final raw = _prefs.getString(k);
      if (raw == null) continue;
      try {
        final v = jsonDecode(raw);
        if (v is Map) {
          if (k != key) recovered = true;
          return v;
        }
        recovered = true;
      } catch (e) {
        recovered = true;
        debugPrint('Corrupted $k: $e');
      }
    }
    return null;
  }

  SaveData loadSave() => SaveData.fromJson(_readJson(saveKey));

  Settings loadSettings() => Settings.fromJson(_readJson(settingsKey));

  Future<void> _write(String key, Map<String, Object?> json) async {
    final raw = jsonEncode(json);
    await _prefs.setString(key, raw);
    await _prefs.setString(key + _backup, raw);
  }

  Future<void> save(SaveData data) => _write(saveKey, data.toJson());

  Future<void> saveSettings(Settings s) => _write(settingsKey, s.toJson());

  Future<void> resetProgress() async {
    await _prefs.remove(saveKey);
    await _prefs.remove(saveKey + _backup);
  }
}
