import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../theme/app_theme.dart';
import '../widgets/feedback.dart';

enum MicAccess { granted, denied, blocked }

/// Records a short roar as raw 16 kHz mono PCM and reports live levels.
class RoarRecorder {
  static const int sampleRate = 16000;
  static const Duration length = Duration(seconds: 3);

  final AudioRecorder _rec = AudioRecorder();
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  StreamSubscription<Uint8List>? _sub;
  final _levels = StreamController<double>.broadcast();
  bool _recording = false;

  Stream<double> get levels => _levels.stream;
  bool get isRecording => _recording;

  static Future<MicAccess> checkAccess() async {
    if (kIsWeb) {
      final ok = await AudioRecorder().hasPermission();
      return ok ? MicAccess.granted : MicAccess.denied;
    }
    var status = await Permission.microphone.status;
    if (status.isGranted) return MicAccess.granted;
    if (status.isPermanentlyDenied) return MicAccess.blocked;
    status = await Permission.microphone.request();
    if (status.isGranted) return MicAccess.granted;
    return status.isPermanentlyDenied ? MicAccess.blocked : MicAccess.denied;
  }

  /// Asks for the mic with friendly explanations. Returns true if usable.
  static Future<bool> ensureAccess(BuildContext context) async {
    final access = await checkAccess();
    switch (access) {
      case MicAccess.granted:
        return true;
      case MicAccess.denied:
        AppToast.show('VoiceBeast needs the microphone to hear your roar. Audio never leaves your phone.', type: ToastType.error, title: 'Microphone needed');
        return false;
      case MicAccess.blocked:
        if (!context.mounted) return false;
        final open = await AppDialog.confirm(
          context: context,
          title: 'Microphone is off',
          message: 'Allow microphone access in Settings to summon beasts. Your voice is analysed on this phone only and never uploaded.',
          confirmLabel: 'Open Settings',
          cancelLabel: 'Not now',
          icon: Icons.mic_off_rounded,
        );
        if (open) await openAppSettings();
        return false;
    }
  }

  Future<void> start() async {
    _buffer.clear();
    final stream = await _rec.startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: sampleRate, numChannels: 1, autoGain: false, echoCancel: false, noiseSuppress: false));
    _recording = true;
    _sub = stream.listen((chunk) {
      _buffer.add(chunk);
      _levels.add(_level(chunk));
    });
  }

  Future<Uint8List> stop() async {
    if (!_recording) return Uint8List(0);
    _recording = false;
    try {
      await _rec.stop();
    } catch (_) {}
    await _sub?.cancel();
    _sub = null;
    final bytes = _buffer.takeBytes();
    // Trim to whole samples.
    return bytes.length.isOdd ? Uint8List.sublistView(bytes, 0, bytes.length - 1) : bytes;
  }

  Future<void> dispose() async {
    await stop();
    await _levels.close();
    await _rec.dispose();
  }

  static double _level(Uint8List chunk) {
    if (chunk.length < 2) return 0;
    final bd = ByteData.sublistView(chunk);
    var sum = 0.0;
    final n = chunk.length ~/ 2;
    for (var i = 0; i < n; i++) {
      final v = bd.getInt16(i * 2, Endian.little) / 32768.0;
      sum += v * v;
    }
    final rms = sqrt(sum / n);
    final db = 20 * log(max(rms, 1e-5)) / ln10;
    return ((db + 55) / 50).clamp(0.0, 1.0);
  }
}

/// Live waveform bars.
class LevelBars extends StatelessWidget {
  const LevelBars({super.key, required this.levels, this.color = AppColors.primary, this.height = 70});
  final List<double> levels;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final l in levels)
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 5,
              height: 4 + l * (height - 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [color, AppColors.gold]),
              ),
            ),
        ],
      ),
    );
  }
}
