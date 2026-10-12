import 'package:flutter/material.dart';

import '../game/amadan_game.dart';
import '../utils/save_manager.dart';
import 'ui_theme.dart';
import 'widgets.dart';

class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key, required this.game});

  final AmadanGame game;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.game.session;
    final h = MediaQuery.sizeOf(context).height;
    final u = (h / 400).clamp(0.8, 1.6);
    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    return FadeTransition(
      opacity: fade,
      child: Material(
        color: const Color(0xCC090303),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(fade),
                child: GlassPanel(
                  padding: EdgeInsets.symmetric(horizontal: 30 * u, vertical: 18 * u),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'KILLED IN ACTION',
                        style: UiText.title(28 * u).copyWith(color: const Color(0xFFE85A3C)),
                      ),
                      SizedBox(height: 4 * u),
                      Text('SURVIVED TO WAVE ${s.level}', style: UiText.label(11 * u)),
                      SizedBox(height: 14 * u),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Stat(label: 'Score', value: '${s.score}', u: u, highlight: true),
                          _Stat(label: 'Kills', value: '${s.kills}', u: u),
                          _Stat(label: 'Headshots', value: '${s.headshots}', u: u),
                          _Stat(label: 'High Score', value: '${SaveManager.highScore}', u: u),
                        ],
                      ),
                      if (s.newHighScore) ...[
                        SizedBox(height: 8 * u),
                        Text(
                          'NEW HIGH SCORE',
                          style: UiText.label(13 * u, color: UiColors.accent),
                        ),
                      ],
                      SizedBox(height: 16 * u),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MilitaryButton(
                            label: 'Restart',
                            width: 180 * u,
                            height: 44 * u,
                            fontSize: 15 * u,
                            onPressed: widget.game.restart,
                          ),
                          SizedBox(width: 14 * u),
                          MilitaryButton(
                            label: 'Lobby',
                            primary: false,
                            width: 160 * u,
                            height: 44 * u,
                            fontSize: 14 * u,
                            onPressed: widget.game.exitToLobby,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.u, this.highlight = false});

  final String label;
  final String value;
  final double u;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6 * u),
      padding: EdgeInsets.symmetric(horizontal: 12 * u, vertical: 8 * u),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: highlight ? const Color(0x88E08A2E) : const Color(0x33E0C8A0)),
      ),
      child: Column(
        children: [
          Text(label.toUpperCase(), style: UiText.label(9.5 * u)),
          SizedBox(height: 3 * u),
          Text(value, style: UiText.value(20 * u, color: highlight ? UiColors.accent : UiColors.text)),
        ],
      ),
    );
  }
}
