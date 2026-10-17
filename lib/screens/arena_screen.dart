import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../game/monster_factory.dart';
import '../models/monster.dart';
import '../services/ads/ad_service.dart';
import '../services/game_store.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';
import '../widgets/monster_view.dart';
import '../widgets/ui.dart';
import 'battle_screen.dart';
import 'home_shell.dart';
import 'scan_screen.dart';

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  static const refillGemPrice = 15;

  @override
  Widget build(BuildContext context) {
    final store = GameScope.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TopHud(title: 'Arena'),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverList.list(
                    children: [
                      const _EnergyPanel(),
                      const SizedBox(height: 12),
                      const _FriendChallengePanel(),
                      SectionTitle(
                        'Arena Ladder',
                        trailing: Text('${store.ladderProgress}/${MonsterFactory.totalStages}', style: AppText.h3.copyWith(color: AppColors.gold)),
                      ),
                    ],
                  ),
                ),
                for (var tier = 0; tier < MonsterFactory.tiers.length; tier++) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Text(MonsterFactory.tiers[tier], style: AppText.h2.copyWith(color: _tierColor(tier))),
                          const SizedBox(width: 10),
                          Expanded(child: Container(height: 1, color: _tierColor(tier).withValues(alpha: 0.3))),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: MonsterFactory.stagesPerTier,
                      itemBuilder: (c, i) {
                        final stage = tier * MonsterFactory.stagesPerTier + i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _StageTile(stage: stage, progress: store.ladderProgress),
                        );
                      },
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _tierColor(int tier) => const [Color(0xFFB08D57), Color(0xFFE0E0E0), Color(0xFFFF7043), Color(0xFFFFEB3B), Color(0xFFB388FF), Color(0xFFFFC93C)][tier];

  /// Shared entry point for all battles (ladder + friends).
  static Future<void> startBattle(BuildContext context, {required Monster enemy, int? ladderStage}) async {
    final store = GameScope.read(context);
    if (store.monsters.isEmpty) {
      AppToast.show(
        'Summon a beast before entering the arena.',
        type: ToastType.info,
        title: 'No beast yet',
        actionLabel: 'Summon',
        onAction: () {
          if (context.mounted) HomeShell.switchTab(context, 1);
        },
      );
      return;
    }
    final fighter = await showModalBottomSheet<Monster>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PreBattleSheet(enemy: enemy, ladderStage: ladderStage),
    );
    if (fighter == null || !context.mounted) return;
    if (!await ensureEnergy(context)) return;
    if (!context.mounted) return;
    store.spendEnergy();
    store.select(fighter);
    await Navigator.of(context).push(gameRoute(BattleScreen(player: fighter, enemy: enemy, ladderStage: ladderStage)));
  }

  static Future<bool> ensureEnergy(BuildContext context) async {
    final store = GameScope.read(context);
    if (store.energy > 0) return true;
    final choice = await AppDialog.show<String>(
      context: context,
      title: 'Out of energy',
      message: 'Energy refills 1 every 10 minutes. Or get back in the fight now:',
      accent: AppColors.energy,
      hero: const IconBadge(icon: Icons.bolt_rounded, color: AppColors.energy, size: 76),
      primaryLabel: 'Watch ad • +5 energy',
      primaryIcon: Icons.play_circle_fill_rounded,
      primaryColor: AppColors.success,
      onPrimary: () => Navigator.of(context).pop('ad'),
      secondaryLabel: 'Refill for $refillGemPrice gems',
      onSecondary: () => Navigator.of(context).pop('gems'),
    );
    if (choice == 'ad') {
      final earned = await AdService.instance.showRewarded(rewardLabel: '+5 energy');
      if (earned) {
        store.addEnergy(5);
        AppToast.show('+5 energy! Back to battle.', type: ToastType.reward);
        return true;
      }
    } else if (choice == 'gems') {
      if (store.spendGems(refillGemPrice)) {
        store.addEnergy(GameStore.maxEnergy);
        AppToast.show('Energy fully refilled!', type: ToastType.success);
        return true;
      }
      AppToast.show(
        'Not enough gems.',
        type: ToastType.error,
        actionLabel: 'Shop',
        onAction: () {
          if (context.mounted) HomeShell.switchTab(context, 3);
        },
      );
    }
    return false;
  }
}

