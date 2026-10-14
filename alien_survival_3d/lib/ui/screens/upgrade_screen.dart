import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../progression/catalog.dart';
import '../../progression/game_state.dart';
import '../widgets.dart';

/// Permanent upgrades: per-weapon damage / magazine / reload speed, and the
/// soldier's max health, armor and grenade capacity.
class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key, required this.state});

  final GameState state;

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  String selected = 'soldier';

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final owned = weapons.where((w) => s.owns(w.id)).toList();
    return SubScreen(
      title: 'UPGRADES',
      state: s,
      child: ListenableBuilder(
        listenable: s,
        builder: (context, _) => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 190,
            child: ListView(children: [
              _tab('soldier', 'SOLDIER', Icons.person),
              for (final w in owned) _tab(w.id, w.name.toUpperCase(), Icons.gps_fixed),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(child: selected == 'soldier' ? _soldier(s) : _weapon(s, weaponById(selected))),
        ]),
      ),
    );
  }

  Widget _tab(String id, String text, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: NeonButton(key: Key('tab_$id'), label: text, icon: icon, primary: selected == id, height: 40, fontSize: 12, onPressed: () => setState(() => selected = id)),
      );

  Widget _row({required String name, required String detail, required int level, required int max, required Cost cost, required Future<PurchaseResult> Function() buy, required Key key}) {
    final maxed = level >= max;
    final s = widget.state;
    final affordable = s.save.coins >= cost.coins && s.save.gems >= cost.gems;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Panel(
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name.toUpperCase(), style: label.copyWith(fontSize: 15)),
              const SizedBox(height: 4),
              LevelPips(level: level, max: max),
              const SizedBox(height: 4),
              Text(detail, style: dim),
            ]),
          ),
          SizedBox(
            width: 170,
            child: maxed
                ? const NeonButton(label: 'MAX', onPressed: null, height: 40)
                : NeonButton(
                    key: key,
                    label: '${cost.coins}${cost.gems > 0 ? ' + ${cost.gems}♦' : ''}',
                    icon: Icons.upgrade,
                    primary: affordable,
                    height: 40,
                    sound: 'ui_select',
                    onPressed: () async {
                      final r = await buy();
                      if (mounted && r != PurchaseResult.ok) showMessage(context, purchaseMessage(r));
                    },
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _soldier(GameState s) {
    final st = enginePlayerStats(s.save.playerLevels);
    return ListView(children: [
      for (final p in PlayerStat.values)
        _row(
          key: Key('up_${p.name}'),
          name: playerStatLabel(p),
          detail: switch (p) {
            PlayerStat.health => 'Max health ${st['maxHealth']}  (+20 per level)',
            PlayerStat.armor => 'Armor capacity ${st['maxArmor']}, start with ${st['startArmor']}',
            PlayerStat.grenades => 'Start with ${st['grenades']} grenades, carry up to ${st['maxGrenades']}',
          },
          level: s.save.playerLevel(p),
          max: maxPlayerLevel[p]!,
          cost: playerUpgradeCost(p, s.save.playerLevel(p)),
          buy: () => s.upgradePlayer(p),
        ),
    ]);
  }

  Widget _weapon(GameState s, WeaponInfo w) {
    final lv = s.save.weaponLevels[w.id] ?? const {};
    final st = engineWeaponStats(w.id, lv);
    return ListView(children: [
      SizedBox(height: 90, child: Image.asset(w.image, fit: BoxFit.contain)),
      for (final stat in WeaponStat.values)
        _row(
          key: Key('up_${w.id}_${stat.name}'),
          name: weaponStatLabel(stat),
          detail: switch (stat) {
            WeaponStat.damage => 'Damage ${st['damage']}${w.pellets > 1 ? ' × ${w.pellets} pellets' : ''}  (+12% per level)',
            WeaponStat.magazine => 'Magazine ${st['mag']} rounds  (+15% per level)',
            WeaponStat.reload => 'Reload ${(st['reload'] as double).toStringAsFixed(2)} s  (−10% per level)',
          },
          level: s.save.weaponLevel(w.id, stat),
          max: maxWeaponLevel,
          cost: weaponUpgradeCost(w.id, stat, s.save.weaponLevel(w.id, stat)),
          buy: () => s.upgradeWeapon(w.id, stat),
        ),
    ]);
  }
}
