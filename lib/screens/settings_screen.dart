import 'package:flutter/material.dart';

import '../config/monetization_config.dart';
import '../services/game_store.dart';
import '../services/iap/iap_service.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';
import '../widgets/ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _reset(BuildContext context) async {
    final store = GameScope.read(context);
    final ok = await AppDialog.confirm(
      context: context,
      title: 'Reset all progress?',
      message: 'All beasts, coins, gems and arena progress will be deleted. Purchases like Remove Ads are kept.',
      confirmLabel: 'Delete everything',
      destructive: true,
      icon: Icons.delete_forever_rounded,
    );
    if (!ok) return;
    await store.resetProgress();
    if (context.mounted) Navigator.of(context).pop();
    AppToast.show('Progress reset. Time for a fresh roar!', type: ToastType.info);
  }

  @override
  Widget build(BuildContext context) {
    final store = GameScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      extendBodyBehindAppBar: true,
      body: GameBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 70, 16, 40),
            children: [
              const SectionTitle('Game'),
              Panel(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: store.soundOn,
                      onChanged: store.setSound,
                      title: Text('Sound effects', style: AppText.h3),
                      secondary: const Icon(Icons.volume_up_rounded, color: AppColors.cyan),
                    ),
                    SwitchListTile(
                      value: store.hapticsOn,
                      onChanged: store.setHaptics,
                      title: Text('Vibration', style: AppText.h3),
                      secondary: const Icon(Icons.vibration_rounded, color: AppColors.cyan),
                    ),
                  ],
                ),
              ),
              const SectionTitle('Purchases'),
              Panel(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.restore_rounded, color: AppColors.gold),
                      title: Text('Restore purchases', style: AppText.h3),
                      subtitle: Text('Get back Remove Ads & Starter Pack', style: AppText.small),
                      onTap: () => IapService.instance.restore(),
                    ),
                    ListTile(
                      leading: Icon(store.removeAds ? Icons.verified_rounded : Icons.block_rounded, color: store.removeAds ? AppColors.success : AppColors.textMute),
                      title: Text(store.removeAds ? 'Ads removed' : 'Ads active', style: AppText.h3),
                    ),
                  ],
                ),
              ),
              const SectionTitle('Stats'),
              Panel(
                child: Row(
                  children: [_Stat('Battles', '${store.totalBattles}'), _Stat('Wins', '${store.totalWins}'), _Stat('Beasts', '${store.monsters.length}'), _Stat('Stage', '${store.ladderProgress}/30')],
                ),
              ),
              const SectionTitle('Privacy'),
              Panel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_rounded, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your roars are analysed and stored only on this phone. Nothing you record is uploaded. Ads are served by Google AdMob, which may use your device advertising ID.',
                        style: AppText.small.copyWith(color: AppColors.textDim),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Center(
                child: TextButton.icon(
                  onPressed: () => _reset(context),
                  icon: const Icon(Icons.delete_forever_rounded, color: AppColors.danger),
                  label: Text('Reset progress', style: AppText.label.copyWith(color: AppColors.danger)),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text('VoiceBeast Arena v1.0.0${MonetizationConfig.testMode ? '  •  TEST MODE' : ''}', style: AppText.small.copyWith(color: AppColors.textMute)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: AppText.h2),
        Text(label, style: AppText.small),
      ],
    ),
  );
}
