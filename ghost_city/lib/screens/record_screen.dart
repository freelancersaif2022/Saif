import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../data/content.dart';
import '../widgets/common.dart';
import 'paywall_screen.dart';

/// Opens the recorder, or the upgrade screen when the free limit is reached.
void openRecorder(BuildContext context, {Place? place}) {
  final state = AppScope.read(context);
  Navigator.of(context).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => state.canRecordMore ? RecordScreen(place: place) : const PaywallScreen(reason: 'You’ve used your 3 free memories.'),
  ));
}

enum _Phase { ready, recording, recorded }

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, this.place});
  final Place? place;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _recorder = AudioRecorder();
  final _preview = AudioPlayer();
  final _title = TextEditingController();
  final _levels = <double>[];
  StreamSubscription<Amplitude>? _ampSub;
  Timer? _timer;

  _Phase _phase = _Phase.ready;
  String? _path;
  Duration _elapsed = Duration.zero;
  bool _previewing = false;
  late String? _placeId = widget.place?.id;
  int _decade = 1990;

  static const _decades = [1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020];
  static const _maxLength = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _preview.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _previewing = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampSub?.cancel();
    _recorder.dispose();
    _preview.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone access is off. Allow it in your phone’s Settings to record.')),
      );
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/memories');
    if (!await folder.exists()) await folder.create(recursive: true);
    final path = '${folder.path}/memory_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 96000, numChannels: 1), path: path);
    HapticFeedback.mediumImpact();
    _levels.clear();
    _ampSub = _recorder.onAmplitudeChanged(const Duration(milliseconds: 90)).listen((a) {
      // dBFS (-60..0) to 0..1.
      final v = ((a.current + 50) / 50).clamp(0.04, 1.0);
      setState(() {
        _levels.add(v);
        if (_levels.length > 60) _levels.removeAt(0);
      });
    });
    final started = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      setState(() => _elapsed = DateTime.now().difference(started));
      if (_elapsed >= _maxLength) _stop();
    });
    setState(() {
      _path = path;
      _phase = _Phase.recording;
      _elapsed = Duration.zero;
    });
  }

  Future<void> _stop() async {
    _timer?.cancel();
    await _ampSub?.cancel();
    _ampSub = null;
    final path = await _recorder.stop();
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    if (_elapsed.inSeconds < 1) {
      _discard(silent: true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('That was too short. Hold on a little longer.')));
      return;
    }
    setState(() {
      _path = path ?? _path;
      _phase = _Phase.recorded;
    });
  }

  Future<void> _discard({bool silent = false}) async {
    await _preview.stop();
    final p = _path;
    if (p != null) {
      try {
        final f = File(p);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _path = null;
      _phase = _Phase.ready;
      _elapsed = Duration.zero;
      _previewing = false;
      _levels.clear();
    });
  }

  Future<void> _togglePreview() async {
    if (_path == null) return;
    if (_previewing) {
      await _preview.stop();
      setState(() => _previewing = false);
    } else {
      setState(() => _previewing = true);
      await _preview.play(DeviceFileSource(_path!));
    }
  }

  Future<void> _save() async {
    await _preview.stop();
    if (!mounted) return;
    final state = AppScope.read(context);
    final title = _title.text.trim().isEmpty ? 'Memory from the ${_decade}s' : _title.text.trim();
    await state.addMemory(Memory(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      placeId: _placeId,
      decade: _decade,
      audioPath: _path!,
      seconds: _elapsed.inSeconds,
      createdAt: DateTime.now(),
      privacy: 'Only me',
    ));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memory pinned. Thank you for remembering.')));
  }

  Future<bool> _confirmLeave() async {
    if (_phase == _Phase.ready) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Discard this recording?', style: GC.display(22)),
        content: Text('Your memory hasn’t been saved yet.', style: GC.body(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep recording')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: GC.coral),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (ok == true) {
      if (_phase == _Phase.recording) {
        _timer?.cancel();
        await _ampSub?.cancel();
        await _recorder.stop();
      }
      await _discard(silent: true);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final recording = _phase == _Phase.recording;
    final recorded = _phase == _Phase.recorded;

    return PopScope(
      canPop: _phase == _Phase.ready,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (await _confirmLeave()) nav.pop();
      },
      child: Scaffold(
        backgroundColor: GC.ground,
        body: ListView(
          padding: EdgeInsets.fromLTRB(22, pad.top + 10, 22, pad.bottom + 24),
          children: [
            Row(
              children: [
                GlassIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Close',
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    if (await _confirmLeave()) nav.pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Leave a memory '),
                TextSpan(text: 'for the future', style: GC.display(30, color: GC.amber, style: FontStyle.italic)),
              ]),
              style: GC.display(30, height: 1.15),
            ),
            const SizedBox(height: 22),
            const SectionLabel('Where did it happen?'),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final p in places) ...[
                    ChoiceChipX(label: p.name, selected: _placeId == p.id, solid: true, onTap: () => setState(() => _placeId = p.id)),
                    const SizedBox(width: 8),
                  ],
                  ChoiceChipX(label: 'Somewhere else', selected: _placeId == null, solid: true, onTap: () => setState(() => _placeId = null)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('When?'),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _decades.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ChoiceChipX(
                  label: '${_decades[i]}s',
                  selected: _decade == _decades[i],
                  solid: true,
                  onTap: () => setState(() => _decade = _decades[i]),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Recorder card.
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              decoration: BoxDecoration(
                color: GC.surface,
                borderRadius: BorderRadius.circular(GC.radiusL + 2),
                border: Border.all(color: recording ? const Color(0x66F08A6E) : GC.line),
              ),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      key: ValueKey(_phase),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (recording) ...[
                          const _Blink(),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          recording ? 'RECORDING' : (recorded ? 'READY TO SAVE' : 'TAP TO RECORD'),
                          style: GC.label(color: recording ? GC.coral : (recorded ? GC.green : GC.faint)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(formatDuration(_elapsed),
                      style: GC.display(46, height: 1).copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                  const SizedBox(height: 16),
                  SizedBox(height: 70, child: _Levels(levels: _levels, active: recording)),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoundButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Discard',
                        onTap: recorded ? () => _discard() : null,
                      ),
                      const SizedBox(width: 28),
                      Semantics(
                        button: true,
                        label: recording ? 'Stop recording' : 'Start recording',
                        child: GestureDetector(
                          onTap: recorded ? null : (recording ? _stop : _start),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              color: recorded ? GC.surface3 : GC.coral,
                              shape: BoxShape.circle,
                              boxShadow: recording
                                  ? const [
                                      BoxShadow(color: Color(0x40F08A6E), spreadRadius: 10),
                                      BoxShadow(color: Color(0x1AF08A6E), spreadRadius: 20),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              recording ? Icons.stop_rounded : (recorded ? Icons.check_rounded : Icons.mic_rounded),
                              color: recorded ? GC.green : GC.onAmber,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      _RoundButton(
                        icon: _previewing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        tooltip: 'Listen back',
                        onTap: recorded ? _togglePreview : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: GC.surface2, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: GC.amber, size: 19),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Try telling who was there with you, what it sounded like and what was sold or made here.',
                              style: GC.body(13, height: 1.45)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('Give it a title'),
            const SizedBox(height: 10),
            TextField(
              controller: _title,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              style: GC.body(16, color: GC.text, height: 1.3),
              cursorColor: GC.amber,
              decoration: InputDecoration(
                hintText: 'e.g. Saturday mornings with my grandfather',
                hintStyle: GC.body(15, color: GC.faint, height: 1.3),
                counterStyle: GC.body(11, color: GC.faint),
                filled: true,
                fillColor: GC.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GC.radiusM), borderSide: const BorderSide(color: GC.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GC.radiusM), borderSide: const BorderSide(color: GC.amber)),
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(label: 'Pin memory to this place', icon: Icons.push_pin_outlined, onPressed: recorded ? _save : null),
            const SizedBox(height: 10),
            Center(child: Text('Saved privately on this phone.', style: GC.body(12, color: GC.faint))),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: GC.surface2,
        shape: const CircleBorder(side: BorderSide(color: GC.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(width: 52, height: 52, child: Icon(icon, color: onTap == null ? GC.surface3 : GC.text, size: 23)),
        ),
      ),
    );
  }
}

class _Levels extends StatelessWidget {
  const _Levels({required this.levels, required this.active});
  final List<double> levels;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const bar = 3.5;
      const gap = 3.0;
      final n = (c.maxWidth / (bar + gap)).floor();
      final data = List<double>.filled(n, 0.06);
      final start = n - levels.length;
      for (var i = 0; i < levels.length && i < n; i++) {
        final idx = start + i;
        if (idx >= 0) data[idx] = levels[i];
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < n; i++)
            Container(
              width: bar,
              height: (data[i] * c.maxHeight).clamp(4.0, c.maxHeight),
              margin: EdgeInsets.only(right: i == n - 1 ? 0 : gap),
              decoration: BoxDecoration(
                color: data[i] > 0.07 ? (active ? GC.coral : GC.amber) : GC.surface3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      );
    });
  }
}

class _Blink extends StatefulWidget {
  const _Blink();

  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: GC.coral, shape: BoxShape.circle)),
    );
  }
}
