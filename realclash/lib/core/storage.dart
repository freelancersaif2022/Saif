import 'package:shared_preferences/shared_preferences.dart';

class SaveData {
  static final SaveData instance = SaveData._();
  SaveData._();

  SharedPreferences? _p;

  int highScore = 0;
  int coins = 0;
  // 0 fire rate, 1 army power, 2 multi shot, 3 coin bonus
  List<int> up = <int>[0, 0, 0, 0];
  static const List<int> upMax = <int>[8, 8, 4, 6];
  int selectedTroop = 0;
  List<bool> troopUnlocked = <bool>[true, false, false, false];

  double master = 1.0;
  double music = 0.7;
  double sfx = 1.0;
  bool muteAll = false;
  bool muteMusic = false;
  bool muteSfx = false;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _p = p;
      highScore = p.getInt('hs') ?? 0;
      coins = p.getInt('coins') ?? 0;
      final u = p.getStringList('up');
      if (u != null && u.length == 4) {
        up = u.map((e) => int.tryParse(e) ?? 0).toList();
      }
      selectedTroop = p.getInt('troop') ?? 0;
      final t = p.getStringList('troops');
      if (t != null && t.length == 4) {
        troopUnlocked = t.map((e) => e == '1').toList();
        troopUnlocked[0] = true;
      }
      master = p.getDouble('master') ?? 1.0;
      music = p.getDouble('music') ?? 0.7;
      sfx = p.getDouble('sfx') ?? 1.0;
      muteAll = p.getBool('muteAll') ?? false;
      muteMusic = p.getBool('muteMusic') ?? false;
      muteSfx = p.getBool('muteSfx') ?? false;
    } catch (_) {}
  }

  Future<void> save() async {
    try {
      final p = _p ?? await SharedPreferences.getInstance();
      _p = p;
      await p.setInt('hs', highScore);
      await p.setInt('coins', coins);
      await p.setStringList('up', up.map((e) => e.toString()).toList());
      await p.setInt('troop', selectedTroop);
      await p.setStringList('troops', troopUnlocked.map((e) => e ? '1' : '0').toList());
      await p.setDouble('master', master);
      await p.setDouble('music', music);
      await p.setDouble('sfx', sfx);
      await p.setBool('muteAll', muteAll);
      await p.setBool('muteMusic', muteMusic);
      await p.setBool('muteSfx', muteSfx);
    } catch (_) {}
  }
}
