import 'dart:math';

import 'package:flutter/material.dart';

import '../app.dart';
import '../game/monster_factory.dart';
import '../models/element.dart';
import '../services/game_store.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/monster_view.dart';
import '../widgets/ui.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    Sfx.music(MusicTrack.menu);
  }

  static final _pages = <_PageData>[
    _PageData(
      title: 'Your Voice.\nYour Beast.',
      text: 'Roar into your phone and a one-of-a-kind monster is born from the sound of YOUR voice.',
      tint: BeastElement.inferno.color,
      art: (_) => const _TrioArt(),
    ),
    _PageData(
      title: 'Every Roar\nIs Unique',
      text: 'Deep voices build tanks. High voices build speedsters. Loud, raspy roars hit hardest. No two beasts are the same.',
      tint: BeastElement.tide.color,
      art: (_) => const _VoiceArt(),
    ),
    _PageData(
      title: 'Battle &\nEvolve',
      text: 'Climb 60 arena stages, battle friends live, level up, and evolve your beast into its ultimate form.',
      tint: BeastElement.shadow.color,
      art: (_) => const _VersusArt(),
    ),
    _PageData(
      title: 'Challenge\nYour Friends',
      text: 'Share your beast as a QR card. Friends scan it and fight it. Works fully offline.',
      tint: BeastElement.storm.color,
      art: (_) => const _ShareArt(),
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _pc.nextPage(duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  void _finish() {
    GameScope.read(context).completeOnboarding();
    Navigator.of(context).pushReplacement(gameRoute(const HomeShell(initialTab: 1)));
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      body: Stack(
        children: [
          // Only the backdrop cross-fades; the PageView stays a single instance.
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: GameBackground(key: ValueKey(_page), tint: _pages[_page].tint, child: const SizedBox.expand()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: last ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: last ? null : _finish,
                      child: Text('Skip', style: AppText.label.copyWith(color: AppColors.textDim)),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (c, i) {
                      final p = _pages[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            Expanded(child: Center(child: p.art(c))),
                            Text(p.title, textAlign: TextAlign.center, style: AppText.display.copyWith(fontSize: 38)),
                            const SizedBox(height: 14),
                            Text(p.text, textAlign: TextAlign.center, style: AppText.body.copyWith(fontSize: 16)),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white24, borderRadius: BorderRadius.circular(8)),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                  child: GameButton(label: last ? "Let's Roar!" : 'Next', icon: last ? Icons.mic_rounded : Icons.arrow_forward_rounded, expand: true, onTap: _next),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  const _PageData({required this.title, required this.text, required this.tint, required this.art});
  final String title;
  final String text;
  final Color tint;
  final WidgetBuilder art;
}

class _TrioArt extends StatelessWidget {
  const _TrioArt();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c, box) {
        final s = min(box.maxWidth, box.maxHeight);
        return SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                bottom: s * 0.12,
                child: MonsterView(monster: MonsterFactory.showcase(BeastElement.frost, 77, stage: 1), size: s * 0.45),
              ),
              Positioned(
                right: 0,
                bottom: s * 0.12,
                child: MonsterView(monster: MonsterFactory.showcase(BeastElement.shadow, 4242, stage: 1), size: s * 0.45, facingLeft: true),
              ),
              Positioned(
                bottom: s * 0.02,
                child: MonsterView(monster: MonsterFactory.showcase(BeastElement.inferno, 31337, stage: 3), size: s * 0.72),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VoiceArt extends StatelessWidget {
  const _VoiceArt();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c, box) {
        final s = min(box.maxWidth, box.maxHeight);
        return SizedBox(
          width: s,
          height: s,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: s * 0.2, child: const _FakeWave()),
              const Icon(Icons.keyboard_double_arrow_down_rounded, color: AppColors.textDim, size: 30),
              MonsterView(monster: MonsterFactory.showcase(BeastElement.tide, 2024, stage: 2), size: s * 0.62),
            ],
          ),
        );
      },
    );
  }
}

class _FakeWave extends StatefulWidget {
  const _FakeWave();
  @override
  State<_FakeWave> createState() => _FakeWaveState();
}

class _FakeWaveState extends State<_FakeWave> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(23, (i) {
        final v = (sin(i * 0.7 + _c.value * 2 * pi) * 0.5 + 0.5) * (1 - (i - 11).abs() / 13);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 5,
          height: 8 + v * 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [AppColors.primary, AppColors.gold]),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    ),
  );
}

class _VersusArt extends StatelessWidget {
  const _VersusArt();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c, box) {
        final s = min(box.maxWidth, box.maxHeight);
        return SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -s * 0.04,
                bottom: s * 0.15,
                child: MonsterView(monster: MonsterFactory.showcase(BeastElement.storm, 555, stage: 2), size: s * 0.56),
              ),
              Positioned(
                right: -s * 0.04,
                top: s * 0.08,
                child: MonsterView(monster: MonsterFactory.showcase(BeastElement.terra, 8080, stage: 3), size: s * 0.56, facingLeft: true),
              ),
              Text(
                'VS',
                style: AppText.display.copyWith(
                  fontSize: 54,
                  color: AppColors.gold,
                  shadows: const [Shadow(color: AppColors.primaryDeep, blurRadius: 18)],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShareArt extends StatelessWidget {
  const _ShareArt();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c, box) {
        final s = min(box.maxWidth, box.maxHeight) * 0.9;
        final m = MonsterFactory.showcase(BeastElement.shadow, 99, stage: 2);
        return Transform.rotate(
          angle: -0.06,
          child: Container(
            width: s * 0.72,
            height: s * 0.92,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [m.element.color.withValues(alpha: 0.55), AppColors.bg1]),
              border: Border.all(color: AppColors.gold, width: 2),
              boxShadow: [BoxShadow(color: m.element.color.withValues(alpha: 0.4), blurRadius: 30)],
            ),
            child: Column(
              children: [
                Expanded(
                  child: MonsterView(monster: m, size: s * 0.6),
                ),
                Text(m.name, style: AppText.h1),
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.qr_code_2_rounded, size: 48, color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
