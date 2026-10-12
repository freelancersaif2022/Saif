import 'package:flutter/material.dart';

import '../game/amadan_game.dart';
import 'ui_theme.dart';
import 'widgets.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final AmadanGame game;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final u = (h / 400).clamp(0.8, 1.6);
    return Material(
      color: const Color(0xB3050506),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: GlassPanel(
              padding: EdgeInsets.symmetric(horizontal: 34 * u, vertical: 22 * u),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('PAUSED', style: UiText.title(30 * u)),
                  SizedBox(height: 6 * u),
                  Text(
                    'WAVE ${game.session.level}   SCORE ${game.session.score}',
                    style: UiText.label(11 * u),
                  ),
                  SizedBox(height: 20 * u),
                  MilitaryButton(
                    label: 'Resume',
                    width: 230 * u,
                    height: 44 * u,
                    fontSize: 15 * u,
                    onPressed: game.resumeGame,
                  ),
                  SizedBox(height: 10 * u),
                  MilitaryButton(
                    label: 'Restart',
                    primary: false,
                    width: 230 * u,
                    height: 40 * u,
                    fontSize: 13 * u,
                    onPressed: game.restart,
                  ),
                  SizedBox(height: 10 * u),
                  MilitaryButton(
                    label: 'Lobby',
                    primary: false,
                    width: 230 * u,
                    height: 40 * u,
                    fontSize: 13 * u,
                    onPressed: game.exitToLobby,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
