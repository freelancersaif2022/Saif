import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../services/game_store.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'arena_screen.dart';
import 'lair_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'summon_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTab = 0});
  final int initialTab;

  static void switchTab(BuildContext context, int index) => context.findAncestorStateOfType<_HomeShellState>()?._go(index);

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _tab = widget.initialTab;

  static const _items = [(Icons.catching_pokemon_rounded, 'Lair'), (Icons.mic_rounded, 'Summon'), (Icons.sports_mma_rounded, 'Arena'), (Icons.storefront_rounded, 'Shop')];

  void _go(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(0);
      },
      child: Scaffold(
        extendBody: true,
        body: GameBackground(
          child: IndexedStack(
            index: _tab,
            children: [
              const LairScreen(),
              SummonScreen(active: _tab == 1),
              const ArenaScreen(),
              const ShopScreen(),
            ],
          ),
        ),
        bottomNavigationBar: _NavBar(index: _tab, items: _items, onTap: _go),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.items, required this.onTap});
  final int index;
  final List<(IconData, String)> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(10, 8, 10, 8 + bottom),
      decoration: BoxDecoration(
        color: const Color(0xF2120E25),
        border: const Border(top: BorderSide(color: AppColors.stroke)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == index;
          final (icon, label) = items[i];
          final isSummon = i == 1;
          return Expanded(
            child: Pressable(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 7),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: active
                      ? LinearGradient(colors: [(isSummon ? AppColors.primary : AppColors.cyan).withValues(alpha: 0.28), (isSummon ? AppColors.primary : AppColors.cyan).withValues(alpha: 0.08)])
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: active ? 1.15 : 1,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(icon, color: active ? (isSummon ? AppColors.primary : AppColors.cyan) : AppColors.textMute, size: 26),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: AppText.small.copyWith(color: active ? AppColors.text : AppColors.textMute, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Top currency bar shared by all tabs.
class TopHud extends StatefulWidget {
  const TopHud({super.key, required this.title});
  final String title;

  @override
  State<TopHud> createState() => _TopHudState();
}

class _TopHudState extends State<TopHud> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Keeps the energy timer fresh.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = GameScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          // Scales down as one unit on narrow phones instead of overflowing.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title, style: AppText.h1),
                  const SizedBox(width: 12),
                  CurrencyChip(type: Currency.energy, value: '${store.energy}/${GameStore.maxEnergy}'),
                  const SizedBox(width: 6),
                  CurrencyChip(type: Currency.coins, value: _compact(store.coins)),
                  const SizedBox(width: 6),
                  CurrencyChip(type: Currency.gems, value: _compact(store.gems), onTap: () => HomeShell.switchTab(context, 3)),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(gameRoute(const SettingsScreen())),
            icon: const Icon(Icons.settings_rounded, color: AppColors.textDim),
          ),
        ],
      ),
    );
  }

  static String _compact(int v) => v >= 100000 ? '${(v / 1000).toStringAsFixed(0)}K' : (v >= 10000 ? '${(v / 1000).toStringAsFixed(1)}K' : '$v');
}
