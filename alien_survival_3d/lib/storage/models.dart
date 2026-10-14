import '../progression/catalog.dart';

/// Defensive JSON readers: missing, wrong-typed or out-of-range values fall
/// back to defaults instead of throwing, so a damaged save never crashes.
int _int(Object? v, int def, {int min = -1 << 31, int max = 1 << 31}) {
  if (v is num && v.isFinite) return v.toInt().clamp(min, max);
  return def;
}

double _double(Object? v, double def, {double min = -1e12, double max = 1e12}) {
  if (v is num && v.isFinite) return v.toDouble().clamp(min, max);
  return def;
}

bool _bool(Object? v, bool def) => v is bool ? v : def;

String _str(Object? v, String def, [List<String>? allowed]) {
  if (v is String && (allowed == null || allowed.contains(v))) return v;
  return def;
}

Map<String, Object?> _map(Object? v) => v is Map ? v.map((k, val) => MapEntry(k.toString(), val)) : const {};

class HighScore {
  HighScore({required this.score, required this.wave, required this.kills, required this.seconds, required this.date});

  final int score;
  final int wave;
  final int kills;
  final int seconds;
  final DateTime date;

  Map<String, Object> toJson() => {'score': score, 'wave': wave, 'kills': kills, 'seconds': seconds, 'date': date.toIso8601String()};

