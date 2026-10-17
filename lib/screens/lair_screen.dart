import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../game/monster_factory.dart';
import '../models/element.dart';
import '../models/monster.dart';
import '../services/ads/ad_service.dart';
import '../services/game_store.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';
import '../widgets/monster_view.dart';
import '../widgets/ui.dart';
import 'home_shell.dart';
import 'monster_detail_screen.dart';

class LairScreen extends StatelessWidget {
  const LairScreen({super.key});

  static const slotPrice = 60;

  @override
  Widget build(BuildContext context) {
    final store = GameScope.of(context);
    final champ = store.selectedMonster;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TopHud(title: 'My Lair'),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverList.list(
                    children: [
                      const _DailyChestBanner(),
                      const SizedBox(height: 12),
                      if (champ == null) const _EmptyLair() else _ChampionPanel(monster: champ),
                      SectionTitle('Beasts ${store.monsters.length}/${store.slots}'),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.82),
                    delegate: SliverChildBuilderDelegate((c, i) {
                      if (i < store.monsters.length) return _MonsterTile(monster: store.monsters[i], selected: store.monsters[i].id == champ?.id);
                      if (i < store.slots) return const _EmptySlotTile();
                      return const _LockedSlotTile();
                    }, childCount: store.slots + 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChestBanner extends StatefulWidget {
  const _DailyChestBanner();
  @override
  State<_DailyChestBanner> createState() => _DailyChestBannerState();
}

class _DailyChestBannerState extends State<_DailyChestBanner> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !GameScope.read(context).dailyReady) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> _open() async {
    final store = GameScope.read(context);
    Sfx.play(Fx.coin);
    final doubled = await AppDialog.show<bool>(
      context: context,
      title: 'Daily Chest!',
      message: 'Your daily loot is ready.',
      accent: AppColors.gold,
      hero: const IconBadge(icon: Icons.card_giftcard_rounded, color: AppColors.gold, size: 84),
      body: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [_Loot(Currency.coins, '+100'), SizedBox(width: 18), _Loot(Currency.gems, '+5')]),
      primaryLabel: 'Double it!',
      primaryIcon: Icons.play_circle_fill_rounded,
      primaryColor: AppColors.success,
      onPrimary: () async {
        final nav = Navigator.of(context);
        final earned = await AdService.instance.showRewarded(rewardLabel: 'double loot');
        if (earned) nav.pop(true);
      },
      secondaryLabel: 'Just collect',
      onSecondary: () => Navigator.of(context).pop(false),
      dismissible: false,
    );
    store.claimDaily(doubled: doubled == true);
    Sfx.play(Fx.coin);
    AppToast.show(doubled == true ? '+200 coins and +10 gems collected!' : '+100 coins and +5 gems collected!', type: ToastType.reward, title: 'Daily chest');
  }

  @override
  Widget build(BuildContext context) {
    final store = GameScope.of(context);
    final ready = store.dailyReady;
    return Pressable(
      onTap: ready ? _open : null,
      child: Panel(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        borderColor: ready ? AppColors.gold.withValues(alpha: 0.6) : null,
        gradient: ready ? LinearGradient(colors: [AppColors.gold.withValues(alpha: 0.22), AppColors.surface]) : null,
        child: Row(
          children: [
            Icon(Icons.card_giftcard_rounded, color: ready ? AppColors.gold : AppColors.textMute, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ready ? 'Daily Chest ready!' : 'Daily Chest', style: AppText.h3),
                  Text(ready ? 'Tap to collect free coins & gems' : 'Next chest in ${formatDuration(store.dailyIn)}', style: AppText.small),
                ],
              ),
            ),
            if (ready) const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}

class _Loot extends StatelessWidget {
  const _Loot(this.type, this.text);
  final Currency type;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CurrencyIcon(type, size: 26),
      const SizedBox(width: 6),
      Text(text, style: AppText.h2),
    ],
  );
}

class _EmptyLair extends StatelessWidget {
  const _EmptyLair();
  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Opacity(
            opacity: 0.35,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcATop),
              child: MonsterView(monster: MonsterFactory.showcase(BeastElement.inferno, 31337), size: 150, animate: false),
            ),
          ),
          Text('Your lair is empty', style: AppText.h1),
          const SizedBox(height: 6),
          Text('Give a mighty ROAR to summon your very first beast.', textAlign: TextAlign.center, style: AppText.body),
          const SizedBox(height: 16),
          GameButton(label: 'Summon a Beast', icon: Icons.mic_rounded, onTap: () => HomeShell.switchTab(context, 1)),
        ],
      ),
    );
  }
}

