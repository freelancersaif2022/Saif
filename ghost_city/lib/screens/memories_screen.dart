import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/app_state.dart';
import '../data/content.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';
import 'record_screen.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pad = MediaQuery.paddingOf(context);
    final list = state.memories;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, pad.top + 14, 20, 30),
      children: [
        Text('MEMORIES', style: GC.label(color: GC.amber)),
        const SizedBox(height: 4),
        Text('Your voice, pinned to places', style: GC.display(28)),
        const SizedBox(height: 8),
        Text('Record what you remember about a street, a shop or a house. Everything stays on this phone.',
            style: GC.body(15, color: GC.muted)),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Record a memory', icon: Icons.mic_rounded, onPressed: () => openRecorder(context)),
        if (!state.premium) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              '${list.length} of ${AppState.freeMemoryLimit} free memories used',
              style: GC.body(12.5, color: GC.faint),
            ),
          ),
        ],
        const SizedBox(height: 26),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
            decoration: BoxDecoration(
              color: GC.surface,
              borderRadius: BorderRadius.circular(GC.radiusL),
              border: Border.all(color: GC.line),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: GC.amberDeep, shape: BoxShape.circle),
                  child: const Icon(Icons.graphic_eq_rounded, color: GC.amber, size: 30),
                ),
                const SizedBox(height: 16),
                Text('No memories yet', style: GC.display(21)),
                const SizedBox(height: 6),
                Text('Your first one could be the street you grew up on.',
                    textAlign: TextAlign.center, style: GC.body(14, color: GC.muted)),
              ],
            ),
          )
        else ...[
          SectionLabel('Recorded', trailing: Text('${list.length}', style: GC.label(color: GC.amber))),
          const SizedBox(height: 12),
          for (final m in list) ...[MemoryTile(memory: m), const SizedBox(height: 10)],
        ],
      ],
    );
  }
}

/// One recorded memory with inline playback.
class MemoryTile extends StatefulWidget {
  const MemoryTile({super.key, required this.memory});
  final Memory memory;

  @override
  State<MemoryTile> createState() => _MemoryTileState();
}

class _MemoryTileState extends State<MemoryTile> {
  AudioPlayer? _player;
  final _subs = <StreamSubscription>[];
  bool _playing = false;
  Duration _pos = Duration.zero;

  Memory get m => widget.memory;

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!File(m.audioPath).existsSync()) {
      showToast('Recording not found', context: context, kind: ToastKind.error, message: 'It is no longer on this phone.');
      return;
    }
    var p = _player;
    if (p == null) {
      p = AudioPlayer();
      _player = p;
      _subs
        ..add(p.onPositionChanged.listen((d) => setState(() => _pos = d)))
        ..add(p.onPlayerComplete.listen((_) => setState(() {
              _playing = false;
              _pos = Duration.zero;
            })));
    }
    if (_playing) {
      await p.pause();
      setState(() => _playing = false);
    } else {
      setState(() => _playing = true);
      if (_pos > Duration.zero) {
        await p.resume();
      } else {
        await p.play(DeviceFileSource(m.audioPath));
      }
    }
  }

  Future<void> _delete() async {
    final ok = await showGhostDialog(
      context,
      title: 'Delete this memory?',
      message: '“${m.title}” will be removed from this phone.',
      icon: Icons.delete_outline_rounded,
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      destructive: true,
    );
    if (ok == true && mounted) {
      await _player?.stop();
      if (!mounted) return;
      await AppScope.read(context).deleteMemory(m);
      showToast('Memory deleted', kind: ToastKind.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = m.placeId == null ? null : placeById(m.placeId!);
    final total = Duration(seconds: m.seconds);
    final frac = total.inMilliseconds == 0 ? 0.0 : (_pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GC.surface,
        borderRadius: BorderRadius.circular(GC.radiusM + 2),
        border: Border.all(color: GC.line),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: _playing ? 'Pause memory' : 'Play memory',
            child: GestureDetector(
              onTap: _toggle,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: frac,
                      strokeWidth: 2.5,
                      backgroundColor: GC.surface3,
                      color: GC.amber,
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: GC.amber, shape: BoxShape.circle),
                      child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: GC.onAmber, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: GC.display(17, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '${m.placeName ?? place?.name ?? 'Somewhere else'} · ${m.decade < 2030 && m.decade % 10 == 0 && m.createdAt.year - m.decade > 9 ? '${m.decade}s' : m.decade} · ${formatDuration(_playing || _pos > Duration.zero ? _pos : total)}',
                  style: GC.body(12.5, color: GC.muted, height: 1.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete memory',
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline_rounded, color: GC.faint, size: 21),
          ),
        ],
      ),
    );
  }
}
