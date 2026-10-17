import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/monetization_config.dart';
import '../game/monster_factory.dart';
import '../models/monster.dart';
import 'roar_storage.dart';

/// Single source of truth for the player's progress. Saved locally only.
class GameStore extends ChangeNotifier {
  GameStore._(this._prefs);

  static const _key = 'vba_save_v1';
  final SharedPreferences _prefs;

  static Future<GameStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = GameStore._(prefs);
    s._read();
    return s;
  }

  // ---- Persistent fields ---------------------------------------------------
  bool onboarded = false;
  int coins = 150;
  int gems = 10;
  int stones = 0;
  int slots = 4;
  int _energy = maxEnergy;
  DateTime _energyStamp = DateTime.now();
  int ladderProgress = 0; // index of next un-cleared stage
  int totalBattles = 0;
  int totalWins = 0;
  bool removeAds = false;
  bool starterPackOwned = false;
  bool soundOn = true;
  bool hapticsOn = true;
  DateTime? lastDailyClaim;
  String _gemAdDay = '';
  int _gemAdsToday = 0;
  String? selectedMonsterId;
  final List<Monster> monsters = [];

  static const int maxEnergy = 10;
  static const Duration energyRegen = Duration(minutes: 10);

  // ---- Energy (regenerates over time, computed lazily) ---------------------
  int get energy {
    _tickEnergy();
    return _energy;
  }

  Duration get nextEnergyIn {
    _tickEnergy();
    if (_energy >= maxEnergy) return Duration.zero;
    final elapsed = DateTime.now().difference(_energyStamp);
    return energyRegen - elapsed;
  }

  void _tickEnergy() {
    if (_energy >= maxEnergy) {
      _energyStamp = DateTime.now();
      return;
    }
    final elapsed = DateTime.now().difference(_energyStamp);
    final gained = elapsed.inSeconds ~/ energyRegen.inSeconds;
    if (gained > 0) {
      _energy = (_energy + gained).clamp(0, maxEnergy);
      _energyStamp = _energy >= maxEnergy ? DateTime.now() : _energyStamp.add(energyRegen * gained);
    }
  }

  bool spendEnergy() {
    _tickEnergy();
    if (_energy <= 0) return false;
    if (_energy == maxEnergy) _energyStamp = DateTime.now();
    _energy--;
    _save();
    return true;
  }

  void addEnergy(int n) {
    _tickEnergy();
    _energy = (_energy + n).clamp(0, maxEnergy + 10);
    _save();
  }

  // ---- Currency -------------------------------------------------------------
  void addCoins(int n) {
    coins += n;
    _save();
  }

  void addGems(int n) {
    gems += n;
    _save();
  }

  void addStones(int n) {
    stones += n;
    _save();
  }

  bool spendCoins(int n) {
    if (coins < n) return false;
    coins -= n;
    _save();
    return true;
  }

  bool spendGems(int n) {
    if (gems < n) return false;
    gems -= n;
    _save();
    return true;
  }

  // ---- Daily chest & free gem ads ------------------------------------------
  bool get dailyReady => lastDailyClaim == null || DateTime.now().difference(lastDailyClaim!) >= const Duration(hours: 20);

  Duration get dailyIn => dailyReady ? Duration.zero : const Duration(hours: 20) - DateTime.now().difference(lastDailyClaim!);

  void claimDaily({required bool doubled}) {
    lastDailyClaim = DateTime.now();
    coins += doubled ? 200 : 100;
    gems += doubled ? 10 : 5;
    _save();
  }

  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  int get gemAdsLeft => _gemAdDay == _today ? (MonetizationConfig.dailyFreeGemAds - _gemAdsToday).clamp(0, 99) : MonetizationConfig.dailyFreeGemAds;

  void recordGemAd() {
    if (_gemAdDay != _today) {
      _gemAdDay = _today;
      _gemAdsToday = 0;
    }
    _gemAdsToday++;
    gems += 5;
    _save();
  }

  // ---- Monsters --------------------------------------------------------------
  bool get hasFreeSlot => monsters.length < slots;

  Monster? get selectedMonster {
    if (monsters.isEmpty) return null;
    return monsters.firstWhere((m) => m.id == selectedMonsterId, orElse: () => monsters.first);
  }

  void select(Monster m) {
    selectedMonsterId = m.id;
    _save();
  }

  void addMonster(Monster m) {
    monsters.insert(0, m);
    selectedMonsterId ??= m.id;
    _save();
  }

  Future<void> releaseMonster(Monster m) async {
    monsters.removeWhere((x) => x.id == m.id);
    if (selectedMonsterId == m.id) selectedMonsterId = monsters.isEmpty ? null : monsters.first.id;
    await RoarStorage.delete(m.roarPath);
    _save();
  }

  void touch() => _save(); // after mutating a monster in place

  // ---- Battle results ------------------------------------------------------
  void recordBattle({required bool won, int? ladderStage}) {
    totalBattles++;
    if (won) totalWins++;
    if (won && ladderStage != null && ladderStage == ladderProgress && ladderProgress < MonsterFactory.totalStages) {
      ladderProgress++;
    }
    _save();
  }

  // ---- Purchases -----------------------------------------------------------
  void grantProduct(String id) {
    switch (id) {
      case ProductIds.removeAds:
        removeAds = true;
      case ProductIds.starterPack:
        if (!starterPackOwned) {
          starterPackOwned = true;
          gems += 150;
          stones += 3;
          slots += 1;
        }
      case ProductIds.gemsSmall:
        gems += 80;
      case ProductIds.gemsMedium:
        gems += 500;
      case ProductIds.gemsLarge:
        gems += 1200;
    }
    _save();
  }

  // ---- Settings --------------------------------------------------------------
  void setSound(bool v) {
    soundOn = v;
    _save();
  }

  void setHaptics(bool v) {
    hapticsOn = v;
    _save();
  }

  void completeOnboarding() {
    onboarded = true;
    _save();
  }

  Future<void> resetProgress() async {
    for (final m in monsters) {
      await RoarStorage.delete(m.roarPath);
    }
    final keepAds = removeAds;
    final keepStarter = starterPackOwned;
    await _prefs.remove(_key);
    monsters.clear();
    _applyDefaults();
    // Purchases are tied to the Google account, never lost by a reset.
    removeAds = keepAds;
    starterPackOwned = keepStarter;
    onboarded = true;
    _save();
  }

  void _applyDefaults() {
    coins = 150;
    gems = 10;
    stones = 0;
    slots = 4 + (starterPackOwned ? 1 : 0);
    _energy = maxEnergy;
    _energyStamp = DateTime.now();
    ladderProgress = 0;
    totalBattles = 0;
    totalWins = 0;
    lastDailyClaim = null;
    selectedMonsterId = null;
  }

  // ---- Persistence ---------------------------------------------------------
  Timer? _saveTimer;

  void _save() {
    notifyListeners();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 250), flush);
  }

  Future<void> flush() async {
    _saveTimer?.cancel();
    final data = {
      'onb': onboarded,
      'coins': coins,
      'gems': gems,
      'stones': stones,
      'slots': slots,
      'en': _energy,
      'enT': _energyStamp.millisecondsSinceEpoch,
      'lad': ladderProgress,
      'tb': totalBattles,
      'tw': totalWins,
      'noAds': removeAds,
      'starter': starterPackOwned,
      'snd': soundOn,
      'hap': hapticsOn,
      'daily': lastDailyClaim?.millisecondsSinceEpoch,
      'gaD': _gemAdDay,
      'gaN': _gemAdsToday,
      'sel': selectedMonsterId,
      'mons': monsters.map((m) => m.toJson()).toList(),
    };
    await _prefs.setString(_key, jsonEncode(data));
  }

  void _read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;
      onboarded = d['onb'] as bool? ?? false;
      coins = d['coins'] as int? ?? coins;
      gems = d['gems'] as int? ?? gems;
      stones = d['stones'] as int? ?? 0;
      slots = d['slots'] as int? ?? 4;
      _energy = d['en'] as int? ?? maxEnergy;
      _energyStamp = DateTime.fromMillisecondsSinceEpoch(d['enT'] as int? ?? DateTime.now().millisecondsSinceEpoch);
      ladderProgress = d['lad'] as int? ?? 0;
      totalBattles = d['tb'] as int? ?? 0;
      totalWins = d['tw'] as int? ?? 0;
      removeAds = d['noAds'] as bool? ?? false;
      starterPackOwned = d['starter'] as bool? ?? false;
      soundOn = d['snd'] as bool? ?? true;
      hapticsOn = d['hap'] as bool? ?? true;
      final daily = d['daily'] as int?;
      lastDailyClaim = daily == null ? null : DateTime.fromMillisecondsSinceEpoch(daily);
      _gemAdDay = d['gaD'] as String? ?? '';
      _gemAdsToday = d['gaN'] as int? ?? 0;
      selectedMonsterId = d['sel'] as String?;
      monsters
        ..clear()
        ..addAll((d['mons'] as List? ?? []).map((e) => Monster.fromJson(Map<String, dynamic>.from(e as Map))));
    } catch (e) {
      debugPrint('Save file unreadable, starting fresh: $e');
    }
  }
}

/// Gives any widget access to the [GameStore] and rebuilds it on changes.
class GameScope extends InheritedNotifier<GameStore> {
  const GameScope({super.key, required GameStore store, required super.child}) : super(notifier: store);

  static GameStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<GameScope>()!.notifier!;

  static GameStore read(BuildContext context) => context.getInheritedWidgetOfExactType<GameScope>()!.notifier!;
}
