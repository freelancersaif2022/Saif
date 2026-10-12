import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio.dart';
import '../core/save_data.dart';
import 'levels_screen.dart';
import 'scene_painters.dart';
import 'theme.dart';
import 'widgets.dart';

/// Final victory sequence after defeating the Shadow King.
class VictoryScreen extends StatefulWidget {
  const VictoryScreen({super.key, required this.score});
  final int score;

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> with SingleTickerProviderStateMixin, SceneClock {
  late final BackdropPainter _painter = BackdropPainter(clock, tint: const Color(0xFF6A3010), emberColor: const Color(0xFFFFC060));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 6500), () {
      if (mounted) GameAudio.instance.playMusic(Sfx.musicLobby, volume: 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(builder: (context, box) {
          final u = math.min(box.maxHeight / 720, box.maxWidth / 1280) * 1.3;
          return Stack(
            children: [
              Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _painter))),
              Center(
                child: SingleChildScrollView(
                  child: ValueListenableBuilder<double>(
                    valueListenable: clock,
                    builder: (context, t, _) {
                      double fadeAt(double s) => Curves.easeOutCubic.transform(((t - s) / 0.9).clamp(0.0, 1.0));
                      final glow = 0.75 + 0.25 * math.sin(t * 2);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: fadeAt(0.3),
                            child: Transform.scale(
                              scale: 1.3 - 0.3 * fadeAt(0.3),
                              child: Text('VICTORY', style: UiText.title(78 * u, color: const Color(0xFFFFE6B0), glow: glow)),
                            ),
                          ),
                          SizedBox(height: 12 * u),
                          Opacity(
                            opacity: fadeAt(1.2),
                            child: Container(width: 420 * u * fadeAt(1.2), height: 2, color: UiColors.gold),
                          ),
                          SizedBox(height: 14 * u),
                          Opacity(
                            opacity: fadeAt(1.6),
                            child: Text('THE SHADOW KING HAS FALLEN', textAlign: TextAlign.center, style: UiText.heading(22 * u)),
                          ),
                          SizedBox(height: 8 * u),
                          Opacity(
                            opacity: fadeAt(2.1),
                            child: Text('LIGHT RETURNS TO THE SHADOW REALM', textAlign: TextAlign.center, style: UiText.body(18 * u, color: UiColors.dim)),
                          ),
                          SizedBox(height: 22 * u),
                          Opacity(
                            opacity: fadeAt(2.7),
                            child: Column(
                              children: [
                                Text('FINAL SCORE', style: UiText.body(16 * u, color: UiColors.dim)),
                                Text('${widget.score}', style: UiText.title(40 * u, color: UiColors.gold, glow: 0.3)),
                                SizedBox(height: 4 * u),
                                Text('BEST  ${SaveData.instance.highScore}', style: UiText.body(16 * u, color: UiColors.accent)),
                              ],
                            ),
                          ),
                          SizedBox(height: 28 * u),
                          IgnorePointer(
                            ignoring: t < 3.3,
                            child: Opacity(
                              opacity: fadeAt(3.3),
                              child: Wrap(
                                spacing: 16 * u,
                                runSpacing: 12 * u,
                                alignment: WrapAlignment.center,
                                children: [
                                  CinematicButton(
                                    label: 'LOBBY',
                                    icon: Icons.home_rounded,
                                    width: 230 * u,
                                    height: 54 * u,
                                    primary: true,
                                    accent: UiColors.gold,
                                    onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                                  ),
                                  CinematicButton(
                                    label: 'LEVELS',
                                    icon: Icons.grid_view_rounded,
                                    width: 230 * u,
                                    height: 54 * u,
                                    onTap: () => Navigator.of(context).pushReplacement(FadeRoute(page: const LevelsScreen())),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
