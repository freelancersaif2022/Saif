import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../app/routes.dart';
import '../models/dragon_model.dart';
import '../services/audio_service.dart';
import '../services/progress_controller.dart';
import 'coin_counter.dart';
import 'currency_icons.dart';
import 'dragon_view.dart';
import 'game_button.dart';
import 'panel.dart';

/// Card for one dragon in the Dragon Shop grid.
class DragonCard extends StatelessWidget {
  const DragonCard({super.key, required this.dragon, required this.onTap});

  final DragonDef dragon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListenableBuilder(
      listenable: s.progress,
      builder: (context, _) {
        final unlocked = s.progress.isUnlocked(dragon.id);
        final equipped = s.progress.data.selectedDragon == dragon.id;
        final price = ProgressController.priceOf(dragon.id);
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: equipped ? AppColors.gold : AppColors.ink, width: equipped ? 4 : 3),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(dragon.glow, Colors.white, 0.55)!, Color.lerp(dragon.body, Colors.white, 0.15)!],
              ),
              boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 5))],
            ),
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              children: [
                Text(dragon.name, style: AppText.title(22)),
                Text(
                  dragon.elementLabel.toUpperCase(),
                  style: AppText.label(11, color: AppColors.ink, weight: FontWeight.w700),
                ),
                Expanded(
                  child: FittedBox(
                    child: DragonView(dragon: dragon, size: 150, interactive: false, locked: !unlocked),
                  ),
                ),
                Text(
                  dragon.specialName,
                  style: AppText.label(12, color: AppColors.ink, weight: FontWeight.w700),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                if (equipped)
                  const _Tag(text: 'EQUIPPED', color: AppColors.gold)
                else if (unlocked)
                  const _Tag(text: 'SELECT', color: AppColors.grass)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xCC2A1636), borderRadius: BorderRadius.circular(14)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          const CoinIcon(size: 18),
                          const SizedBox(width: 4),
                          Text(formatNumber(price), style: AppText.title(16)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.ink, width: 2),
    ),
    child: Text(text, style: AppText.title(15)),
  );
}

/// Detail dialog for a dragon with purchase / equip actions.
///
/// The purchase is executed by [ProgressController.purchaseDragon], which
/// validates ownership and balance and deducts the price exactly once.
Future<void> showDragonDetails(BuildContext context, DragonDef dragon) {
  final s = AppScope.of(context);
  return showCartoonDialog(
    context,
    title: dragon.name,
    body: ListenableBuilder(
      listenable: s.progress,
      builder: (ctx, _) {
        final unlocked = s.progress.isUnlocked(dragon.id);
        final equipped = s.progress.data.selectedDragon == dragon.id;
        final price = ProgressController.priceOf(dragon.id);
        final enough = s.progress.coins >= price;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                DragonView(dragon: dragon, size: 150, locked: !unlocked),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _info('Element', dragon.elementLabel),
                      _info('Attack', dragon.attackName),
                      _info('Special', dragon.specialName),
                      const SizedBox(height: 4),
                      Text(
                        dragon.specialDescription,
                        style: AppText.label(13, color: AppColors.ink, weight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dragon.personality,
              style: AppText.label(13, color: const Color(0xFF6B5A7A), weight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (!unlocked) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Price: ', style: AppText.label(16, color: AppColors.ink)),
                  const CoinIcon(size: 22),
                  Text(' ${formatNumber(price)}', style: AppText.title(20, color: AppColors.goldDark)),
                  const SizedBox(width: 18),
                  Text('You have: ', style: AppText.label(16, color: AppColors.ink)),
                  const CoinIcon(size: 22),
                  Text(' ${formatNumber(s.progress.coins)}', style: AppText.title(20, color: enough ? AppColors.grassDark : AppColors.red)),
                ],
              ),
              const SizedBox(height: 12),
              if (enough)
                GameButton(
                  label: 'UNLOCK',
                  icon: Icons.lock_open_rounded,
                  color: AppColors.grass,
                  width: 240,
                  cooldown: const Duration(seconds: 1),
                  onPressed: () {
                    final r = s.progress.purchaseDragon(dragon.id);
                    if (r == DragonPurchaseResult.success) {
                      s.audio.play(Sfx.unlock);
                      s.audio.vibrate();
                      showMessage(context, '${dragon.name} unlocked!');
                    }
                  },
                )
              else ...[
                Text(
                  'Not enough coins. Keep running to earn ${formatNumber(price - s.progress.coins)} more, or visit the shop.',
                  style: AppText.label(14, color: AppColors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                GameButton(
                  label: 'COIN SHOP',
                  icon: Icons.storefront_rounded,
                  color: AppColors.gold,
                  width: 240,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Routes.coinShop(context);
                  },
                ),
              ],
            ] else if (equipped)
              Text('EQUIPPED', style: AppText.title(24, color: AppColors.goldDark))
            else
              GameButton(
                label: 'EQUIP',
                icon: Icons.check_rounded,
                color: AppColors.orange,
                width: 240,
                onPressed: () {
                  s.progress.selectDragon(dragon.id);
                  s.audio.play(Sfx.powerup);
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        );
      },
    ),
  );
}

Widget _info(String k, String v) => Padding(
  padding: const EdgeInsets.only(bottom: 2),
  child: RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '$k: ',
          style: AppText.label(14, color: const Color(0xFF6B5A7A)),
        ),
        TextSpan(
          text: v,
          style: AppText.label(15, color: AppColors.ink, weight: FontWeight.w700),
        ),
      ],
    ),
  ),
);