class _ChampionPanel extends StatelessWidget {
  const _ChampionPanel({required this.monster});
  final Monster monster;

  @override
  Widget build(BuildContext context) {
    final e = monster.element;
    return Panel(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      borderColor: e.color.withValues(alpha: 0.5),
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [e.color.withValues(alpha: 0.28), AppColors.surface]),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.gold, size: 15),
                    const SizedBox(width: 3),
                    Text(
                      'CHAMPION',
                      style: AppText.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElementBadge(e),
            ],
          ),
          Pressable(
            sound: false,
            onTap: () => Sfx.roar(monster.roarPath),
            child: MonsterView(monster: monster, size: 210),
          ),
          Text(monster.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.display.copyWith(fontSize: 30)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RarityTag(monster.rarity),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Lv ${monster.level}  •  Power ${monster.power}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(color: AppColors.textDim),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GameButton(
                  label: 'Details',
                  icon: Icons.info_rounded,
                  color: AppColors.surfaceHi,
                  small: true,
                  onTap: () => Navigator.of(context).push(gameRoute(MonsterDetailScreen(monster: monster))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GameButton(label: 'Battle', icon: Icons.sports_mma_rounded, small: true, onTap: () => HomeShell.switchTab(context, 2)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonsterTile extends StatelessWidget {
  const _MonsterTile({required this.monster, required this.selected});
  final Monster monster;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final e = monster.element;
    return Pressable(
      onTap: () => Navigator.of(context).push(gameRoute(MonsterDetailScreen(monster: monster))),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [e.color.withValues(alpha: 0.30), AppColors.surface]),
          border: Border.all(color: selected ? AppColors.gold : e.color.withValues(alpha: 0.35), width: selected ? 2 : 1),
        ),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          children: [
            Row(
              children: [
                ElementBadge(e, compact: true),
                const Spacer(),
                if (selected) const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                Text('Lv ${monster.level}', style: AppText.number.copyWith(fontSize: 14)),
              ],
            ),
            Expanded(
              child: FittedBox(child: MonsterView(monster: monster, size: 150, animate: false)),
            ),
            Text(monster.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.h3),
            const SizedBox(height: 3),
            Container(
              height: 3,
              width: 46,
              decoration: BoxDecoration(color: monster.rarity.color, borderRadius: BorderRadius.circular(2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlotTile extends StatelessWidget {
  const _EmptySlotTile();
  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => HomeShell.switchTab(context, 1),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface.withValues(alpha: 0.5),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const IconBadge(icon: Icons.mic_rounded, color: AppColors.primary, size: 58),
          const SizedBox(height: 10),
          Text('Summon', style: AppText.h3),
          Text('Empty slot', style: AppText.small),
        ],
      ),
    ),
  );
}

class _LockedSlotTile extends StatelessWidget {
  const _LockedSlotTile();

  Future<void> _unlock(BuildContext context) async {
    final store = GameScope.read(context);
    final ok = await AppDialog.confirm(
      context: context,
      title: 'Unlock a slot?',
      message: 'Keep one more beast in your lair for ${LairScreen.slotPrice} gems.',
      confirmLabel: 'Unlock • ${LairScreen.slotPrice} 💎',
      icon: Icons.lock_open_rounded,
    );
    if (!ok) return;
    if (store.spendGems(LairScreen.slotPrice)) {
      store.slots++;
      store.touch();
      Sfx.play(Fx.levelup);
      AppToast.show('New monster slot unlocked!', type: ToastType.success);
    } else {
      AppToast.show(
        'You need ${LairScreen.slotPrice - store.gems} more gems.',
        type: ToastType.error,
        title: 'Not enough gems',
        actionLabel: 'Shop',
        onAction: () {
          if (context.mounted) HomeShell.switchTab(context, 3);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => _unlock(context),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withValues(alpha: 0.25),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, color: AppColors.textMute, size: 40),
          const SizedBox(height: 10),
          Text('Locked slot', style: AppText.h3.copyWith(color: AppColors.textDim)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CurrencyIcon(Currency.gems, size: 16),
              const SizedBox(width: 4),
              Text('${LairScreen.slotPrice}', style: AppText.number),
            ],
          ),
        ],
      ),
    ),
  );
}
