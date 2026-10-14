import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio.dart';
import '../core/save_data.dart';
import '../game/level_data.dart';
import 'game_screen.dart';
import 'scene_painters.dart';
import 'theme.dart';
import 'widgets.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> with SingleTickerProviderStateMixin, SceneClock {
  late final BackdropPainter _painter = BackdropPainter(clock);
  int? _picked;
  final Map<int, int> _shakes = {};
  late int _page = SaveData.instance.selectedLevel > 10 ? 1 : 0;
  late final PageController _pages = PageController(initialPage: _page);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int page) {
    GameAudio.instance.play(Sfx.uiClick, volume: 0.7);
    _pages.animateToPage(page, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
  }

  void _select(int level) {
    final save = SaveData.instance;
    if (!save.isUnlocked(level)) {
      GameAudio.instance.play(Sfx.uiLocked, volume: 0.8);
      setState(() => _shakes[level] = (_shakes[level] ?? 0) + 1);
      return;
    }
    if (_picked != null) return;
    GameAudio.instance.play(Sfx.uiLevelSelect, volume: 0.9);
    save.selectLevel(level);
    setState(() => _picked = level);
    Future.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(FadeRoute(page: GameScreen(level: level), ms: 700));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final gridW = math.min(w * 0.86, h * 1.9);
        final cardW = (gridW - 4 * 14) / 5 - 1;
        final cardH = math.min(cardW * 1.05, (h * 0.62 - 18) / 2);
        return Stack(
          children: [
            Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _painter))),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: h * 0.03),
                  Row(
                    children: [
                      SizedBox(width: w * 0.03),
                      RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        size: math.min(48, h * 0.09),
                        onTap: () {
                          GameAudio.instance.play(Sfx.uiClick, volume: 0.8);
                          Navigator.of(context).maybePop();
                        },
                      ),
                      const Spacer(),
                      Text('SELECT LEVEL', style: UiText.title(math.min(h * 0.07, w * 0.04), glow: 0.6)),
                      const Spacer(),
                      SizedBox(width: math.min(48, h * 0.09) + w * 0.03),
                    ],
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      onPageChanged: (i) => setState(() => _page = i),
                      children: [
                        for (var page = 0; page < 2; page++)
                          Center(
                            child: SizedBox(
                              width: gridW,
                              child: Wrap(
                                spacing: 14,
                                runSpacing: 18,
                                children: [
                                  for (var i = page * 10 + 1; i <= page * 10 + 10; i++)
                                    _LevelCard(
                                      key: ValueKey('card$i'),
                                      level: i,
                                      width: cardW,
                                      height: cardH,
                                      delay: (i - page * 10) * 0.06,
                                      shake: _shakes[i] ?? 0,
                                      picked: _picked == i,
                                      dimmed: _picked != null && _picked != i,
                                      onTap: () => _select(i),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: h * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PageArrow(icon: Icons.chevron_left_rounded, enabled: _page > 0, onTap: () => _go(0)),
                        SizedBox(width: w * 0.02),
                        for (var i = 0; i < 2; i++)
                          GestureDetector(
                            onTap: () => _go(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: math.max(2, h * 0.006)),
                              decoration: BoxDecoration(
                                color: _page == i ? UiColors.accent.withAlpha(50) : const Color(0x66000000),
                                border: Border.all(color: (_page == i ? UiColors.accent : UiColors.locked).withAlpha(180)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(i == 0 ? 'CHAPTER I   1 - 10' : 'CHAPTER II   11 - 20', style: UiText.body(math.max(10, h * 0.028), color: _page == i ? UiColors.text : UiColors.dim)),
                            ),
                          ),
                        SizedBox(width: w * 0.02),
                        _PageArrow(icon: Icons.chevron_right_rounded, enabled: _page < 1, onTap: () => _go(1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.3,
      child: RoundIconButton(icon: icon, size: 36, onTap: enabled ? onTap : () {}),
    );
  }
}

class _LevelCard extends StatefulWidget {
  const _LevelCard({
    super.key,
    required this.level,
    required this.width,
    required this.height,
    required this.delay,
    required this.shake,
    required this.picked,
    required this.dimmed,
    required this.onTap,
  });

  final int level;
  final double width;
  final double height;
  final double delay;
  final int shake;
  final bool picked;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..forward();
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(_LevelCard old) {
    super.didUpdateWidget(old);
    if (widget.shake != old.shake) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final save = SaveData.instance;
    final unlocked = save.isUnlocked(widget.level);
    final done = save.isCompleted(widget.level);
    final cfg = levelConfig(widget.level);
    final boss = cfg.isBoss;
    final accent = !unlocked ? UiColors.locked : (boss ? UiColors.red : UiColors.accent);
    final selected = save.selectedLevel == widget.level;
    final h = widget.height;

    return GestureDetector(
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: AnimatedBuilder(
        animation: Listenable.merge([_enter, _pulse, _shake]),
        builder: (context, child) {
          final k = Curves.easeOutBack.transform(((_enter.value - widget.delay) / 0.55).clamp(0.0, 1.0));
          final sx = math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value);
          final glow = unlocked ? (0.5 + 0.5 * math.sin(_pulse.value * math.pi * 2)) : 0.0;
          final scale = widget.picked ? 1.12 : (widget.dimmed ? 0.94 : 1.0);
          return Opacity(
            opacity: (k.clamp(0.0, 1.0) * (widget.dimmed ? 0.4 : 1.0)).toDouble(),
            child: Transform.translate(
              offset: Offset(sx, 40 * (1 - k)),
              child: AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Container(
                  width: widget.width,
                  height: h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent.withAlpha(unlocked ? 46 : 18),
                        const Color(0xF0080A10),
                        const Color(0xFA040508),
                      ],
                    ),
                    border: Border.all(
                      color: accent.withAlpha(unlocked ? (110 + 120 * glow * (selected ? 1 : 0.5)).round() : 70),
                      width: selected ? 2.2 : 1.3,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      if (unlocked && selected) BoxShadow(color: accent.withAlpha(60), blurRadius: 16),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(h * 0.07),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('LEVEL', style: UiText.body(h * 0.1, color: unlocked ? UiColors.dim : UiColors.locked)),
                        const Spacer(),
                        if (boss)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: h * 0.04, vertical: h * 0.01),
                            decoration: BoxDecoration(
                              border: Border.all(color: accent.withAlpha(180)),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text('BOSS', style: UiText.body(h * 0.075, color: accent)),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.level.toString().padLeft(2, '0'),
                            style: UiText.title(h * 0.34, color: unlocked ? UiColors.text : UiColors.locked, glow: unlocked ? (boss ? 0.9 : 0.4) : 0),
                          ),
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        unlocked ? cfg.name : 'LOCKED',
                        style: UiText.body(h * 0.085, color: unlocked ? accent : UiColors.locked),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!unlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x99000000),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(Icons.lock_rounded, size: h * 0.3, color: const Color(0xFF8A94A6), shadows: const [Shadow(color: Colors.black, blurRadius: 8)]),
                  ),
                ),
              ),
            if (done)
              Positioned(
                right: h * 0.05,
                bottom: h * 0.2,
                child: Icon(Icons.check_circle_rounded, size: h * 0.14, color: UiColors.gold),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
