import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../audio/roar_recorder.dart';
import '../audio/voice_analyzer.dart';
import '../game/monster_factory.dart';
import '../models/element.dart';
import '../models/monster.dart';
import '../services/ads/ad_service.dart';
import '../services/game_store.dart';
import '../services/roar_storage.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';
import '../widgets/monster_view.dart';
import '../widgets/ui.dart';
import 'home_shell.dart';
import 'lair_screen.dart';

enum _Phase { idle, recording, analyzing, reveal }

class SummonScreen extends StatefulWidget {
  const SummonScreen({super.key, required this.active});
  final bool active;

  @override
  State<SummonScreen> createState() => _SummonScreenState();
}

class _SummonScreenState extends State<SummonScreen> with TickerProviderStateMixin {
  _Phase _phase = _Phase.idle;
  RoarRecorder? _recorder;
  StreamSubscription<double>? _levelSub;
  final List<double> _levels = List.filled(28, 0);
  late final AnimationController _progress = AnimationController(vsync: this, duration: RoarRecorder.length);
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  late final AnimationController _revealC = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  Monster? _monster;
  Uint8List? _wav;
  int _reforgesLeft = 3;
  bool _busy = false;

  @override
  void didUpdateWidget(covariant SummonScreen old) {
    super.didUpdateWidget(old);
    if (!widget.active && _phase == _Phase.recording) _cancelRecording();
  }

  @override
  void dispose() {
    _levelSub?.cancel();
    _recorder?.dispose();
    _progress.dispose();
    _pulse.dispose();
    _revealC.dispose();
    super.dispose();
  }

  Future<void> _startRoar() async {
    if (_busy) return;
    _busy = true;
    try {
      if (!await RoarRecorder.ensureAccess(context)) return;
      _recorder ??= RoarRecorder();
      await _levelSub?.cancel();
      _levelSub = _recorder!.levels.listen((l) {
        if (!mounted) return;
        setState(() {
          _levels.removeAt(0);
          _levels.add(l);
        });
      });
      await _recorder!.start();
      Sfx.haptic();
      setState(() => _phase = _Phase.recording);
      await _progress.forward(from: 0);
      if (_phase == _Phase.recording && mounted) await _finishRecording();
    } catch (e) {
      debugPrint('Recording failed: $e');
      AppToast.show('Could not access the microphone. Close other apps using it and try again.', type: ToastType.error, title: 'Mic busy');
      if (mounted) setState(() => _phase = _Phase.idle);
    } finally {
      _busy = false;
    }
  }

  Future<void> _cancelRecording() async {
    _progress.stop();
    await _recorder?.stop();
    if (mounted) setState(() => _phase = _Phase.idle);
  }

  Future<void> _finishRecording() async {
    final pcm = await _recorder!.stop();
    setState(() {
      _phase = _Phase.analyzing;
      _levels.fillRange(0, _levels.length, 0);
    });
    Sfx.play(Fx.summon);
    try {
      final results = await Future.wait([compute(analyzeVoiceIsolate, AnalysisInput(pcm, RoarRecorder.sampleRate)), Future.delayed(const Duration(milliseconds: 1500))]);
      final profile = results[0] as VoiceProfile;
      _wav = pcmToWav(pcm, RoarRecorder.sampleRate);
      _monster = MonsterFactory.fromVoice(profile);
      _reforgesLeft = 3;
      if (!mounted) return;
      setState(() => _phase = _Phase.reveal);
      Sfx.play(Fx.levelup);
      Sfx.haptic(heavy: true);
      _revealC.forward(from: 0);
    } on VoiceAnalysisException catch (e) {
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      AppToast.show(e.message, type: ToastType.error, title: 'Summon failed');
    } catch (e) {
      debugPrint('Analysis failed: $e');
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      AppToast.show('Something went wrong. Please roar again.', type: ToastType.error);
    }
  }

  Future<void> _reforge() async {
    if (_reforgesLeft <= 0) {
      AppToast.show('No reforges left for this roar. Record a new one!', type: ToastType.info);
      return;
    }
    final earned = await AdService.instance.showRewarded(rewardLabel: 'a reforge');
    if (!earned || !mounted || _monster == null) return;
    setState(() {
      MonsterFactory.reforge(_monster!);
      _reforgesLeft--;
    });
    Sfx.play(Fx.summon);
    _revealC.forward(from: 0.35);
    AppToast.show('${_monster!.name} was reforged: new look, new stats!', type: ToastType.success, title: 'Reforged');
  }

  Future<void> _rename() async {
    final m = _monster;
    if (m == null) return;
    final name = await showRenameDialog(context, m.name);
    if (name != null && mounted) setState(() => m.name = name);
  }

