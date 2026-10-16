import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../data/content.dart';
import '../services/narrator.dart';
import '../widgets/common.dart';
import 'paywall_screen.dart';

/// A narrated story. The device voice reads it aloud while the transcript
/// lights up as it goes.
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.place, required this.story});
  final Place place;
  final Story story;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final _narrator = Narrator();
  late Story _story = widget.story;

  static const _speeds = [(0.35, '0.8×'), (0.45, '1×'), (0.55, '1.2×')];

  @override
  void initState() {
    super.initState();
    _narrator.load(_story.text);
    _narrator.addListener(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _narrator.rate = AppScope.read(context).speechRate;
  }

  void _onTick() => setState(() {});

  @override
  void dispose() {
    _narrator.removeListener(_onTick);
    _narrator.dispose();
    super.dispose();
  }

  Future<void> _switchTo(Story s) async {
    if (s.premium && !AppScope.read(context).premium) {
      await Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen()));
      return;
    }
    await _narrator.stop();
    setState(() => _story = s);
    _narrator.load(s.text);
    await _narrator.play();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final state = AppScope.of(context);
    final pad = MediaQuery.paddingOf(context);
    final h = MediaQuery.sizeOf(context).height;
    final words = _story.text.split(' ').length;
    final total = Duration(seconds: (words / (150 * (_narrator.rate / 0.45)) * 60).round());
    final elapsed = Duration(seconds: (total.inSeconds * _narrator.progress).round());
    final spoken = (_story.text.length * _narrator.progress).round();
    final others = place.stories.where((s) => s.id != _story.id).toList();

    return Scaffold(
      backgroundColor: GC.ground,
      body: Stack(
        children: [
          SizedBox(
            height: h * 0.42,
            width: double.infinity,
            child: Stack(fit: StackFit.expand, children: [ArchivePhoto(place.image), const BottomFade(stops: [0.4, 1.0])]),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(22, h * 0.30, 22, pad.bottom + 40),
            children: [
              Wrap(spacing: 8, children: [
                Pill(label: '${_story.year}'),
                const Pill(label: 'Narrated story', background: GC.surface2, foreground: GC.textSoft),
              ]),
              const SizedBox(height: 14),
              Text(_story.title, style: GC.display(32, height: 1.1)),
              const SizedBox(height: 8),
              Text('${place.name} · ${place.city}', style: GC.body(14, color: GC.muted)),
              const SizedBox(height: 22),

              // Player.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GC.surface,
                  borderRadius: BorderRadius.circular(GC.radiusL),
                  border: Border.all(color: GC.line),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Semantics(
                          button: true,
                          label: _narrator.isPlaying ? 'Pause' : 'Play',
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _narrator.toggle();
                            },
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: const BoxDecoration(color: GC.amber, shape: BoxShape.circle),
                              child: Icon(_narrator.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: GC.onAmber, size: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _Waveform(
                            progress: _narrator.progress,
                            seed: _story.id.hashCode,
                            onSeek: (f) => _narrator.seekFraction(f),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(formatDuration(elapsed), style: GC.body(12.5, color: GC.amber, weight: FontWeight.w700)),
                        const Spacer(),
                        for (final s in _speeds)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ChoiceChipX(
                              label: s.$2,
                              selected: (state.speechRate - s.$1).abs() < 0.01,
                              solid: true,
                              onTap: () async {
                                await state.setSpeechRate(s.$1);
                                _narrator.rate = s.$1;
                                if (_narrator.isPlaying) {
                                  await _narrator.pause();
                                  await _narrator.play();
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        const Spacer(),
                        Text(formatDuration(total), style: GC.body(12.5, color: GC.faint, weight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const SectionLabel('Transcript'),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: _story.text.substring(0, spoken), style: const TextStyle(color: GC.text)),
                  TextSpan(text: _story.text.substring(spoken), style: const TextStyle(color: GC.faint)),
                ]),
                style: GC.display(19, height: 1.6),
              ),
              if (others.isNotEmpty) ...[
                const SizedBox(height: 32),
                const SectionLabel('More from this spot'),
                const SizedBox(height: 12),
                for (final s in others)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: GC.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GC.radiusM), side: const BorderSide(color: GC.line)),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        onTap: () => _switchTo(s),
                        leading: Icon(s.premium && !state.premium ? Icons.lock_rounded : Icons.play_circle_outline_rounded,
                            color: GC.amber),
                        title: Text(s.title, style: GC.display(16, height: 1.2)),
                        subtitle: Text('${s.year} · ${s.minutes} min', style: GC.body(12.5, color: GC.muted, height: 1.3)),
                        trailing: s.premium && !state.premium ? const PremiumBadge(compact: true) : null,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 18),
              Text('Narration is read by your phone’s built-in voice and works offline.',
                  style: GC.body(12, color: GC.faint)),
            ],
          ),
          Positioned(
            top: pad.top + 10,
            left: 16,
            child: GlassIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
          ),
        ],
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.progress, required this.seed, required this.onSeek});
  final double progress;
  final int seed;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      void seek(Offset p) => onSeek((p.dx / c.maxWidth).clamp(0.0, 1.0));
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => seek(d.localPosition),
        onHorizontalDragEnd: (_) {},
        onHorizontalDragUpdate: (d) => seek(d.localPosition),
        child: SizedBox(
          height: 48,
          child: CustomPaint(painter: _WavePainter(progress, seed), size: Size(c.maxWidth, 48)),
        ),
      );
    });
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.progress, this.seed);
  final double progress;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const bar = 3.0;
    const gap = 2.5;
    final n = (size.width / (bar + gap)).floor();
    final rnd = math.Random(seed);
    final on = Paint()..color = GC.amber;
    final off = Paint()..color = const Color(0xFF4A4336);
    for (var i = 0; i < n; i++) {
      final env = 0.35 + 0.65 * math.sin(math.pi * (i / n)).abs();
      final hgt = (6 + rnd.nextDouble() * (size.height - 6)) * env;
      final x = i * (bar + gap);
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, (size.height - hgt) / 2, bar, hgt), const Radius.circular(2));
      canvas.drawRRect(r, (i / n) <= progress ? on : off);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress || old.seed != seed;
}
