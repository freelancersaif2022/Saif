import 'package:flutter/foundation.dart';

import '../storage/models.dart';
import '../storage/save_repository.dart';
import 'catalog.dart';

/// Result of one survival run as reported by the engine.
class RunResult {
  RunResult(this.raw);

  final Map<String, Object?> raw;

  int _i(String k) => (raw[k] is num) ? (raw[k] as num).toInt().clamp(0, 1 << 30) : 0;

  int get score => _i('score');
  int get wave => _i('wave');
  int get kills => _i('kills');
  int get seconds => _i('time');
  int get coins => _i('coins');
  int get gems => _i('gems');
  int get headshots => _i('headshots');
  int get shotsFired => _i('shotsFired');
  int get shotsHit => _i('shotsHit');
  int get accuracy => _i('accuracy');
  int get bossesKilled => _i('bossesKilled');
  int get pickups => _i('pickups');
  int get grenadesThrown => _i('grenadesThrown');
  double get maxCombo => (raw['maxCombo'] is num) ? (raw['maxCombo'] as num).toDouble() : 1;
  Map<String, int> get killsByType {
    final m = raw['killsByType'];
    if (m is! Map) return {};
    return {for (final e in m.entries) e.key.toString(): (e.value is num) ? (e.value as num).toInt() : 0};
  }
}

class RunReward {
  RunReward({required this.coinsCollected, required this.waveBonus, required this.scoreBonus, required this.gems, required this.newHighScore, required this.rank});

  final int coinsCollected;
  final int waveBonus;
  final int scoreBonus;
  final int gems;
  final bool newHighScore;

  /// 1-based position in the high-score table, or 0 if not placed.
  final int rank;

  int get totalCoins => coinsCollected + waveBonus + scoreBonus;
}

enum PurchaseResult { ok, notEnoughCoins, notEnoughGems, maxed, alreadyOwned, locked }

/// App-wide progression state; persists every change immediately.
class GameState extends ChangeNotifier {
  GameState(this.repo, this.save, this.settings);

  final SaveRepository? repo;
  final SaveData save;
  final Settings settings;

  static Future<GameState> load() async {
    final repo = await SaveRepository.open();
    return GameState(repo, repo.loadSave(), repo.loadSettings());
  }

  Future<void> _persist() async {
    notifyListeners();
    await repo?.save(save);
  }

  Future<void> persistSettings() async {
    notifyListeners();
    await repo?.saveSettings(settings);
  }

  PurchaseResult _pay(int coins, int gems) {
    if (save.coins < coins) return PurchaseResult.notEnoughCoins;
    if (save.gems < gems) return PurchaseResult.notEnoughGems;
    save.coins -= coins;
    save.gems -= gems;
    return PurchaseResult.ok;
  }

  bool owns(String id) => save.unlocked.contains(id);

  Future<PurchaseResult> buyWeapon(String id) async {
    if (owns(id)) return PurchaseResult.alreadyOwned;
    final w = weaponById(id);
    final r = _pay(w.price, w.gemPrice);
    if (r != PurchaseResult.ok) return r;
    save.unlocked.add(id);
    if (save.secondary.isEmpty && !w.sidearm) save.secondary = id;
    await _persist();
    return r;
  }

  Future<PurchaseResult> upgradeWeapon(String id, WeaponStat stat) async {
    if (!owns(id)) return PurchaseResult.locked;
    final lvl = save.weaponLevel(id, stat);
    if (lvl >= maxWeaponLevel) return PurchaseResult.maxed;
    final c = weaponUpgradeCost(id, stat, lvl);
    final r = _pay(c.coins, c.gems);
    if (r != PurchaseResult.ok) return r;
    (save.weaponLevels[id] ??= {})[stat] = lvl + 1;
    await _persist();
    return r;
  }

  Future<PurchaseResult> upgradePlayer(PlayerStat stat) async {
    final lvl = save.playerLevel(stat);
    if (lvl >= maxPlayerLevel[stat]!) return PurchaseResult.maxed;
    final c = playerUpgradeCost(stat, lvl);
    final r = _pay(c.coins, c.gems);
    if (r != PurchaseResult.ok) return r;
    save.playerLevels[stat] = lvl + 1;
    await _persist();
    return r;
  }

  Future<void> setLoadout(String primary, String secondary) async {
    if (owns(primary) && !weaponById(primary).sidearm) save.primary = primary;
    save.secondary = (secondary != save.primary && owns(secondary) && !weaponById(secondary).sidearm) ? secondary : '';
    await _persist();
  }

  /// Converts a finished run into coins, gems, statistics and high scores.
  Future<RunReward> applyRun(RunResult r) async {
    final waveBonus = r.wave * 10;
    final scoreBonus = r.score ~/ 400;
    save.coins += r.coins + waveBonus + scoreBonus;
    save.gems += r.gems;
    final s = save.stats;
    s.gamesPlayed++;
    s.totalKills += r.kills;
    s.totalHeadshots += r.headshots;
    s.totalShots += r.shotsFired;
    s.totalHits += r.shotsHit;
    s.totalSeconds += r.seconds;
    if (r.wave > s.bestWave) s.bestWave = r.wave;
    s.bossesKilled += r.bossesKilled;
    s.coinsEarned += r.coins + waveBonus + scoreBonus;
    s.gemsEarned += r.gems;
    s.pickups += r.pickups;
    s.grenadesThrown += r.grenadesThrown;
    if (r.maxCombo > s.bestCombo) s.bestCombo = r.maxCombo;
    r.killsByType.forEach((k, v) => s.killsByType[k] = (s.killsByType[k] ?? 0) + v);

    final best = save.highScores.isEmpty ? 0 : save.highScores.first.score;
    var rank = 0;
    if (r.score > 0) {
      final entry = HighScore(score: r.score, wave: r.wave, kills: r.kills, seconds: r.seconds, date: DateTime.now());
      save.highScores.add(entry);
      save.highScores.sort((a, b) => b.score.compareTo(a.score));
      if (save.highScores.length > 10) save.highScores.removeRange(10, save.highScores.length);
      final i = save.highScores.indexOf(entry);
      rank = i >= 0 ? i + 1 : 0;
    }
    await _persist();
    return RunReward(coinsCollected: r.coins, waveBonus: waveBonus, scoreBonus: scoreBonus, gems: r.gems, newHighScore: r.score > best && r.score > 0, rank: rank);
  }

  /// Full configuration for window.game.boot().
  Map<String, Object?> engineConfig({String mode = 'play'}) => {
        'mode': mode,
        'seed': DateTime.now().millisecondsSinceEpoch % 1000000000,
        'loadout': save.loadout,
        'weapons': {
          for (final id in save.loadout)
            id: engineWeaponStats(id, save.weaponLevels[id] ?? const {}),
        },
        'player': enginePlayerStats(save.playerLevels),
        'settings': settings.toEngine(),
      };

  Future<void> resetProgress() async {
    await repo?.resetProgress();
    final fresh = SaveData();
    save
      ..coins = fresh.coins
      ..gems = fresh.gems
      ..unlocked = fresh.unlocked
      ..weaponLevels = {}
      ..playerLevels = {}
      ..primary = fresh.primary
      ..secondary = ''
      ..highScores = []
      ..stats = LifetimeStats();
    await _persist();
  }
}