  Future<void> _keep() async {
    final store = GameScope.read(context);
    final m = _monster;
    if (m == null) return;
    if (!store.hasFreeSlot) {
      final unlock = await AppDialog.confirm(
        context: context,
        title: 'Lair is full',
        message: 'Unlock a new slot for ${LairScreen.slotPrice} gems, or release a beast from your lair first.',
        confirmLabel: 'Unlock • ${LairScreen.slotPrice} 💎',
        cancelLabel: 'Not now',
        icon: Icons.inventory_2_rounded,
      );
      if (!unlock) return;
      if (!store.spendGems(LairScreen.slotPrice)) {
        AppToast.show(
          'You need ${LairScreen.slotPrice - store.gems} more gems.',
          type: ToastType.error,
          title: 'Not enough gems',
          actionLabel: 'Shop',
          onAction: () {
            if (mounted) HomeShell.switchTab(context, 3);
          },
        );
        return;
      }
      store.slots++;
    }
    if (_wav != null) {
      try {
        m.roarPath = await RoarStorage.save(m.id, _wav!);
      } catch (e) {
        debugPrint('Saving roar failed: $e');
      }
    }
    store.addMonster(m);
    if (store.monsters.length == 1) store.select(m);
    Sfx.play(Fx.coin);
    AppToast.show('${m.name} joined your lair!', type: ToastType.success, title: 'New beast');
    if (!mounted) return;
    setState(() {
      _phase = _Phase.idle;
      _monster = null;
      _wav = null;
    });
    HomeShell.switchTab(context, 0);
  }

  Future<void> _discard() async {
    final ok = await AppDialog.confirm(
      context: context,
      title: 'Release ${_monster?.name}?',
      message: 'This beast will vanish forever. You can always roar again.',
      confirmLabel: 'Release',
      destructive: true,
      icon: Icons.delete_forever_rounded,
    );
    if (ok && mounted) {
      setState(() {
        _phase = _Phase.idle;
        _monster = null;
      });
    }
  }

