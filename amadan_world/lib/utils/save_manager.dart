import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for the best score and the last selected weapon.
class SaveManager {
  SaveManager._();

  static const String _kHighScore = 'amadan_high_score';
  static const String _kWeapon = 'amadan_weapon';

  static SharedPreferences? _prefs;
  static Future<void>? _initFuture;
  static int highScore = 0;
  static int weaponIndex = 0;

  static Future<void> init() => _initFuture ??= _init();

  static Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
      highScore = prefs.getInt(_kHighScore) ?? 0;
      weaponIndex = prefs.getInt(_kWeapon) ?? 0;
    } catch (e) {
      debugPrint('Save data unavailable: $e');
    }
  }

  /// Stores [score] when it beats the current best. Returns true on a new record.
  static Future<bool> submitScore(int score) async {
    if (score <= highScore) return false;
    highScore = score;
    try {
      await _prefs?.setInt(_kHighScore, score);
    } catch (e) {
      debugPrint('Could not save score: $e');
    }
    return true;
  }

  static Future<void> saveWeapon(int index) async {
    weaponIndex = index;
    try {
      await _prefs?.setInt(_kWeapon, index);
    } catch (e) {
      debugPrint('Could not save weapon: $e');
    }
  }
}
