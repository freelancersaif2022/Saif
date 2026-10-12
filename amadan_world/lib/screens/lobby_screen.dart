import 'dart:async';

import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../ui/atmosphere.dart';
import '../ui/lobby_soldier.dart';
import '../ui/ui_theme.dart';
import '../ui/widgets.dart';
import '../utils/asset_paths.dart';
import '../utils/save_manager.dart';
import '../weapons/weapon_data.dart';
import 'game_screen.dart';

/// Main lobby: animated soldier, weapon loadout, high score and deployment.
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late int _selected = SaveManager.weaponIndex.clamp(0, WeaponSpec.all.length - 1);
  bool _leaving = false;

  WeaponSpec get _weapon => WeaponSpec.all[_selected];

  @override
  void initState() {
    super.initState();
    unawaited(AudioManager.instance.playMusic(Sfx.musicMenu));
  }

  void _select(int i) {
    if (i == _selected) return;
    AudioManager.instance.play(Sfx.uiSelect, volume: 0.7, minGapMs: 0);
    AudioManager.instance.play(Sfx.reload, volume: 0.5, minGapMs: 0);
    setState(() => _selected = i);
    unawaited(SaveManager.saveWeapon(i));
  }

  void _start() {
    if (_leaving) return;
    _leaving = true;
    unawaited(AudioManager.instance.playMusic(Sfx.musicBattle));
    Navigator.of(context).pushReplacement(
      fadeRoute<void>(GameScreen(weapon: _weapon.type), milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight;
          final w = c.maxWidth;
          final u = (h / 400).clamp(0.75, 1.7);
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AssetPaths.lobbyBg, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0x00000000), Color(0x22000000), Color(0xC0050506)],
                    stops: [0.0, 0.42, 0.75],
                  ),
                ),
              ),
              const AtmosphereLayer(intensity: 0.8),
              Positioned(
                left: 0,
                top: h * 0.06,
                bottom: 0,
                width: w * 0.46,
                child: LobbySoldier(weapon: _weapon),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14 * u, vertical: 10 * u),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 44,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: _Brand(u: u),
                        ),
                      ),
                      SizedBox(width: 10 * u),
                      Expanded(
                        flex: 56,
                        child: _LoadoutPanel(
                          u: u,
                          selected: _selected,
                          onSelect: _select,
                          onStart: _start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF0D2), Color(0xFFE0A050)],
      ).createShader(rect),
      child: Text('AMADAN WORLD', style: UiText.title(24 * u)),
    );
  }
}

class _LoadoutPanel extends StatelessWidget {
  const _LoadoutPanel({
    required this.u,
    required this.selected,
    required this.onSelect,
    required this.onStart,
  });

  final double u;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final spec = WeaponSpec.all[selected];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GlassPanel(
            padding: EdgeInsets.symmetric(horizontal: 14 * u, vertical: 7 * u),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('HIGH SCORE', style: UiText.label(10 * u)),
                SizedBox(width: 10 * u),
                Text('${SaveManager.highScore}', style: UiText.value(20 * u, color: UiColors.accent)),
              ],
            ),
          ),
        ),
        SizedBox(height: 8 * u),
        Expanded(
          child: GlassPanel(
            padding: EdgeInsets.all(10 * u),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('LOADOUT', style: UiText.label(10 * u, color: UiColors.accent)),
                SizedBox(height: 6 * u),
                SizedBox(
                  height: 62 * u,
                  child: Row(
                    children: [
                      for (var i = 0; i < WeaponSpec.all.length; i++) ...[
                        if (i > 0) SizedBox(width: 6 * u),
                        Expanded(
                          child: _WeaponCard(
                            spec: WeaponSpec.all[i],
                            selected: i == selected,
                            u: u,
                            onTap: () => onSelect(i),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 8 * u),
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(spec.name.toUpperCase(), style: UiText.value(15 * u)),
                      ),
                    ),
                    Text(
                      '${spec.magazine} RDS',
                      style: UiText.label(10 * u, color: UiColors.accent),
                    ),
                  ],
                ),
                SizedBox(height: 2 * u),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        StatBar(label: 'Damage', value: spec.damageRating, fontSize: 9.5 * u),
                        StatBar(label: 'Fire rate', value: spec.fireRateRating, fontSize: 9.5 * u),
                        StatBar(label: 'Magazine', value: spec.magazineRating, fontSize: 9.5 * u),
                        StatBar(label: 'Reload', value: spec.reloadRating, fontSize: 9.5 * u),
                        StatBar(label: 'Range', value: spec.rangeRating, fontSize: 9.5 * u),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8 * u),
        Align(
          alignment: Alignment.centerRight,
          child: MilitaryButton(
            label: 'Start',
            width: 210 * u,
            height: 46 * u,
            fontSize: 18 * u,
            icon: Icons.play_arrow_rounded,
            onPressed: onStart,
          ),
        ),
      ],
    );
  }
}

class _WeaponCard extends StatelessWidget {
  const _WeaponCard({
    required this.spec,
    required this.selected,
    required this.u,
    required this.onTap,
  });

  final WeaponSpec spec;
  final bool selected;
  final double u;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(4 * u),
        decoration: BoxDecoration(
          color: selected ? const Color(0x40E08A2E) : const Color(0x26000000),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? UiColors.accent : const Color(0x33E0C8A0),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(spec.image, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
            ),
            SizedBox(height: 2 * u),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _short(spec.type),
                style: UiText.label(8.5 * u, color: selected ? UiColors.text : UiColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _short(WeaponType t) {
    switch (t) {
      case WeaponType.assaultRifle:
        return 'RIFLE';
      case WeaponType.smg:
        return 'SMG';
      case WeaponType.shotgun:
        return 'SHOTGUN';
      case WeaponType.sniper:
        return 'SNIPER';
    }
  }
}