class _EnergyPanel extends StatefulWidget {
  const _EnergyPanel();
  @override
  State<_EnergyPanel> createState() => _EnergyPanelState();
}

class _EnergyPanelState extends State<_EnergyPanel> {
  Timer? _t;
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> _watch() async {
    final store = GameScope.read(context);
    final earned = await AdService.instance.showRewarded(rewardLabel: '+5 energy');
    if (earned) {
      store.addEnergy(5);
      AppToast.show('+5 energy added!', type: ToastType.reward);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = GameScope.of(context);
    final e = store.energy;
    final full = e >= GameStore.maxEnergy;
    return Panel(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          const CurrencyIcon(Currency.energy, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Energy $e/${GameStore.maxEnergy}', style: AppText.h3),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(value: (e / GameStore.maxEnergy).clamp(0, 1), minHeight: 8, color: AppColors.energy, backgroundColor: Colors.black38),
                ),
                const SizedBox(height: 4),
                Text(full ? 'Full • 1 energy per battle' : '+1 in ${formatDuration(store.nextEnergyIn)}', style: AppText.small),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GameButton(label: '+5', icon: Icons.play_circle_fill_rounded, color: AppColors.success, small: true, onTap: _watch),
        ],
      ),
    );
  }
}

class _FriendChallengePanel extends StatelessWidget {
  const _FriendChallengePanel();

  Future<void> _enterCode(BuildContext context) async {
    final ctrl = TextEditingController();
    final clip = await Clipboard.getData(Clipboard.kTextPlain);
    if (clip?.text?.contains('VBA1.') ?? false) ctrl.text = clip!.text!;
    if (!context.mounted) return;
    Monster? enemy;
    await AppDialog.show(
      context: context,
      title: 'Enter challenge code',
      message: 'Paste the code your friend sent you.',
      accent: AppColors.cyan,
      hero: const IconBadge(icon: Icons.key_rounded, color: AppColors.cyan),
      body: TextField(
        controller: ctrl,
        maxLines: 3,
        minLines: 1,
        style: AppText.label,
        decoration: const InputDecoration(hintText: 'VBA1.xxxxxxxx'),
      ),
      primaryLabel: 'Find beast',
      onPrimary: () {
        final m = Monster.fromChallengeCode(ctrl.text);
        if (m == null) {
          AppToast.show('That code is not valid. Check it and try again.', type: ToastType.error, title: 'Invalid code');
          return;
        }
        enemy = m;
        Navigator.of(context).pop();
      },
      secondaryLabel: 'Cancel',
    );
    if (enemy != null && context.mounted) await ArenaScreen.startBattle(context, enemy: enemy!);
  }

