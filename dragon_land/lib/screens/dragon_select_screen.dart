import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/app_theme.dart';
import '../app/routes.dart';
import '../models/dragon_model.dart';
import '../services/audio_service.dart';
import '../services/progress_controller.dart';
import '../widgets/coin_counter.dart';
import '../widgets/currency_icons.dart';
import '../widgets/dragon_card.dart';
import '../widgets/dragon_view.dart';
import '../widgets/game_button.dart';
import '../widgets/panel.dart';

/// Large carousel to browse and equip dragons one at a time.
class DragonSelectScreen extends StatefulWidget {
  const DragonSelectScreen({super.key});

  @override
  State<DragonSelectScreen> createState() => _DragonSelectScreenState();
}

class _DragonSelectScreenState extends State<DragonSelectScreen> {
  late int _index;
  int _celebrate = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _index = Dragons.all.indexWhere((d) => d.id == AppScope.of(context).progress.data.selectedDragon).clamp(0, 4);
  }

  void _go(int delta) {
    setState(() => _index = (_index + delta) % Dragons.all.length);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return MenuScaffold(
      title: 'SELECT DRAGON',
      onAddCoins: () => Routes.coinShop(context),
      child: ListenableBuilder(
        listenable: s.progress,
        builder: (context, _) {
          final d = Dragons.all[_index];
          final unlocked = s.progress.isUnlocked(d.id);
          final equipped = s.progress.data.selectedDragon == d.id;
          final price = ProgressController.priceOf(d.id);
          return LayoutBuilder(
            builder: (context, box) {
              final h = box.maxHeight;
              return Row(
                children: [
                  const SizedBox(width: 12),
                  RoundIconButton(icon: Icons.chevron_left_rounded, size: 60, color: AppColors.purple, onPressed: () => _go(-1)),
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragEnd: (e) {
                        final v = e.primaryVelocity ?? 0;
                        if (v.abs() > 200) _go(v < 0 ? 1 : -1);
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Column(
                          key: ValueKey(d.id),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DragonView(dragon: d, size: h * 0.66, locked: !unlocked, celebrate: _celebrate),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < Dragons.all.length; i++)
                                  Container(
                                    margin: const EdgeInsets.all(4),
                                    width: i == _index ? 22 : 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: i == _index ? AppColors.gold : Colors.white70,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: (box.maxWidth * 0.36).clamp(260.0, 380.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: h - 8),
                      child: CartoonPanel(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(d.name, style: AppText.title(34, color: d.bodyDark)),
                              Text(
                                d.elementLabel.toUpperCase(),
                                style: AppText.label(14, color: AppColors.ink, weight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${d.attackName} • ${d.specialName}',
                                style: AppText.label(14, color: AppColors.purple, weight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                d.specialDescription,
                                style: AppText.label(13, color: AppColors.ink, weight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              if (equipped)
                                Text('EQUIPPED', style: AppText.title(26, color: AppColors.goldDark))
                              else if (unlocked)
                                GameButton(
                                  label: 'SELECT',
                                  icon: Icons.check_rounded,
                                  color: AppColors.grass,
                                  width: 220,
                                  onPressed: () {
                                    if (s.progress.selectDragon(d.id)) {
                                      s.audio.play(Sfx.powerup);
                                      setState(() => _celebrate++);
                                    }
                                  },
                                )
                              else ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_rounded, color: AppColors.ink),
                                    const SizedBox(width: 6),
                                    const CoinIcon(size: 24),
                                    Text(' ${formatNumber(price)}', style: AppText.title(24, color: AppColors.goldDark)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GameButton(
                                  label: 'DETAILS',
                                  icon: Icons.info_outline_rounded,
                                  color: AppColors.orange,
                                  width: 220,
                                  onPressed: () => showDragonDetails(context, d),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  RoundIconButton(icon: Icons.chevron_right_rounded, size: 60, color: AppColors.purple, onPressed: () => _go(1)),
                  const SizedBox(width: 12),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
