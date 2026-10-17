import 'package:flutter/material.dart';

import '../game/battle_engine.dart';
import '../models/monster.dart';
import '../services/game_store.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';
import '../widgets/monster_view.dart';
import '../widgets/share_card.dart';
import '../widgets/ui.dart';
import 'home_shell.dart';
import 'summon_screen.dart';

class MonsterDetailScreen extends StatefulWidget {
  const MonsterDetailScreen({super.key, required this.monster});
  final Monster monster;

  static const stoneCoinPrice = 600;

  @override
  State<MonsterDetailScreen> createState() => _MonsterDetailScreenState();
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  Monster get m => widget.monster;

  Future<void> _rename() async {
    final name = await showRenameDialog(context, m.name);
    if (name == null || !mounted) return;
    setState(() => m.name = name);
    GameScope.read(context).touch();
    AppToast.show('Renamed to $name', type: ToastType.success);
  }

  Future<void> _evolve() async {
    final store = GameScope.read(context);
    final need = m.stonesForNextEvolution;
    if (!m.canEvolve) {
      AppToast.show('Reach level ${m.nextEvolutionLevel} to evolve.', type: ToastType.info, title: 'Not ready yet');
      return;
    }
    if (store.stones < need) {
      final missing = need - store.stones;
      final buy = await AppDialog.confirm(
        context: context,
        title: 'Need evolution stones',
        message: 'You need $missing more stone${missing > 1 ? 's' : ''}. Buy ${missing > 1 ? 'them' : 'one'} for ${MonsterDetailScreen.stoneCoinPrice * missing} coins?',
        confirmLabel: 'Buy for ${MonsterDetailScreen.stoneCoinPrice * missing} coins',
        icon: Icons.auto_awesome_rounded,
      );
      if (!buy) return;
      if (!store.spendCoins(MonsterDetailScreen.stoneCoinPrice * missing)) {
        AppToast.show(
          'Not enough coins. Win battles or visit the shop.',
          type: ToastType.error,
          actionLabel: 'Shop',
          onAction: () {
            if (mounted) {
              Navigator.of(context).pop();
              HomeShell.switchTab(context, 3);
            }
          },
        );
        return;
      }
      store.addStones(missing);
    }
    store.stones -= need;
    m.stage++;
    store.touch();
    Sfx.play(Fx.levelup);
    Sfx.haptic(heavy: true);
    if (!mounted) return;
    setState(() {});
    await AppDialog.show(
      context: context,
      title: '${m.name} evolved!',
      message: 'Stage ${m.stage} unlocked. All stats boosted!',
      accent: m.element.color,
      hero: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.elasticOut,
        builder: (_, v, _) => Transform.scale(
          scale: 0.5 + v * 0.5,
          child: MonsterView(monster: m, size: 200, flash: (1 - v).clamp(0.0, 1.0)),
        ),
      ),
      primaryLabel: 'Awesome!',
    );
  }

  Future<void> _release() async {
    final store = GameScope.read(context);
    final ok = await AppDialog.confirm(
      context: context,
      title: 'Release ${m.name}?',
      message: 'This cannot be undone. Its level, evolution and roar will be lost forever.',
      confirmLabel: 'Release forever',
      destructive: true,
      icon: Icons.warning_rounded,
    );
    if (!ok) return;
    await store.releaseMonster(m);
    if (!mounted) return;
    Navigator.of(context).pop();
    AppToast.show('${m.name} returned to the wild.', type: ToastType.info);
  }

  @override
  Widget build(BuildContext context) {
    final store = GameScope.of(context);
    final e = m.element;
    final isChamp = store.selectedMonster?.id == m.id;
    final moves = Move.forElement(e);
    return Scaffold(
      body: GameBackground(
        tint: e.color,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.bg1.withValues(alpha: 0.9),
                title: Text(m.name),
                actions: [IconButton(onPressed: _rename, icon: const Icon(Icons.edit_rounded))],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList.list(
                  children: [
                    Pressable(
                      sound: false,
                      onTap: () => Sfx.roar(m.roarPath),
                      child: Column(
                        children: [
                          MonsterView(monster: m, size: 260),
                          Text(m.roarPath != null ? 'Tap to hear its roar' : 'Tap to hear a roar', style: AppText.small.copyWith(color: AppColors.textMute)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [RarityTag(m.rarity), const SizedBox(width: 8), ElementBadge(e)]),
                    const SizedBox(height: 14),
                    if (!isChamp)
                      GameButton(
                        label: 'Set as Champion',
                        icon: Icons.star_rounded,
                        color: AppColors.gold,
                        expand: true,
                        small: true,
                        onTap: () {
                          store.select(m);
                          AppToast.show('${m.name} is now your champion!', type: ToastType.success);
                        },
                      )
                    else
                      Center(
                        child: Text('★ Your champion', style: AppText.h3.copyWith(color: AppColors.gold)),
                      ),
                    const SizedBox(height: 12),
                    Panel(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Level ${m.level}', style: AppText.h2),
                              const Spacer(),
                              Text('Power ${m.power}', style: AppText.h3.copyWith(color: AppColors.gold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(value: m.xpProgress, minHeight: 10, color: AppColors.cyan, backgroundColor: Colors.black38),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(m.level >= Monster.maxLevel ? 'MAX LEVEL' : '${m.xp} / ${m.xpToNext} XP', style: AppText.small),
                          ),
                          const Divider(height: 22, color: AppColors.stroke),
                          StatBar(label: 'HP', value: m.maxHp, max: 700, color: AppColors.success, icon: Icons.favorite_rounded),
                          const SizedBox(height: 10),
                          StatBar(label: 'ATK', value: m.atk, max: 300, color: AppColors.danger, icon: Icons.local_fire_department_rounded),
                          const SizedBox(height: 10),
                          StatBar(label: 'DEF', value: m.def, max: 300, color: AppColors.cyan, icon: Icons.shield_rounded),
                          const SizedBox(height: 10),
                          StatBar(label: 'SPD', value: m.spd, max: 300, color: AppColors.gold, icon: Icons.speed_rounded),
                        ],
                      ),
                    ),
                    const SectionTitle('Evolution'),
                    _EvolutionPanel(monster: m, stones: store.stones, onEvolve: _evolve),
                    const SectionTitle('Moves'),
                    Panel(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Column(
                        children: [
                          for (final mv in moves)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Icon(_moveIcon(mv.kind), color: mv.kind == MoveKind.special ? e.color : AppColors.textDim),
                              title: Text(mv.name, style: AppText.h3),
                              subtitle: Text(mv.description, style: AppText.small),
                              trailing: mv.power > 0 ? Text('PWR ${mv.power}', style: AppText.label.copyWith(color: AppColors.textDim)) : null,
                            ),
                        ],
                      ),
                    ),
                    const SectionTitle('Strengths'),
                    Panel(
                      child: Row(
                        children: [
                          Expanded(
                            child: _Matchup(label: 'Strong vs', element: e.beats.label, emoji: e.beats.emoji, color: AppColors.success),
                          ),
                          Container(width: 1, height: 40, color: AppColors.stroke),
                          Expanded(
                            child: _Matchup(label: 'Weak vs', element: e.weakTo.label, emoji: e.weakTo.emoji, color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                    if (m.voice != null) ...[
                      const SectionTitle('Born from your roar'),
                      Panel(
                        child: Row(
                          children: [
                            _Info('Pitch', '${m.voice!.pitchHz.round()} Hz'),
                            _Info('Power', '${(m.voice!.loudnessDb + 60).round()} dB'),
                            _Info('Rasp', '${(m.voice!.roughness * 100).round()}%'),
                            _Info('Record', '${m.wins}W ${m.losses}L'),
                          ],
                        ),
                      ),
                    ],
                    const SectionTitle('Share'),
                    Row(
                      children: [
                        Expanded(
                          child: GameButton(label: 'Card', icon: Icons.image_rounded, color: AppColors.success, small: true, onTap: () => ShareService.showCardPreview(context, m)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GameButton(label: 'QR', icon: Icons.qr_code_2_rounded, color: const Color(0xFF7C4DFF), small: true, onTap: () => ShareService.showChallengeQr(context, m)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GameButton(label: 'Roar', icon: Icons.graphic_eq_rounded, color: AppColors.primary, small: true, onTap: () => ShareService.shareRoar(m)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Center(
                      child: TextButton.icon(
                        onPressed: _release,
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                        label: Text('Release beast', style: AppText.label.copyWith(color: AppColors.danger)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _moveIcon(MoveKind k) => switch (k) {
    MoveKind.claw => Icons.back_hand_rounded,
    MoveKind.special => Icons.auto_awesome_rounded,
    MoveKind.roar => Icons.campaign_rounded,
    MoveKind.guard => Icons.shield_rounded,
  };
}

class _EvolutionPanel extends StatelessWidget {
  const _EvolutionPanel({required this.monster, required this.stones, required this.onEvolve});
  final Monster monster;
  final int stones;
  final VoidCallback onEvolve;

  @override
  Widget build(BuildContext context) {
    final next = monster.nextEvolutionLevel;
    return Panel(
      child: Column(
        children: [
          Row(
            children: [
              for (var s = 1; s <= 3; s++) ...[
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(color: s <= monster.stage ? monster.element.color : Colors.black38, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                if (s < 3) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text(next == null ? 'Final form reached!' : 'Stage ${monster.stage}/3 • Evolves at Lv $next', style: AppText.label)),
              const CurrencyIcon(Currency.stones, size: 18),
              const SizedBox(width: 4),
              Text('$stones', style: AppText.number),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 12),
            GameButton(
              label: monster.canEvolve ? 'Evolve • ${monster.stonesForNextEvolution} stone${monster.stonesForNextEvolution > 1 ? 's' : ''}' : 'Reach Lv $next to evolve',
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFFE040FB),
              expand: true,
              small: true,
              onTap: monster.canEvolve ? onEvolve : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _Matchup extends StatelessWidget {
  const _Matchup({required this.label, required this.element, required this.emoji, required this.color});
  final String label;
  final String element;
  final String emoji;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label.toUpperCase(),
        style: AppText.small.copyWith(color: color, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
      const SizedBox(height: 4),
      Text('$emoji $element', style: AppText.h3),
    ],
  );
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(label.toUpperCase(), style: AppText.small.copyWith(fontSize: 10.5, letterSpacing: 1)),
        const SizedBox(height: 3),
        FittedBox(child: Text(value, style: AppText.h3)),
      ],
    ),
  );
}
