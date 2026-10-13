import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'browser_settings.dart';

/// Persists [BrowserSettings] under a single key so a write is all-or-nothing.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'settings.v1';

  BrowserSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const BrowserSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) return BrowserSettings.fromJson(decoded);
    } on FormatException {
      // Corrupted value: fall back to defaults.
    }
    return const BrowserSettings();
  }

  Future<void> save(BrowserSettings settings) => _prefs.setString(_key, jsonEncode(settings.toJson()));

  Future<void> reset() => _prefs.remove(_key);

  /// Small key/value store for other features (e.g. proxy preferences).
  SharedPreferences get prefs => _prefs;
}
