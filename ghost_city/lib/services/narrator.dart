import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum NarratorStatus { idle, playing, paused }

/// Reads a text aloud on the device and reports progress, with pause/resume
/// implemented by restarting from the last spoken word (works on every platform).
class Narrator extends ChangeNotifier {
  Narrator() {
    _tts.setStartHandler(() {
      status = NarratorStatus.playing;
      notifyListeners();
    });
    _tts.setProgressHandler((text, start, end, word) {
      _offset = _base + start;
      notifyListeners();
    });
    _tts.setCompletionHandler(() {
      _offset = _text.length;
      status = NarratorStatus.idle;
      notifyListeners();
      onComplete?.call();
    });
    _tts.setCancelHandler(() {});
    _tts.setErrorHandler((msg) {
      status = NarratorStatus.idle;
      notifyListeners();
    });
  }

  final FlutterTts _tts = FlutterTts();
  String _text = '';
  int _base = 0;
  int _offset = 0;
  double rate = 0.45;
  NarratorStatus status = NarratorStatus.idle;
  VoidCallback? onComplete;

  double get progress => _text.isEmpty ? 0 : (_offset / _text.length).clamp(0.0, 1.0);
  bool get isPlaying => status == NarratorStatus.playing;

  Future<void> _configure() async {
    try {
      await _tts.setLanguage('en-US');
    } catch (_) {}
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(1.0);
  }

  void load(String text) {
    _text = text;
    _base = 0;
    _offset = 0;
    status = NarratorStatus.idle;
    notifyListeners();
  }

  Future<void> play() async {
    if (_text.isEmpty) return;
    if (_offset >= _text.length) _offset = 0;
    await _configure();
    _base = _offset;
    status = NarratorStatus.playing;
    notifyListeners();
    await _tts.speak(_text.substring(_offset));
  }

  Future<void> pause() async {
    await _tts.stop();
    status = NarratorStatus.paused;
    notifyListeners();
  }

  Future<void> toggle() => isPlaying ? pause() : play();

  Future<void> seekFraction(double f) async {
    final wasPlaying = isPlaying;
    if (wasPlaying) await _tts.stop();
    var i = (f.clamp(0.0, 1.0) * _text.length).round();
    // Snap to the start of a word so speech never begins mid-word.
    while (i > 0 && i < _text.length && _text[i - 1] != ' ') {
      i--;
    }
    _offset = i;
    notifyListeners();
    if (wasPlaying) await play();
  }

  Future<void> stop() async {
    await _tts.stop();
    status = NarratorStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
