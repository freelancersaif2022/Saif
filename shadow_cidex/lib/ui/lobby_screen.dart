import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../audio.dart';
import '../core/save_data.dart';
import 'game_screen.dart';
import 'levels_screen.dart';
import 'scene_painters.dart';
import 'settings_screen.dart';
import 'theme.dart';
import 'widgets.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> with SingleTickerProviderStateMixin, SceneClock {
  late final LobbyScenePainter _painter = LobbyScenePainter(clock);
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    GameAudio.instance.playMusic(Sfx.musicLobby, volume: 0.55);
  }

  Future<void> _go(Widget page) async {
    await Navigator.of(context).push(FadeRoute(page: page));
    if (!mounted) return;
    GameAudio.instance.playMusic(Sfx.musicLobby, volume: 0.55);
    setState(() {});
  }

  void _exit() {
    if (_exiting) return;
    setState(() => _exiting = true);
    GameAudio.instance.stopMusic();
    Future.delayed(const Duration(milliseconds: 900), () {
      SystemNavigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SaveData.instance.changes,
      builder: (context, _, __) => _buildLobby(context),
    );
  }

  Widget _buildLobby(BuildContext context) {
    final save = SaveData.instance;
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, box) {
        final h = box.maxHeight;
        final w = box.maxWidth;
        final bw = math.min(300.0, w * 0.3);
        final bh = math.min(60.0, h * 0.11);
        return Stack(
          children: [
            Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _painter))),
            // Title.
            Positioned(
              top: h * 0.05,
              left: 0,
              right: 0,
              child: _Title(clock: clock, size: math.min(w * 0.06, h * 0.11)),
            ),
            // Buttons.
            Positioned(
              left: w * 0.04,
              top: h * 0.26,
              bottom: h * 0.06,
              child: SafeArea(
                right: false,
                top: false,
                bottom: false,
                child: _StaggeredColumn(
                  spacing: bh * 0.26,
                  children: [
                    CinematicButton(
                      label: 'START',
                      sub: 'LEVEL ${save.selectedLevel}',
                      width: bw,
                      height: bh * 1.15,
                      primary: true,
                      accent: UiColors.red,
                      icon: Icons.play_arrow_rounded,
                      sound: Sfx.uiLevelSelect,
                      onTap: () => _go(GameScreen(level: save.selectedLevel)),
                    ),
                    CinematicButton(
                      label: 'LEVELS',
                      width: bw,
                      height: bh,
                      icon: Icons.grid_view_rounded,
                      onTap: () => _go(const LevelsScreen()),
                    ),
                    CinematicButton(
                      label: 'SETTINGS',
                      width: bw,
                      height: bh,
                      icon: Icons.tune_rounded,
                      sound: Sfx.uiSettings,
                      onTap: () => _go(const SettingsScreen()),
                    ),
                    CinematicButton(
                      label: 'EXIT',
                      width: bw,
                      height: bh,
                      icon: Icons.power_settings_new_rounded,
                      accent: const Color(0xFF9AA4B8),
                      sound: Sfx.uiExit,
                      onTap: _exit,
                    ),
                  ],
                ),
              ),
            ),
            // Progress info.
            Positioned(
              right: w * 0.03,
              bottom: h * 0.05,
              child: SafeArea(
                left: false,
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('BEST SCORE', style: UiText.body(h * 0.026, color: UiColors.dim)),
                    Text('${save.highScore}', style: UiText.heading(h * 0.04, color: UiColors.gold)),
                    SizedBox(height: h * 0.012),
                    Text('LEVELS CLEARED  ${save.completed.length} / ${SaveData.levelCount}', style: UiText.body(h * 0.026, color: UiColors.dim)),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _exiting ? 1 : 0,
                duration: const Duration(milliseconds: 800),
                child: const ColoredBox(color: Colors.black, child: SizedBox.expand()),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.clock, required this.size});
  final ValueNotifier<double> clock;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: clock,
      builder: (context, t, _) {
        final glow = 0.75 + 0.25 * math.sin(t * 1.6);
        return Column(
          children: [
            Text('SHADOW CIDEX', textAlign: TextAlign.center, style: UiText.title(size, glow: glow)),
            SizedBox(height: size * 0.18),
            Container(
              width: size * 7,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  UiColors.red.withAlpha((200 * glow).round()),
                  Colors.transparent,
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Column whose children slide in one after another.
class _StaggeredColumn extends StatefulWidget {
  const _StaggeredColumn({required this.children, required this.spacing});
  final List<Widget> children;
  final double spacing;

  @override
  State<_StaggeredColumn> createState() => _StaggeredColumnState();
}

class _StaggeredColumnState extends State<_StaggeredColumn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.children.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < n; i++) ...[
          AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final start = i / (n + 2);
              final k = Curves.easeOutCubic.transform(((_c.value - start) / 0.45).clamp(0.0, 1.0));
              return Opacity(
                opacity: k,
                child: Transform.translate(offset: Offset(-60 * (1 - k), 0), child: child),
              );
            },
            child: widget.children[i],
          ),
          if (i < n - 1) SizedBox(height: widget.spacing),
        ],
      ],
    );
  }
}
