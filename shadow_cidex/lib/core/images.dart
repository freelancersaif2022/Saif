import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Decoded image cache shared by the Flutter screens and the Flame game.
class GameImages {
  GameImages._();

  static const sky = 'sky.jpg';
  static const mountainsFar = 'mountains_far.png';
  static const mountainsNear = 'mountains_near.png';
  static const treesFar = 'trees_far.png';
  static const ruinsMid = 'ruins_mid.png';
  static const ground = 'ground.jpg';
  static const fog = 'fog.png';
  static const foreground = 'foreground.png';
  static const splashBg = 'splash_bg.jpg';
  static const lobbyBg = 'lobby_bg.jpg';

  static const List<String> all = [
    splashBg, fog, lobbyBg, sky, mountainsFar, mountainsNear, treesFar,
    ruinsMid, ground, foreground,
  ];

  static final Map<String, ui.Image> _cache = {};

  static ui.Image? get(String name) => _cache[name];

  static Future<ui.Image?> load(String name) async {
    final cached = _cache[name];
    if (cached != null) return cached;
    try {
      final data = await rootBundle.load('assets/images/$name');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _cache[name] = frame.image;
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  static Future<void> loadAll({void Function(double progress)? onProgress}) async {
    var i = 0;
    for (final n in all) {
      await load(n);
      i++;
      onProgress?.call(i / all.length);
    }
  }
}
