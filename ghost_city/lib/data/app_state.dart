import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/archive_api.dart';

class Memory {
  Memory({
    required this.id,
    required this.title,
    required this.placeId,
    required this.decade,
    required this.audioPath,
    required this.seconds,
    required this.createdAt,
    required this.privacy,
    this.placeName,
  });

  final String id;
  final String title;
  final String? placeId;
  final int decade;
  final String audioPath;
  final int seconds;
  final DateTime createdAt;
  final String privacy;

  /// Where it happened, as a readable name ("Mall Road, Lahore").
  final String? placeName;

  /// The year it happened. Older versions stored a decade here, which still reads fine.
  int get year => decade;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'placeId': placeId,
        'decade': decade,
        'audioPath': audioPath,
        'seconds': seconds,
        'createdAt': createdAt.toIso8601String(),
        'privacy': privacy,
        'placeName': placeName,
      };

  static Memory fromJson(Map<String, dynamic> j) => Memory(
        id: j['id'] as String,
        title: j['title'] as String,
        placeId: j['placeId'] as String?,
        decade: j['decade'] as int,
        audioPath: j['audioPath'] as String,
        seconds: j['seconds'] as int,
        createdAt: DateTime.parse(j['createdAt'] as String),
        privacy: j['privacy'] as String? ?? 'Only me',
        placeName: j['placeName'] as String?,
      );
}

/// All app state lives on the device. There is no account and no server.
class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    _onboarded = _prefs.getBool(_kOnboarded) ?? false;
    _premium = _prefs.getBool(_kPremium) ?? false;
    _saved = (_prefs.getStringList(_kSaved) ?? const []).toSet();
    _speechRate = _prefs.getDouble(_kRate) ?? 0.45;
    for (final raw in _prefs.getStringList(_kSavedPlaces) ?? const <String>[]) {
      try {
        final p = NearbyPlace.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        _savedPlaces[p.id] = p;
      } catch (_) {}
    }
    final raw = _prefs.getString(_kMemories);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _memories = list.map(Memory.fromJson).toList();
    }
  }

  static const freeMemoryLimit = 3;
  static const _kOnboarded = 'onboarded';
  static const _kPremium = 'premium';
  static const _kSaved = 'saved';
  static const _kMemories = 'memories';
  static const _kRate = 'speechRate';
  static const _kSavedPlaces = 'savedNearbyPlaces';

  final SharedPreferences _prefs;

  late bool _onboarded;
  late bool _premium;
  late Set<String> _saved;
  late double _speechRate;
  List<Memory> _memories = [];
  final Map<String, NearbyPlace> _savedPlaces = {};

  List<NearbyPlace> get savedPlaces => _savedPlaces.values.toList();
  bool isPlaceSaved(String id) => _savedPlaces.containsKey(id);

  Future<void> togglePlace(NearbyPlace p) async {
    _savedPlaces.containsKey(p.id) ? _savedPlaces.remove(p.id) : _savedPlaces[p.id] = p;
    notifyListeners();
    await _prefs.setStringList(_kSavedPlaces, _savedPlaces.values.map((p) => jsonEncode(p.toJson())).toList());
  }

  bool get onboarded => _onboarded;
  bool get premium => _premium;
  double get speechRate => _speechRate;
  List<Memory> get memories => List.unmodifiable(_memories);
  bool isSaved(String id) => _saved.contains(id);
  Set<String> get saved => Set.unmodifiable(_saved);
  bool get canRecordMore => _premium || _memories.length < freeMemoryLimit;

  Future<void> finishOnboarding() async {
    _onboarded = true;
    notifyListeners();
    await _prefs.setBool(_kOnboarded, true);
  }

  Future<void> setPremium(bool value) async {
    _premium = value;
    notifyListeners();
    await _prefs.setBool(_kPremium, value);
  }

  Future<void> toggleSaved(String id) async {
    _saved.contains(id) ? _saved.remove(id) : _saved.add(id);
    notifyListeners();
    await _prefs.setStringList(_kSaved, _saved.toList());
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    notifyListeners();
    await _prefs.setDouble(_kRate, rate);
  }

  Future<void> addMemory(Memory m) async {
    _memories = [m, ..._memories];
    notifyListeners();
    await _persistMemories();
  }

  Future<void> deleteMemory(Memory m) async {
    _memories = _memories.where((x) => x.id != m.id).toList();
    notifyListeners();
    await _persistMemories();
    try {
      final f = File(m.audioPath);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  Future<void> resetAll() async {
    for (final m in _memories) {
      try {
        final f = File(m.audioPath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    await _prefs.clear();
    _onboarded = false;
    _premium = false;
    _saved = {};
    _memories = [];
    _speechRate = 0.45;
    notifyListeners();
  }

  Future<void> _persistMemories() =>
      _prefs.setString(_kMemories, jsonEncode(_memories.map((m) => m.toJson()).toList()));
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
