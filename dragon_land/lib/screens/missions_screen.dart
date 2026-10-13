import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../models/mission_model.dart';
import '../services/audio_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/coin_counter.dart';
import '../widgets/currency_icons.dart';
import '../widgets/game_button.dart';
import '../widgets/panel.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  static IconData _icon(MissionStat s) => switch (s) {
    MissionStat.coins => Icons.monetization_on_rounded,
    MissionStat.distance => Icons.directions_run_rounded,
    MissionStat.enemies => Icons.sports_martial_arts_rounded,
    MissionStat.flights => Icons.flight_rounded,
    MissionStat.attacks => Icons.local_fire_department_rounded,
    MissionStat.runs => Icons.replay_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return MenuScaffold(
      title: 'MISSIONS',
      bottom: const BannerAdSlot(),
      child: ListenableBuilder(
        listenable: s.progress,
        builder: (context, _) => GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 84,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
          children: [
            for (final m in MissionDef.all)
              Builder(
                builder: (context) {
                  final tier = s.rewards.missionTier(m);
                  final target = s.rewards.missionTarget(m);
                  final progress = s.rewards.missionProgress(m).clamp(0, target);
                  final done = s.rewards.missionComplete(m);
                  return CartoonPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: done ? const Color(0xFFFFF0B3) : AppColors.panel,
                    child: Row(
                      children: [
                        Icon(_icon(m.stat), color: AppColors.purple, size: 34),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.titleForTier(tier),
                                style: AppText.label(15, color: AppColors.ink, weight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: target == 0 ? 0 : progress / target,
                                  minHeight: 10,
                                  color: done ? AppColors.gold : AppColors.grass,
                                  backgroundColor: const Color(0x332A1636),
                                ),
                              ),
                              Text(
                                '${formatNumber(progress)} / ${formatNumber(target)}  •  Level ${tier + 1}',
                                style: AppText.label(11, color: const Color(0xFF6B5A7A)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        done
                            ? GameButton(
                                label: '${m.rewardForTier(tier)}',
                                leading: const CoinIcon(size: 20),
                                color: AppColors.grass,
                                height: 40,
                                fontSize: 16,
                                cooldown: const Duration(seconds: 1),
                                onPressed: () {
                                  final r = s.rewards.claimMission(m);
                                  if (r != null) {
                                    s.audio.play(Sfx.purchase);
                                    showMessage(context, 'Mission complete! +${formatNumber(r)} coins');
                                  }
                                },
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CoinIcon(size: 20),
                                  Text(' ${m.rewardForTier(tier)}', style: AppText.title(16, color: AppColors.goldDark)),
                                ],
                              ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
