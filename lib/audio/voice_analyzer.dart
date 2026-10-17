import 'dart:math';
import 'dart:typed_data';

import '../models/monster.dart';

class VoiceAnalysisException implements Exception {
  VoiceAnalysisException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Pure-Dart roar analysis. Runs in a background isolate via compute().
///
/// Input: little-endian 16-bit mono PCM.
class VoiceAnalyzer {
  static const int frameSize = 1024;
  static const int hop = 512;

  static VoiceProfile analyze(AnalysisInput input) {
    final pcm = input.pcm;
    final sr = input.sampleRate;
    final samples = Float64List(pcm.lengthInBytes ~/ 2);
    final bd = ByteData.sublistView(pcm);
    for (var i = 0; i < samples.length; i++) {
      samples[i] = bd.getInt16(i * 2, Endian.little) / 32768.0;
    }
    if (samples.length < frameSize * 4) {
      throw VoiceAnalysisException('Roar too short. Hold on for the full 3 seconds!');
    }

    // Remove DC offset.
    var mean = 0.0;
    for (final s in samples) {
      mean += s;
    }
    mean /= samples.length;
    for (var i = 0; i < samples.length; i++) {
      samples[i] -= mean;
    }

    final rmsList = <double>[];
    final zcrList = <double>[];
    final pitches = <double>[];
    final minLag = (sr / 900).floor();
    final maxLag = (sr / 60).ceil();
    var peakRms = 0.0;

    final frames = <int>[];
    for (var start = 0; start + frameSize <= samples.length; start += hop) {
      frames.add(start);
      var sum = 0.0;
      var zc = 0;
      for (var i = start; i < start + frameSize; i++) {
        sum += samples[i] * samples[i];
        if (i > start && (samples[i] >= 0) != (samples[i - 1] >= 0)) zc++;
      }
      final rms = sqrt(sum / frameSize);
      rmsList.add(rms);
      zcrList.add(zc / frameSize);
      if (rms > peakRms) peakRms = rms;
    }

    // Adaptive gate: frames meaningfully above the noise floor count as "roar".
    final sorted = [...rmsList]..sort();
    final noiseFloor = sorted[(sorted.length * 0.1).floor()];
    // If the player roared for the whole window, the "floor" is the roar
    // itself, so the floor-based gate is capped well below the peak.
    final gate = max(0.012, max(min(noiseFloor * 2.5, peakRms * 0.35), peakRms * 0.12));

    final active = <int>[];
    for (var f = 0; f < rmsList.length; f++) {
      if (rmsList[f] >= gate) active.add(f);
    }
    if (active.length < 4 || peakRms < 0.02) {
      throw VoiceAnalysisException('Too quiet! Get closer to the mic and ROAR louder.');
    }

    var loudSum = 0.0;
    var zcrSum = 0.0;
    for (final f in active) {
      final start = frames[f];
      loudSum += rmsList[f];
      zcrSum += zcrList[f];
      final p = _pitch(samples, start, sr, minLag, maxLag);
      if (p != null) pitches.add(p);
    }
    final avgRms = loudSum / active.length;
    final loudnessDb = (20 * log(avgRms) / ln10).clamp(-60.0, 0.0);
    final voicedRatio = pitches.length / active.length;
    final zcrNorm = ((zcrSum / active.length) / 0.25).clamp(0.0, 1.0);
    final roughness = (0.55 * (1 - voicedRatio) + 0.45 * zcrNorm).clamp(0.0, 1.0);

    double pitchHz;
    double variation;
    if (pitches.length >= 3) {
      pitches.sort();
      // Median-ish trimmed mean for robustness against octave errors.
      final lo = (pitches.length * 0.2).floor();
      final hi = max(lo + 1, (pitches.length * 0.8).ceil());
      final core = pitches.sublist(lo, hi);
      pitchHz = core.reduce((a, b) => a + b) / core.length;
      final sd = sqrt(core.map((p) => pow(p - pitchHz, 2)).reduce((a, b) => a + b) / core.length);
      final spread = (pitches[(pitches.length * 0.9).floor().clamp(0, pitches.length - 1)] - pitches[(pitches.length * 0.1).floor()]) / pitchHz;
      variation = (0.5 * (sd / pitchHz) / 0.15 + 0.5 * spread / 0.6).clamp(0.0, 1.0);
    } else {
      // Unvoiced growl / hiss: estimate "pitch" from brightness.
      pitchHz = 90 + zcrNorm * 300;
      variation = 0.5;
    }

    return VoiceProfile(pitchHz: pitchHz, loudnessDb: loudnessDb, roughness: roughness, variation: variation, duration: (active.length / rmsList.length).clamp(0.0, 1.0));
  }

  /// Normalised autocorrelation pitch detector. Returns null if unvoiced.
  static double? _pitch(Float64List s, int start, int sr, int minLag, int maxLag) {
    final n = frameSize;
    var energy = 0.0;
    for (var i = start; i < start + n; i++) {
      energy += s[i] * s[i];
    }
    if (energy <= 1e-9) return null;
    var bestLag = -1;
    var best = 0.0;
    final upper = min(maxLag, n - 64);
    final corr = Float64List(upper + 2);
    for (var lag = minLag; lag <= upper; lag++) {
      var c = 0.0;
      var e1 = 0.0;
      var e2 = 0.0;
      for (var i = start; i < start + n - lag; i++) {
        final a = s[i];
        final b = s[i + lag];
        c += a * b;
        e1 += a * a;
        e2 += b * b;
      }
      final v = c / (sqrt(e1 * e2) + 1e-12);
      corr[lag] = v;
      if (v > best) {
        best = v;
        bestLag = lag;
      }
    }
    if (bestLag < 0 || best < 0.5) return null;
    // Prefer the shortest lag that is nearly as good (avoids octave-down errors).
    for (var lag = minLag; lag < bestLag; lag++) {
      if (corr[lag] > best * 0.9 && corr[lag] >= corr[lag - 1] && corr[lag] >= corr[lag + 1]) {
        bestLag = lag;
        break;
      }
    }
    return sr / bestLag;
  }
}

class AnalysisInput {
  AnalysisInput(this.pcm, this.sampleRate);
  final Uint8List pcm;
  final int sampleRate;
}

VoiceProfile analyzeVoiceIsolate(AnalysisInput input) => VoiceAnalyzer.analyze(input);

/// Wraps raw PCM16 mono into a playable WAV file.
Uint8List pcmToWav(Uint8List pcm, int sampleRate) {
  final header = ByteData(44);
  void str(int o, String s) {
    for (var i = 0; i < s.length; i++) {
      header.setUint8(o + i, s.codeUnitAt(i));
    }
  }

  str(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  str(8, 'WAVE');
  str(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, 1, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, sampleRate * 2, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  str(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);
  return Uint8List.fromList([...header.buffer.asUint8List(), ...pcm]);
}
