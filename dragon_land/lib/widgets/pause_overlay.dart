import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import 'game_button.dart';
import 'panel.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.onResume, required this.onRestart, required this.onQuit, required this.onSettings});

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xAA140A28),
      child: Center(
        child: CartoonPanel(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('PAUSED', style: AppText.title(40, color: AppColors.orange)),
              const SizedBox(height: 14),
              GameButton(label: 'RESUME', icon: Icons.play_arrow_rounded, onPressed: onResume, color: AppColors.grass, width: 260),
              const SizedBox(height: 10),
              GameButton(label: 'RESTART', icon: Icons.refresh_rounded, onPressed: onRestart, color: AppColors.skyDeep, width: 260),
              const SizedBox(height: 10),
              GameButton(label: 'SETTINGS', icon: Icons.settings_rounded, onPressed: onSettings, color: AppColors.purple, width: 260),
              const SizedBox(height: 10),
              GameButton(label: 'MAIN MENU', icon: Icons.home_rounded, onPressed: onQuit, color: AppColors.red, width: 260),
            ],
          ),
        ),
      ),
    );
  }
}
