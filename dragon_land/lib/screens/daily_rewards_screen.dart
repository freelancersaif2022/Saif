import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../config/economy_config.dart';
import '../services/audio_service.dart';
import '../services/reward_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/coin_counter.dart';
import '../widgets/currency_icons.dart';
import '../widgets/game_button.dart';
import '../widgets/panel.dart';

class DailyRewardsScreen extends StatelessWidget {
  const DailyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return MenuScaffold(
      title: 'DAILY REWARDS',
      bottom: const BannerAdSlot(),
      child: ListenableBuilder(
        listenable: s.progress,
        builder: (context, _) {
          final status = s.rewards.dailyStatus;
          final current = s.rewards.currentDisplayDay;
          final claimedThrough = status == DailyStatus.claimedToday ? s.progress.data.dailyStreak : current - 1;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final r in EconomyConfig.dailyRewards)
                      _DayCard(reward: r, claimed: r.day <= claimedThrough, today: r.day == current && status == DailyStatus.available),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              switch (status) {
                DailyStatus.available => GameButton(
                  label: 'CLAIM DAY $current',
                  icon: Icons.card_giftcard_rounded,
                  color: AppColors.grass,
                  width: 280,
                  pulse: true,
                  cooldown: const Duration(seconds: 1),
                  onPressed: () {
                    final r = s.rewards.claimDaily();
                    if (r != null) {
                      s.audio.play(Sfx.chest);
                      showMessage(context, '+${formatNumber(r.coins)} coins${r.gems > 0 ? ' and +${r.gems} gems' : ''}!');
                    }
                  },
                ),
                DailyStatus.claimedToday => Text('Come back tomorrow for Day ${current >= 7 ? 1 : current + 1}!', style: AppText.title(22)),
                DailyStatus.clockError => Text(
                  'Please check your device date and time.',
                  style: AppText.title(20, color: const Color(0xFFFFB3B3)),
                ),
              },
              const SizedBox(height: 6),
              Text('Miss a day and the streak starts over at Day 1.', style: AppText.label(13)),
            ],
          );
        },
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.reward, required this.claimed, required this.today});
  final DailyRewardDef reward;
  final bool claimed;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final big = reward.day == 7;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: today ? 1.06 : 1,
        child: Container(
          width: big ? 150 : 108,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: claimed ? const Color(0xFFCFE9C9) : (today ? const Color(0xFFFFF0B3) : AppColors.panel),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: today ? AppColors.gold : AppColors.ink, width: today ? 4 : 3),
            boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(0, 4))],
          ),
          child: Column(
            children: [
              Text('DAY ${reward.day}', style: AppText.title(18, color: AppColors.orange)),
              const Spacer(),
              if (claimed)
                const Icon(Icons.check_circle_rounded, color: AppColors.grassDark, size: 48)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CoinIcon(size: big ? 44 : 36),
                    if (reward.gems > 0) const GemIcon(size: 34),
                  ],
                ),
              const Spacer(),
              Text(formatNumber(reward.coins), style: AppText.title(20, color: AppColors.goldDark)),
              if (reward.gems > 0)
                Text(
                  '+${reward.gems} gems',
                  style: AppText.label(12, color: AppColors.purple, weight: FontWeight.w700),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
