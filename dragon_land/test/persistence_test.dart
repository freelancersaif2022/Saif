import 'package:dragon_land/models/player_progress_model.dart';
import 'package:dragon_land/services/progress_controller.dart';
import 'package:dragon_land/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('progress survives a restart', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final p = ProgressController(storage);
    p.addCoins(3000);
    expect(p.purchaseDragon('aqua'), DragonPurchaseResult.success);
    p.selectDragon('aqua');
    p.updateSettings((s) {
      s.music = false;
      s.leftHanded = true;
      s.graphics = GraphicsQuality.low;
    });
    p.mutate((d) {
      d.bestDistance = 1234;
      d.bestScore = 5678;
      d.mission('collect_coins').progress = 42;
    });
    await p.save();

    // "restart": a new storage + controller reading the same preferences
    final storage2 = await StorageService.create();
    final p2 = ProgressController(storage2);
    expect(p2.coins, 1000);
    expect(p2.isUnlocked('aqua'), isTrue);
    expect(p2.selectedDragon.id, 'aqua');
    expect(p2.settings.music, isFalse);
    expect(p2.settings.leftHanded, isTrue);
    expect(p2.settings.graphics, GraphicsQuality.low);
    expect(p2.data.bestDistance, 1234);
    expect(p2.data.bestScore, 5678);
    expect(p2.data.mission('collect_coins').progress, 42);
  });

  test('corrupted primary copy falls back to the backup', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final p = ProgressController(storage);
    p.addCoins(777);
    await p.save();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dragon_land.progress.v1', '{not json');
    final p2 = ProgressController(await StorageService.create());
    expect(p2.coins, 777);
  });

  test('unknown selected dragon falls back to ember', () {
    final j = PlayerProgress().toJson()..['selected'] = 'solar';
    final p = PlayerProgress.fromJson(j);
    expect(p.selectedDragon, 'ember');
  });
}
