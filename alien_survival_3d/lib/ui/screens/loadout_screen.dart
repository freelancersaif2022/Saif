import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../progression/catalog.dart';
import '../../progression/game_state.dart';
import '../widgets.dart';

/// Weapon selection before deploying: a primary, an optional secondary and
/// the pistol sidearm (always carried).
class LoadoutScreen extends StatefulWidget {
  const LoadoutScreen({super.key, required this.state});

  final GameState state;

  @override
  State<LoadoutScreen> createState() => _LoadoutScreenState();
}

class _LoadoutScreenState extends State<LoadoutScreen> {
  late String primary = widget.state.save.primary;
  late String secondary = widget.state.save.secondary;

  void _tap(String id) {
    setState(() {
      if (id == primary) {
        if (secondary.isNotEmpty) {
          primary = secondary;
          secondary = '';
        }
      } else if (id == secondary) {
        secondary = '';
      } else if (secondary.isEmpty) {
        secondary = id;
      } else {
        secondary = primary;
        primary = id;
      }
    });
  }

  Future<void> _deploy() async {
    await widget.state.setLoadout(primary, secondary);
    if (!mounted) return;
    await Navigator.of(context).pushReplacementNamed(Routes.game);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final owned = weapons.where((w) => !w.sidearm && s.owns(w.id)).toList();
    return SubScreen(
      title: 'WEAPON SELECTION',
      state: s,
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 150,
          child: Image.asset('assets/images/soldier.png', fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox()),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Tap weapons to choose a PRIMARY and a SECONDARY. The pistol is always carried.', style: dim),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.extent(
                maxCrossAxisExtent: 260,
                childAspectRatio: 1.9,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final w in owned) _card(w, w.id == primary ? 'PRIMARY' : w.id == secondary ? 'SECONDARY' : null),
                  _card(weaponById('pistol'), 'SIDEARM', enabled: false),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(owned.length < 2 ? 'Buy more weapons in the SHOP.' : 'Loadout: ${[primary, if (secondary.isNotEmpty) secondary, 'pistol'].map((e) => weaponById(e).name).join('  ·  ')}', style: label)),
              NeonButton(key: const Key('deploy'), label: 'DEPLOY', primary: true, width: 200, height: 52, fontSize: 22, sound: 'ui_select', onPressed: _deploy),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _card(WeaponInfo w, String? role, {bool enabled = true}) {
    return GestureDetector(
      onTap: enabled ? () => _tap(w.id) : null,
      child: Panel(
        highlight: role != null,
        padding: const EdgeInsets.all(8),
        child: Stack(children: [
          Positioned.fill(child: Image.asset(w.image, fit: BoxFit.contain)),
          Positioned(left: 0, top: 0, child: Text(w.name.toUpperCase(), style: label)),
          if (role != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.lime, borderRadius: BorderRadius.circular(4)),
                child: Text(role, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
            ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Text('DMG ${w.damage.round()}${w.pellets > 1 ? '×${w.pellets}' : ''} · ${w.roundsPerMinute.round()} RPM · MAG ${w.magazine}', style: dim.copyWith(fontSize: 10)),
          ),
        ]),
      ),
    );
  }
}
