import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/audio_manager.dart';
import '../core/storage.dart';
import '../game/real_clash_game.dart';
import '../graphics/sprites.dart';
import 'widgets.dart';

Widget _root(Widget child) {
  return Material(type: MaterialType.transparency, child: SizedBox.expand(child: child));
}

Widget _dim({required Widget child}) {
  return _root(
    Container(
      color: const Color(0xBB05070F),
      child: SafeArea(child: Center(child: child)),
    ),
  );
}

TextStyle _title(double size) => TextStyle(
      color: Colors.white,
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: 2,
      shadows: const <Shadow>[Shadow(color: Color(0xFF000000), blurRadius: 6, offset: Offset(0, 3))],
    );

const TextStyle _label = TextStyle(color: Color(0xFFB8C8F0), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5);

// ------------------------------------------------------------------ menu

class MenuOverlay extends StatelessWidget {
  final RealClashGame game;
  const MenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return _root(
      SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 10,
              left: 12,
              child: ValueListenableBuilder<int>(
                valueListenable: game.highScore,
                builder: (BuildContext c, int v, Widget? w) => CoinPill(value: SaveData.instance.coins),
              ),
            ),
            const Positioned(top: 8, right: 12, child: SoundButton()),
            const Align(alignment: Alignment(0, -0.62), child: RealClashLogo(size: 76)),
            Align(
              alignment: const Alignment(0, 0.58),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Panel(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text('HIGH SCORE', style: _label),
                        ValueListenableBuilder<int>(
                          valueListenable: game.highScore,
                          builder: (BuildContext c, int v, Widget? w) => Text('$v', style: _title(30)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GameButton(
                    label: 'PLAY',
                    width: 230,
                    height: 72,
                    fontSize: 32,
                    color: const Color(0xFF2EBF4F),
                    icon: Icons.play_arrow_rounded,
                    onTap: game.startGame,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GameButton(
                        label: 'UPGRADES',
                        width: 140,
                        height: 48,
                        fontSize: 15,
                        color: const Color(0xFFE59A1D),
                        onTap: game.openShop,
                      ),
                      const SizedBox(width: 12),
                      GameButton(
                        label: 'SETTINGS',
                        width: 140,
                        height: 48,
                        fontSize: 15,
                        color: const Color(0xFF4A6FD0),
                        onTap: game.openSettings,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ HUD

class HudOverlay extends StatelessWidget {
  final RealClashGame game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return _root(
      SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ValueListenableBuilder<int>(
                              valueListenable: game.hearts,
                              builder: (BuildContext c, int v, Widget? w) => HeartsRow(hearts: v, size: 30),
                            ),
                            const SizedBox(height: 4),
                            ValueListenableBuilder<int>(
                              valueListenable: game.runCoins,
                              builder: (BuildContext c, int v, Widget? w) => CoinPill(value: v),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('SCORE', style: _label),
                      ValueListenableBuilder<int>(
                        valueListenable: game.score,
                        builder: (BuildContext c, int v, Widget? w) => Text('$v', style: _title(32)),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: game.highScore,
                        builder: (BuildContext c, int v, Widget? w) =>
                            Text('BEST  $v', style: const TextStyle(color: Color(0xFFFFD25A), fontSize: 13, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SoundButton(size: 44),
                            const SizedBox(width: 8),
                            RoundIconButton(size: 44, icon: Icons.pause, onTap: game.pauseGame),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 112,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Column(
                  children: <Widget>[
                    ValueListenableBuilder<String>(
                      valueListenable: game.banner,
                      builder: (BuildContext c, String v, Widget? w) {
                        if (v.isEmpty) return const SizedBox.shrink();
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            v,
                            style: TextStyle(
                              color: const Color(0xFFFFE066),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 3,
                              shadows: const <Shadow>[
                                Shadow(color: Color(0xFFFF6A00), blurRadius: 16),
                                Shadow(color: Color(0xFF000000), blurRadius: 4, offset: Offset(0, 3)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<int>(
                      valueListenable: game.armyCount,
                      builder: (BuildContext c, int v, Widget? w) => Text(
                        'ARMY  $v',
                        style: const TextStyle(color: Color(0xFF9CD0FF), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Row(
                children: <Widget>[
                  HoldButton(icon: Icons.arrow_back_rounded, onChange: (bool d) => game.leftHeld = d),
                  const SizedBox(width: 14),
                  HoldButton(icon: Icons.arrow_forward_rounded, onChange: (bool d) => game.rightHeld = d),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 18,
              child: HoldButton(
                icon: Icons.keyboard_double_arrow_up_rounded,
                size: 84,
                color: const Color(0xFFE5701D),
                onChange: (bool d) {
                  if (d) game.jump();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ pause

class PauseOverlay extends StatelessWidget {
  final RealClashGame game;
  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return _dim(
      child: Panel(
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('PAUSED', style: _title(34)),
            const SizedBox(height: 18),
            GameButton(label: 'RESUME', width: 220, color: const Color(0xFF2EBF4F), icon: Icons.play_arrow_rounded, onTap: game.resumeGame),
            const SizedBox(height: 12),
            GameButton(label: 'RESTART', width: 220, color: const Color(0xFFE59A1D), icon: Icons.replay_rounded, onTap: game.startGame),
            const SizedBox(height: 12),
            GameButton(label: 'SETTINGS', width: 220, color: const Color(0xFF4A6FD0), icon: Icons.tune_rounded, onTap: game.openSettings),
            const SizedBox(height: 12),
            GameButton(label: 'MENU', width: 220, color: const Color(0xFFC0392B), icon: Icons.home_rounded, onTap: game.toMenu),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ game over

class GameOverOverlay extends StatelessWidget {
  final RealClashGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return _dim(
      child: Panel(
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('GAME OVER', style: _title(34)),
            const SizedBox(height: 10),
            if (game.lastRunBest)
              const Text('NEW HIGH SCORE', style: TextStyle(color: Color(0xFFFFD25A), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 6),
            const Text('SCORE', style: _label),
            Text('${game.lastRunScore}', style: _title(44)),
            const SizedBox(height: 6),
            Text('BEST  ${game.save.highScore}', style: const TextStyle(color: Color(0xFFFFD25A), fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            CoinPill(value: game.lastRunCoins),
            const SizedBox(height: 18),
            GameButton(label: 'PLAY AGAIN', width: 230, height: 60, color: const Color(0xFF2EBF4F), icon: Icons.replay_rounded, onTap: game.startGame),
            const SizedBox(height: 12),
            GameButton(label: 'UPGRADES', width: 230, color: const Color(0xFFE59A1D), icon: Icons.upgrade_rounded, onTap: game.openShop),
            const SizedBox(height: 12),
            GameButton(label: 'MENU', width: 230, color: const Color(0xFFC0392B), icon: Icons.home_rounded, onTap: game.toMenu),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ shop

class ShopOverlay extends StatefulWidget {
  final RealClashGame game;
  const ShopOverlay({super.key, required this.game});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  final SaveData d = SaveData.instance;

  static const List<String> upNames = <String>['FIRE RATE', 'ARMY POWER', 'MULTI SHOT', 'COIN BONUS'];
  static const List<String> upDesc = <String>[
    'Cannon fires faster',
    'Stronger, tougher soldiers',
    'More soldiers per shot',
    'Earn extra coins',
  ];
  static const List<IconData> upIcons = <IconData>[Icons.bolt_rounded, Icons.shield_rounded, Icons.call_split_rounded, Icons.monetization_on_rounded];
  static const List<String> troopNames = <String>['RECRUIT', 'KNIGHT', 'HEAVY', 'ELITE'];
  static const List<String> troopDesc = <String>['Balanced fighter', 'Tough with sword and shield', 'Slow, very tanky', 'Fast and deadly'];
  static const List<int> troopCost = <int>[0, 400, 1000, 2200];

  int upCost(int level) => (60 * math.pow(1.55, level)).round();

  void _buyUp(int i) {
    final lvl = d.up[i];
    if (lvl >= SaveData.upMax[i]) return;
    final c = upCost(lvl);
    if (d.coins < c) return;
    d.coins -= c;
    d.up[i] = lvl + 1;
    d.save();
    AudioManager.I.sfx('coin');
    setState(() {});
  }

  void _troop(int i) {
    if (d.troopUnlocked[i]) {
      d.selectedTroop = i;
    } else if (d.coins >= troopCost[i]) {
      d.coins -= troopCost[i];
      d.troopUnlocked[i] = true;
      d.selectedTroop = i;
      AudioManager.I.sfx('gate');
    } else {
      return;
    }
    d.save();
    setState(() {});
  }

  Widget _card(Widget leading, String title, String desc, Widget trailing, {Widget? extra}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xAA0A1022),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3F5FA8), width: 2),
      ),
      child: Row(
        children: <Widget>[
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Color(0xFFA8B8E0), fontSize: 12, fontWeight: FontWeight.w600)),
                if (extra != null) ...<Widget>[const SizedBox(height: 5), extra],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    children.add(const Padding(
      padding: EdgeInsets.only(bottom: 8, top: 4),
      child: Text('UPGRADES', style: _label),
    ));
    for (var i = 0; i < 4; i++) {
      final lvl = d.up[i];
      final max = SaveData.upMax[i];
      final maxed = lvl >= max;
      final cost = upCost(lvl);
      children.add(_card(
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: <Color>[Color(0xFF3F8CFF), Color(0xFF1B3F9A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: Colors.white54, width: 2),
          ),
          child: Icon(upIcons[i], color: Colors.white, size: 26),
        ),
        upNames[i],
        upDesc[i],
        GameButton(
          label: maxed ? 'MAX' : '$cost',
          icon: maxed ? null : Icons.monetization_on_rounded,
          width: 92,
          height: 42,
          fontSize: 15,
          color: maxed ? const Color(0xFF5A5F6B) : const Color(0xFF2EBF4F),
          enabled: !maxed && d.coins >= cost,
          onTap: () => _buyUp(i),
        ),
        extra: Row(
          children: List<Widget>.generate(max, (int k) {
            return Container(
              width: 14,
              height: 6,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: k < lvl ? const Color(0xFFFFC94A) : const Color(0xFF2A3350),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ));
    }
    children.add(const Padding(
      padding: EdgeInsets.only(bottom: 8, top: 8),
      child: Text('TROOPS', style: _label),
    ));
    for (var i = 0; i < 4; i++) {
      final unlocked = d.troopUnlocked[i];
      final selected = d.selectedTroop == i;
      String label;
      if (selected) {
        label = 'EQUIPPED';
      } else if (unlocked) {
        label = 'EQUIP';
      } else {
        label = '${troopCost[i]}';
      }
      children.add(_card(
        SizedBox(
          width: 46,
          height: 66,
          child: RawImage(image: Sprites.I.get(i, 0), fit: BoxFit.contain, filterQuality: FilterQuality.medium),
        ),
        troopNames[i],
        troopDesc[i],
        GameButton(
          label: label,
          icon: (!unlocked) ? Icons.monetization_on_rounded : null,
          width: 108,
          height: 42,
          fontSize: 14,
          color: selected ? const Color(0xFF4A6FD0) : (unlocked ? const Color(0xFFE59A1D) : const Color(0xFF2EBF4F)),
          enabled: !selected && (unlocked || d.coins >= troopCost[i]),
          onTap: () => _troop(i),
        ),
      ));
    }

    return _root(
      Container(
        color: const Color(0xDD05070F),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RoundIconButton(icon: Icons.arrow_back_rounded, onTap: widget.game.closeShop),
                    const Expanded(
                      child: Center(child: Text('UPGRADES', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2))),
                    ),
                    CoinPill(value: d.coins),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ settings

class SettingsOverlay extends StatefulWidget {
  final RealClashGame game;
  const SettingsOverlay({super.key, required this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  final SaveData d = SaveData.instance;

  Widget _row(String name, double value, bool muted, ValueChanged<double> onChanged, ValueChanged<bool> onMute, {VoidCallback? onEnd}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(name, style: _label)),
              const Text('MUTE', style: _label),
              Switch(value: muted, onChanged: onMute, activeColor: const Color(0xFFFF5A5A)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF3FA9FF),
              inactiveTrackColor: const Color(0xFF2A3350),
              thumbColor: const Color(0xFFFFD25A),
              trackHeight: 6,
            ),
            child: Slider(value: value, onChanged: onChanged, onChangeEnd: (double v) {
              if (onEnd != null) onEnd();
            }),
          ),
        ],
      ),
    );
  }

  void _apply() {
    AudioManager.I.applyVolume();
    d.save();
  }

  @override
  Widget build(BuildContext context) {
    return _dim(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Panel(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('SETTINGS', style: _title(28)),
                const SizedBox(height: 10),
                _row('MASTER VOLUME', d.master, d.muteAll, (double v) {
                  setState(() => d.master = v);
                  AudioManager.I.applyVolume();
                }, (bool m) {
                  setState(() => d.muteAll = m);
                  _apply();
                }, onEnd: _apply),
                _row('MUSIC VOLUME', d.music, d.muteMusic, (double v) {
                  setState(() => d.music = v);
                  AudioManager.I.applyVolume();
                }, (bool m) {
                  setState(() => d.muteMusic = m);
                  _apply();
                }, onEnd: _apply),
                _row('EFFECTS VOLUME', d.sfx, d.muteSfx, (double v) {
                  setState(() => d.sfx = v);
                }, (bool m) {
                  setState(() => d.muteSfx = m);
                  _apply();
                }, onEnd: () {
                  _apply();
                  AudioManager.I.sfx('shoot', volume: 0.6);
                }),
                const SizedBox(height: 8),
                GameButton(label: 'BACK', width: 180, color: const Color(0xFF4A6FD0), icon: Icons.arrow_back_rounded, onTap: widget.game.closeSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