  Future<void> _scan(BuildContext context) async {
    final m = await Navigator.of(context).push<Monster>(gameRoute(const ScanScreen()));
    if (m != null && context.mounted) await ArenaScreen.startBattle(context, enemy: m);
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      gradient: LinearGradient(colors: [const Color(0xFF7C4DFF).withValues(alpha: 0.35), AppColors.surface]),
      borderColor: const Color(0xFF7C4DFF).withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_rounded, color: Color(0xFFB39DFF), size: 28),
              const SizedBox(width: 10),
              Expanded(child: Text('Challenge a Friend', style: AppText.h2)),
            ],
          ),
          const SizedBox(height: 4),
          Text("Scan a friend's beast QR or paste their code. No internet needed.", style: AppText.small),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GameButton(label: 'Scan QR', icon: Icons.qr_code_scanner_rounded, color: const Color(0xFF7C4DFF), small: true, onTap: () => _scan(context)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GameButton(label: 'Enter Code', icon: Icons.keyboard_rounded, color: AppColors.surfaceHi, small: true, onTap: () => _enterCode(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({required this.stage, required this.progress});
  final int stage;
  final int progress;

  @override
  Widget build(BuildContext context) {
    final cleared = stage < progress;
    final current = stage == progress;
    final locked = stage > progress;
    final boss = MonsterFactory.isBoss(stage);
    final enemy = MonsterFactory.opponentForStage(stage);
    final accent = boss ? AppColors.danger : enemy.element.color;
    return Pressable(
      onTap: locked
          ? () => AppToast.show('Beat stage $stage first to unlock this fight.', type: ToastType.info, title: 'Locked')
          : () => ArenaScreen.startBattle(context, enemy: enemy, ladderStage: stage),
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: Container(
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: current ? 0.35 : 0.18),
                AppColors.surface,
              ],
            ),
            border: Border.all(color: current ? AppColors.gold : accent.withValues(alpha: 0.3), width: current ? 2 : 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                child: locked
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.mode(Color(0xFF0E0B1C), BlendMode.srcATop),
                        child: MonsterView(monster: enemy, size: 86, animate: false, shadow: false),
                      )
                    : MonsterView(monster: enemy, size: 86, animate: false, shadow: false, facingLeft: true),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Stage ${stage + 1}',
                          style: AppText.small.copyWith(color: AppColors.textDim, fontWeight: FontWeight.w900),
                        ),
                        if (boss) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              'BOSS',
                              style: AppText.small.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(locked ? '???' : enemy.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.h2),
                    Text(locked ? 'Locked' : 'Lv ${enemy.level} • ${enemy.element.emoji} ${enemy.element.label}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.small),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: cleared
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 30)
                    : current
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                        child: Text('FIGHT', style: AppText.h3.copyWith(color: Colors.white)),
                      )
                    : const Icon(Icons.lock_rounded, color: AppColors.textMute),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreBattleSheet extends StatefulWidget {
  const _PreBattleSheet({required this.enemy, this.ladderStage});
  final Monster enemy;
  final int? ladderStage;

  @override
  State<_PreBattleSheet> createState() => _PreBattleSheetState();
}

class _PreBattleSheetState extends State<_PreBattleSheet> {
  late Monster _pick = GameScope.read(context).selectedMonster!;

  @override
  Widget build(BuildContext context) {
    final store = GameScope.of(context);
    final enemy = widget.enemy;
    final adv = _pick.element.against(enemy.element);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1738),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 10),
            Text(widget.ladderStage != null ? 'Stage ${widget.ladderStage! + 1}' : 'Friend Challenge', style: AppText.h2),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _Side(monster: _pick, label: 'YOU'),
                ),
                Text('VS', style: AppText.display.copyWith(color: AppColors.gold)),
                Expanded(
                  child: _Side(monster: enemy, label: 'ENEMY', facingLeft: true),
                ),
              ],
            ),
            if (adv != 1)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: (adv > 1 ? AppColors.success : AppColors.danger).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  adv > 1 ? 'Type advantage! Your ${_pick.element.specialMove} deals 1.5× damage.' : 'Type disadvantage: your special deals less damage.',
                  style: AppText.small.copyWith(color: adv > 1 ? AppColors.success : AppColors.danger),
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Choose your fighter', style: AppText.label.copyWith(color: AppColors.textDim)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: store.monsters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (c, i) {
                  final m = store.monsters[i];
                  final sel = m.id == _pick.id;
                  return Pressable(
                    onTap: () => setState(() => _pick = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: m.element.color.withValues(alpha: sel ? 0.3 : 0.1),
                        border: Border.all(color: sel ? AppColors.gold : AppColors.stroke, width: sel ? 2 : 1),
                      ),
                      child: Column(
                        children: [
                          Expanded(child: MonsterView(monster: m, size: 66, animate: false, shadow: false)),
                          Text('Lv ${m.level}', style: AppText.small.copyWith(color: AppColors.text)),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            GameButton(
              label: 'FIGHT',
              icon: Icons.sports_mma_rounded,
              expand: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                  Text('1', style: AppText.h3.copyWith(color: Colors.white)),
                ],
              ),
              onTap: () => Navigator.of(context).pop(_pick),
            ),
          ],
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.monster, required this.label, this.facingLeft = false});
  final Monster monster;
  final String label;
  final bool facingLeft;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: AppText.small.copyWith(letterSpacing: 2, fontWeight: FontWeight.w900)),
      MonsterView(monster: monster, size: 120, facingLeft: facingLeft),
      Text(monster.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.h3),
      Text('Lv ${monster.level} • ${monster.element.emoji} • PWR ${monster.power}', style: AppText.small),
    ],
  );
}