  static HighScore? fromJson(Object? json) {
    final m = _map(json);
    if (m.isEmpty) return null;
    return HighScore(
      score: _int(m['score'], 0, min: 0),
      wave: _int(m['wave'], 0, min: 0),
      kills: _int(m['kills'], 0, min: 0),
      seconds: _int(m['seconds'], 0, min: 0),
      date: DateTime.tryParse(_str(m['date'], '')) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class LifetimeStats {
  int gamesPlayed = 0;
  int totalKills = 0;
  int totalHeadshots = 0;
  int totalShots = 0;
  int totalHits = 0;
  int totalSeconds = 0;
  int bestWave = 0;
  int bossesKilled = 0;
  int coinsEarned = 0;
  int gemsEarned = 0;
  int pickups = 0;
  int grenadesThrown = 0;
  double bestCombo = 1;
  Map<String, int> killsByType = {};

  Map<String, Object> toJson() => {
        'gamesPlayed': gamesPlayed,
        'totalKills': totalKills,
        'totalHeadshots': totalHeadshots,
        'totalShots': totalShots,
        'totalHits': totalHits,
        'totalSeconds': totalSeconds,
        'bestWave': bestWave,
        'bossesKilled': bossesKilled,
        'coinsEarned': coinsEarned,
        'gemsEarned': gemsEarned,
        'pickups': pickups,
        'grenadesThrown': grenadesThrown,
        'bestCombo': bestCombo,
        'killsByType': killsByType,
      };

  static LifetimeStats fromJson(Object? json) {
    final m = _map(json);
    final s = LifetimeStats();
    s.gamesPlayed = _int(m['gamesPlayed'], 0, min: 0);
    s.totalKills = _int(m['totalKills'], 0, min: 0);
    s.totalHeadshots = _int(m['totalHeadshots'], 0, min: 0);
    s.totalShots = _int(m['totalShots'], 0, min: 0);
    s.totalHits = _int(m['totalHits'], 0, min: 0);
    s.totalSeconds = _int(m['totalSeconds'], 0, min: 0);
    s.bestWave = _int(m['bestWave'], 0, min: 0);
    s.bossesKilled = _int(m['bossesKilled'], 0, min: 0);
    s.coinsEarned = _int(m['coinsEarned'], 0, min: 0);
    s.gemsEarned = _int(m['gemsEarned'], 0, min: 0);
    s.pickups = _int(m['pickups'], 0, min: 0);
    s.grenadesThrown = _int(m['grenadesThrown'], 0, min: 0);
    s.bestCombo = _double(m['bestCombo'], 1, min: 1, max: 100);
    final k = _map(m['killsByType']);
    s.killsByType = {for (final e in k.entries) e.key: _int(e.value, 0, min: 0)};
    return s;
  }

  double get accuracy => totalShots == 0 ? 0 : totalHits / totalShots;
}

/// Everything the player earns or buys.
class SaveData {
  static const version = 1;

  int coins = 250;
  int gems = 0;
  Set<String> unlocked = {'rifle', 'pistol'};
  Map<String, Map<WeaponStat, int>> weaponLevels = {};
  Map<PlayerStat, int> playerLevels = {};
  String primary = 'rifle';
  String secondary = '';
  List<HighScore> highScores = [];
  LifetimeStats stats = LifetimeStats();

  int weaponLevel(String id, WeaponStat s) => weaponLevels[id]?[s] ?? 0;
  int playerLevel(PlayerStat s) => playerLevels[s] ?? 0;

  List<String> get loadout {
    final out = <String>[primary];
    if (secondary.isNotEmpty && secondary != primary && unlocked.contains(secondary)) out.add(secondary);
    out.add('pistol');
    return out;
  }

  Map<String, Object> toJson() => {
        'version': version,
        'coins': coins,
        'gems': gems,
        'unlocked': unlocked.toList()..sort(),
        'weaponLevels': {
          for (final e in weaponLevels.entries) e.key: {for (final l in e.value.entries) l.key.name: l.value},
        },
        'playerLevels': {for (final e in playerLevels.entries) e.key.name: e.value},
        'primary': primary,
        'secondary': secondary,
        'highScores': highScores.map((h) => h.toJson()).toList(),
        'stats': stats.toJson(),
      };

  static SaveData fromJson(Object? json) {
    final m = _map(json);
    final d = SaveData();
    if (m.isEmpty) return d;
    d.coins = _int(m['coins'], 250, min: 0, max: 1 << 30);
    d.gems = _int(m['gems'], 0, min: 0, max: 1 << 30);
    final ids = weapons.map((w) => w.id).toSet();
    final un = m['unlocked'];
    if (un is List) d.unlocked = {'rifle', 'pistol', ...un.whereType<String>().where(ids.contains)};
    for (final e in _map(m['weaponLevels']).entries) {
      if (!ids.contains(e.key)) continue;
      final lv = <WeaponStat, int>{};
      for (final s in WeaponStat.values) {
        final v = _map(e.value)[s.name];
        if (v != null) lv[s] = _int(v, 0, min: 0, max: maxWeaponLevel);
      }
      d.weaponLevels[e.key] = lv;
    }
    final pl = _map(m['playerLevels']);
    for (final s in PlayerStat.values) {
      if (pl[s.name] != null) d.playerLevels[s] = _int(pl[s.name], 0, min: 0, max: maxPlayerLevel[s]!);
    }
    d.primary = _str(m['primary'], 'rifle');
    if (!d.unlocked.contains(d.primary) || weaponById(d.primary).sidearm) d.primary = 'rifle';
    d.secondary = _str(m['secondary'], '');
    if (!d.unlocked.contains(d.secondary) || d.secondary == d.primary || weaponById(d.secondary).sidearm) d.secondary = '';
    final hs = m['highScores'];
    if (hs is List) d.highScores = hs.map(HighScore.fromJson).whereType<HighScore>().take(10).toList()..sort((a, b) => b.score.compareTo(a.score));
    d.stats = LifetimeStats.fromJson(m['stats']);
    return d;
  }
}

enum Quality { LOW, MEDIUM, HIGH } // ignore: constant_identifier_names

class Settings {
  Quality quality = Quality.MEDIUM;
  int fps = 60;
  double masterVolume = 1.0;
  double musicVolume = 0.6;
  double sfxVolume = 0.9;
  double ambienceVolume = 0.7;
  double sensitivity = 1.0;
  double aimSensitivity = 0.6;
  double fov = 70;
  bool invertY = false;
  bool aimAssist = true;
  int shoulder = 1;
  double cameraShake = 1.0;
  double controlScale = 1.0;
  double controlOpacity = 0.85;
  bool showFps = false;
  bool vibration = true;
  Map<String, Map<String, double>> layout = {};

  Map<String, Object> toJson() => {
        'quality': quality.name,
        'fps': fps,
        'masterVolume': masterVolume,
        'musicVolume': musicVolume,
        'sfxVolume': sfxVolume,
        'ambienceVolume': ambienceVolume,
        'sensitivity': sensitivity,
        'aimSensitivity': aimSensitivity,
        'fov': fov,
        'invertY': invertY,
        'aimAssist': aimAssist,
        'shoulder': shoulder,
        'cameraShake': cameraShake,
        'controlScale': controlScale,
        'controlOpacity': controlOpacity,
        'showFps': showFps,
        'vibration': vibration,
        'layout': layout,
      };

  /// Settings as the engine expects them (vibration is handled by Flutter).
  Map<String, Object?> toEngine() {
    final j = Map<String, Object?>.from(toJson())..remove('vibration');
    if (layout.isEmpty) j['layout'] = null;
    return j;
  }

  static Settings fromJson(Object? json) {
    final m = _map(json);
    final s = Settings();
    s.quality = Quality.values.firstWhere((q) => q.name == m['quality'], orElse: () => Quality.MEDIUM);
    s.fps = _int(m['fps'], 60) == 30 ? 30 : 60;
    s.masterVolume = _double(m['masterVolume'], 1, min: 0, max: 1);
    s.musicVolume = _double(m['musicVolume'], 0.6, min: 0, max: 1);
    s.sfxVolume = _double(m['sfxVolume'], 0.9, min: 0, max: 1);
    s.ambienceVolume = _double(m['ambienceVolume'], 0.7, min: 0, max: 1);
    s.sensitivity = _double(m['sensitivity'], 1, min: 0.2, max: 3);
    s.aimSensitivity = _double(m['aimSensitivity'], 0.6, min: 0.1, max: 1.5);
    s.fov = _double(m['fov'], 70, min: 55, max: 95);
    s.invertY = _bool(m['invertY'], false);
    s.aimAssist = _bool(m['aimAssist'], true);
    s.shoulder = _int(m['shoulder'], 1) < 0 ? -1 : 1;
    s.cameraShake = _double(m['cameraShake'], 1, min: 0, max: 1.5);
    s.controlScale = _double(m['controlScale'], 1, min: 0.6, max: 1.5);
    s.controlOpacity = _double(m['controlOpacity'], 0.85, min: 0.3, max: 1);
    s.showFps = _bool(m['showFps'], false);
    s.vibration = _bool(m['vibration'], true);
    for (final e in _map(m['layout']).entries) {
      final p = _map(e.value);
      final x = p['x'], y = p['y'];
      if (x is num && y is num && x.isFinite && y.isFinite) {
        s.layout[e.key] = {'x': x.toDouble().clamp(0.0, 1.0), 'y': y.toDouble().clamp(0.0, 1.0)};
      }
    }
    return s;
  }
}
