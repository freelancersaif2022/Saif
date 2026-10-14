import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent local progression storage.
class SaveData {
  SaveData._();
  static final SaveData instance = SaveData._();

  static const int levelCount = 20;

  SharedPreferences? _prefs;

  /// Bumped whenever progression changes so menus can refresh.
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  int unlockedLevel = 1;
  final Set<int> completed = <int>{};
  int selectedLevel = 1;
  int highScore = 0;
  bool soundOn = true;
  int checkpointLevel = 1;
  double checkpointX = 0;

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final p = _prefs!;
      unlockedLevel = (p.getInt('unlocked') ?? 1).clamp(1, levelCount);
      completed
        ..clear()
        ..addAll((p.getStringList('completed') ?? const <String>[])
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e >= 1 && e <= levelCount));
      selectedLevel = (p.getInt('selected') ?? 1).clamp(1, unlockedLevel);
      highScore = p.getInt('highScore') ?? 0;
      soundOn = p.getBool('sound') ?? true;
      checkpointLevel = (p.getInt('cpLevel') ?? 1).clamp(1, levelCount);
      checkpointX = p.getDouble('cpX') ?? 0;
    } catch (_) {
      // Storage unavailable: keep defaults.
    }
  }

  Future<void> _persist() async {
    changes.value++;
    final p = _prefs;
    if (p == null) return;
    try {
      await p.setInt('unlocked', unlockedLevel);
      await p.setStringList('completed', completed.map((e) => '$e').toList());
      await p.setInt('selected', selectedLevel);
      await p.setInt('highScore', highScore);
      await p.setBool('sound', soundOn);
      await p.setInt('cpLevel', checkpointLevel);
      await p.setDouble('cpX', checkpointX);
    } catch (_) {}
  }

  bool isUnlocked(int level) => level <= unlockedLevel;
  bool isCompleted(int level) => completed.contains(level);

  void setSound(bool on) {
    soundOn = on;
    _persist();
  }

  void selectLevel(int level) {
    if (!isUnlocked(level)) return;
    selectedLevel = level;
    _persist();
  }

  void saveCheckpoint(int level, double x) {
    checkpointLevel = level;
    checkpointX = x;
    _persist();
  }

  void clearCheckpoint(int level) {
    checkpointLevel = level;
    checkpointX = 0;
    _persist();
  }

  double checkpointFor(int level) => checkpointLevel == level ? checkpointX : 0;

  void submitScore(int score) {
    if (score > highScore) {
      highScore = score;
      _persist();
    }
  }

  void completeLevel(int level) {
    completed.add(level);
    if (level < levelCount && unlockedLevel < level + 1) {
      unlockedLevel = level + 1;
    }
    selectedLevel = level < levelCount ? level + 1 : level;
    checkpointLevel = selectedLevel;
    checkpointX = 0;
    _persist();
  }
}
