import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../widgets/common.dart';

class _Slide {
  const _Slide(this.image, this.badge, this.title, this.accent, this.body, this.alignment);
  final String image;
  final String badge;
  final String title;
  final String accent;
  final String body;
  final Alignment alignment;
}

const _slides = [
  _Slide(
    'assets/photos/moulin_rouge_1914.jpg',
    'Paris · c. 1914',
    'Every street',
    'remembers.',
    'Point your camera at a corner and see it 5, 10 or 14 years ago, in real photographs of that exact spot.',
    Alignment(0, -0.35),
  ),
  _Slide(
    'assets/photos/detroit_1915.jpg',
    'Detroit · c. 1915',
    'Your street,',
    'years ago.',
    'Ghost City finds street photos, archive pictures and satellite images of wherever you stand, from 5 to 20 years back.',
    Alignment(-0.1, 0),
  ),
  _Slide(
    'assets/photos/new_york_1931.jpg',
    'New York · 1931',
    'Leave your voice',
    'for the future.',
    'Record what you remember about a place. Your memories stay on your phone, pinned to the spot where they happened.',
    Alignment(0.2, 0),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _page = _controller.page ?? 0));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final s in _slides) {
      precacheImage(AssetImage(s.image), context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final i = _page.round();
    if (i < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
    } else {
      AppScope.read(context).finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _page.round().clamp(0, _slides.length - 1);
    final last = index == _slides.length - 1;
    final pad = MediaQuery.paddingOf(context);
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: GC.ground,
      body: Stack(
        children: [
          // Photos cross-fade and drift slightly as you swipe.
          for (var i = 0; i < _slides.length; i++)
            Positioned.fill(
              child: Opacity(
                opacity: (1 - (_page - i).abs()).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 1.08 - 0.04 * (1 - (_page - i).abs()).clamp(0.0, 1.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: h * 0.72,
                      width: double.infinity,
                      child: ArchivePhoto(_slides[i].image, alignment: _slides[i].alignment),
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      GC.ground.withValues(alpha: 0.2),
                      GC.ground.withValues(alpha: 0.92),
                      GC.ground,
                    ],
                    stops: const [0.0, 0.2, 0.42, 0.62, 0.74],
                  ),
                ),
              ),
            ),
          ),
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            itemBuilder: (context, i) => const SizedBox.expand(),
          ),
          Positioned(
            top: pad.top + 12,
            left: 20,
            right: 20,
            child: Row(
              children: [
                const _Logo(),
                const Spacer(),
                AnimatedOpacity(
                  opacity: last ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: last ? null : () => AppScope.read(context).finishOnboarding(),
                    style: TextButton.styleFrom(
                      foregroundColor: GC.text,
                      backgroundColor: const Color(0x730F0E0C),
                      shape: const StadiumBorder(side: BorderSide(color: Color(0x2EF3EBDD))),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      textStyle: GC.body(14, weight: FontWeight.w600, height: 1),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 26,
            right: 26,
            bottom: pad.bottom + 28,
            child: IgnorePointer(
              ignoring: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _SlideText(key: ValueKey(index), slide: _slides[index]),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == index ? 24 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == index ? GC.amber : const Color(0xFF5A5245),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: last ? 'Start exploring' : 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    iconAfter: true,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideText extends StatelessWidget {
  const _SlideText({super.key, required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
          decoration: BoxDecoration(
            color: const Color(0x990F0E0C),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: const Color(0x66E9B44C)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: GC.amber, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(slide.badge.toUpperCase(), style: GC.label(color: GC.amberLight, size: 11.5)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(slide.title, style: GC.display(40)),
        Text(slide.accent, style: GC.display(40, color: GC.amber, style: FontStyle.italic)),
        const SizedBox(height: 14),
        Text(slide.body, style: GC.body(16, color: const Color(0xFFC9BEA9), height: 1.55)),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: GC.amber, width: 1.6)),
          child: const Icon(Icons.history_rounded, size: 18, color: GC.amber),
        ),
        const SizedBox(width: 9),
        Text('Ghost City', style: GC.display(19).copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