  void _playRoar() {
    final w = _wav;
    if (w == null) return;
    Sfx.roarBytes(w);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TopHud(title: 'Summon'),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(a), child: c),
              ),
              child: switch (_phase) {
                _Phase.idle || _Phase.recording => _buildRecorder(),
                _Phase.analyzing => _buildAnalyzing(),
                _Phase.reveal => _buildReveal(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorder() {
    final recording = _phase == _Phase.recording;
    return SingleChildScrollView(
      key: const ValueKey('rec'),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(recording ? 'ROAR NOW!' : 'Give it your best roar', style: AppText.display.copyWith(color: recording ? AppColors.primary : AppColors.text)),
          const SizedBox(height: 8),
          Text(recording ? 'Keep going for 3 seconds…' : 'Tap the button and roar, growl or scream for 3 seconds. Your voice decides everything.', textAlign: TextAlign.center, style: AppText.body),
          const SizedBox(height: 26),
          LevelBars(levels: _levels, height: 80),
          const SizedBox(height: 26),
          Pressable(
            onTap: recording ? null : _startRoar,
            scale: 0.92,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulse, _progress]),
              builder: (_, _) {
                final p = _pulse.value;
                return SizedBox(
                  width: 210,
                  height: 210,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var k = 0; k < 2; k++)
                        Opacity(
                          opacity: (1 - ((p + k * 0.5) % 1)) * (recording ? 0.6 : 0.35),
                          child: Container(
                            width: 140 + ((p + k * 0.5) % 1) * 70,
                            height: 140 + ((p + k * 0.5) % 1) * 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 3),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 156,
                        height: 156,
                        child: CircularProgressIndicator(value: recording ? _progress.value : 0, strokeWidth: 7, strokeCap: StrokeCap.round, color: AppColors.gold, backgroundColor: Colors.white10),
                      ),
                      Container(
                        width: 136,
                        height: 136,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(colors: [Color(0xFFFFA14D), AppColors.primary, AppColors.primaryDeep], stops: [0, 0.6, 1]),
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.6), blurRadius: 30 + p * 10)],
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: Icon(recording ? Icons.graphic_eq_rounded : Icons.mic_rounded, size: 64, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Text(recording ? '' : 'TAP TO ROAR', style: AppText.h3.copyWith(color: AppColors.textDim, letterSpacing: 2)),
          const SizedBox(height: 26),
          const _ElementGuide(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 14, color: AppColors.textMute),
              const SizedBox(width: 6),
              Flexible(
                child: Text('Your voice is analysed on this phone and never uploaded.', style: AppText.small.copyWith(color: AppColors.textMute)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      key: const ValueKey('ana'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) => Transform.rotate(
              angle: _pulse.value * 2 * pi,
              child: CustomPaint(size: const Size(180, 180), painter: _PortalPainter(_pulse.value)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Decoding your roar…', style: AppText.h1),
          const SizedBox(height: 8),
          Text('Measuring pitch, power and rasp', style: AppText.body),
        ],
      ),
    );
  }

  Widget _buildReveal() {
    final m = _monster!;
    final v = m.voice!;
    return SingleChildScrollView(
      key: ValueKey('rev${m.seed}'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _revealC,
            builder: (_, child) {
              final t = Curves.elasticOut.transform(_revealC.value.clamp(0.0, 1.0));
              final flash = (1 - _revealC.value * 3).clamp(0.0, 1.0);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.5 + 0.5 * flash,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [m.element.color.withValues(alpha: 0.55), Colors.transparent]),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.3 + 0.7 * t,
                    child: MonsterView(monster: m, size: 250, flash: flash),
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(m.name, style: AppText.display, overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                onPressed: _rename,
                icon: const Icon(Icons.edit_rounded, color: AppColors.textDim, size: 20),
              ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [RarityTag(m.rarity), const SizedBox(width: 8), ElementBadge(m.element)]),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              children: [
                StatBar(label: 'HP', value: m.stats.hp, max: 100, color: AppColors.success, icon: Icons.favorite_rounded),
                const SizedBox(height: 10),
                StatBar(label: 'ATK', value: m.stats.atk, max: 100, color: AppColors.danger, icon: Icons.local_fire_department_rounded),
                const SizedBox(height: 10),
                StatBar(label: 'DEF', value: m.stats.def, max: 100, color: AppColors.cyan, icon: Icons.shield_rounded),
                const SizedBox(height: 10),
                StatBar(label: 'SPD', value: m.stats.spd, max: 100, color: AppColors.gold, icon: Icons.speed_rounded),
                const Divider(height: 26, color: AppColors.stroke),
                Row(
                  children: [
                    _VoiceChip('Pitch', '${v.pitchHz.round()} Hz', v.pitchLabel),
                    _VoiceChip('Power', '${(v.loudnessDb + 60).round()}', 'dB'),
                    _VoiceChip('Rasp', '${(v.roughness * 100).round()}%', ''),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GameButton(label: 'Play Roar', icon: Icons.volume_up_rounded, color: AppColors.surfaceHi, small: true, onTap: _playRoar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GameButton(label: 'Reforge ($_reforgesLeft)', icon: Icons.play_circle_fill_rounded, color: const Color(0xFF7C4DFF), small: true, onTap: _reforgesLeft > 0 ? _reforge : null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GameButton(label: 'Keep This Beast', icon: Icons.check_circle_rounded, color: AppColors.success, expand: true, onTap: _keep),
          TextButton(
            onPressed: _discard,
            child: Text('Release & roar again', style: AppText.label.copyWith(color: AppColors.textDim)),
          ),
        ],
      ),
    );
  }
}

Future<String?> showRenameDialog(BuildContext context, String current) async {
  final ctrl = TextEditingController(text: current);
  String? result;
  await AppDialog.show(
    context: context,
    title: 'Name your beast',
    hero: const IconBadge(icon: Icons.edit_rounded, color: AppColors.cyan),
    accent: AppColors.cyan,
    body: TextField(
      controller: ctrl,
      autofocus: true,
      maxLength: 14,
      textCapitalization: TextCapitalization.words,
      style: AppText.h2,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(counterText: ''),
    ),
    primaryLabel: 'Save',
    onPrimary: () {
      final v = ctrl.text.trim();
      if (v.length < 2) {
        AppToast.show('Name must be at least 2 letters.', type: ToastType.error);
        return;
      }
      result = v;
      Navigator.of(context).pop();
    },
    secondaryLabel: 'Cancel',
  );
  return result;
}

class _VoiceChip extends StatelessWidget {
  const _VoiceChip(this.label, this.value, this.unit);
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(label.toUpperCase(), style: AppText.small.copyWith(fontSize: 10.5, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: AppText.h2),
        if (unit.isNotEmpty) Text(unit, style: AppText.small.copyWith(color: AppColors.textMute)),
      ],
    ),
  );
}

class _ElementGuide extends StatelessWidget {
  const _ElementGuide();
  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Roar style → Element', style: AppText.h3),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in BeastElement.values)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: e.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: e.color.withValues(alpha: 0.35)),
                  ),
                  child: Text('${e.emoji} ${e.roarHint}', style: AppText.small.copyWith(color: AppColors.text)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortalPainter extends CustomPainter {
  _PortalPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final colors = BeastElement.values.map((e) => e.color).toList();
    canvas.drawCircle(
      c,
      r * 0.9,
      Paint()
        ..shader = SweepGradient(colors: [...colors, colors.first]).createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6),
    );
    for (var i = 0; i < 12; i++) {
      final a = i / 12 * 2 * pi;
      final rr = r * (0.55 + 0.15 * sin(t * 2 * pi * 2 + i));
      canvas.drawCircle(c + Offset(cos(a), sin(a)) * rr, 5, Paint()..color = colors[i % colors.length]);
    }
    canvas.drawCircle(c, r * 0.35, Paint()..shader = const RadialGradient(colors: [Colors.white, Color(0x00FFFFFF)]).createShader(Rect.fromCircle(center: c, radius: r * 0.35)));
  }

  @override
  bool shouldRepaint(covariant _PortalPainter old) => old.t != t;
}
