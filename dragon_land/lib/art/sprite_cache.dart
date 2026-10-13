import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../models/enemy_model.dart';
import 'enemy_art.dart';
import 'prop_art.dart';

/// A pre-rendered animation: vector art is rasterised once at load time so
/// that frequently drawn entities cost a single `drawImageRect` per frame.
class SpriteFrames {
  SpriteFrames(this.frames, this.box, this.pixelRatio);

  final List<ui.Image> frames;

  /// Bounds of the art in world units relative to the entity origin.
  final Rect box;
  final double pixelRatio;

  static final Paint _paint = Paint()
    ..filterQuality = FilterQuality.medium
    ..isAntiAlias = true;
  static final Paint _flashPaint = Paint()
    ..filterQuality = FilterQuality.medium
    ..colorFilter = const ColorFilter.mode(Color(0xDDFFFFFF), BlendMode.srcATop);

  /// Draws the frame for [phase] (0..1, looping) at [pos].
  void draw(Canvas c, double phase, Offset pos, {double scale = 1, bool flash = false, double opacity = 1, bool flipX = false}) {
    final n = frames.length;
    final i = ((phase % 1.0) * n).floor().clamp(0, n - 1);
    final img = frames[i];
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    final dst = Rect.fromLTRB(pos.dx + box.left * scale, pos.dy + box.top * scale, pos.dx + box.right * scale, pos.dy + box.bottom * scale);
    final paint = flash ? _flashPaint : _paint;
    if (opacity < 1) {
      paint.color = Color.fromRGBO(255, 255, 255, opacity.clamp(0.0, 1.0));
    } else {
      paint.color = const Color(0xFFFFFFFF);
    }
    if (flipX) {
      c.save();
      c.translate(pos.dx, pos.dy);
      c.scale(-1, 1);
      c.drawImageRect(img, src, dst.shift(Offset(-pos.dx, -pos.dy)), paint);
      c.restore();
    } else {
      c.drawImageRect(img, src, dst, paint);
    }
  }

  void dispose() {
    for (final f in frames) {
      f.dispose();
    }
  }
}

typedef ArtPainter = void Function(Canvas c, double phase);

/// Builds and owns every pre-rendered sprite used in gameplay.
class SpriteCache {
  SpriteCache({this.pixelRatio = 1.6});

  final double pixelRatio;
  final Map<String, SpriteFrames> _sheets = {};

  SpriteFrames operator [](String key) => _sheets[key]!;
  SpriteFrames enemy(EnemyKind k) => _sheets['enemy_${k.name}']!;

  SpriteFrames _render(Rect box, int count, ArtPainter painter) {
    final frames = <ui.Image>[];
    final w = (box.width * pixelRatio).ceil();
    final h = (box.height * pixelRatio).ceil();
    for (var i = 0; i < count; i++) {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      c.scale(pixelRatio);
      c.translate(-box.left, -box.top);
      painter(c, i / count);
      final pic = rec.endRecording();
      frames.add(pic.toImageSync(w, h));
      pic.dispose();
    }
    return SpriteFrames(frames, box, pixelRatio);
  }

  void build() {
    if (_sheets.isNotEmpty) return;
    _sheets['coin'] = _render(const Rect.fromLTRB(-26, -26, 26, 26), 12, (c, p) => PropArt.coin(c, p));
    _sheets['gem'] = _render(const Rect.fromLTRB(-28, -28, 28, 28), 8, (c, p) => PropArt.gem(c, p));
    _sheets['heart'] = _render(const Rect.fromLTRB(-28, -30, 28, 26), 8, (c, p) => PropArt.heart(c, p));
    _sheets['magnet'] = _render(const Rect.fromLTRB(-26, -26, 26, 26), 8, (c, p) => PropArt.magnet(c, p));
    _sheets['crystal'] = _render(const Rect.fromLTRB(-60, -112, 60, 6), 8, (c, p) => PropArt.crystal(c, p));
    _sheets['boulder'] = _render(const Rect.fromLTRB(-56, -88, 56, 4), 1, (c, p) => PropArt.boulder(c));
    _sheets['boulder_cracked'] = _render(const Rect.fromLTRB(-56, -88, 56, 4), 1, (c, p) => PropArt.boulder(c, crack: 1));
    _sheets['thorns'] = _render(const Rect.fromLTRB(-70, -82, 70, 4), 8, (c, p) => PropArt.thorns(c, p));
    _sheets['barrier'] = _render(const Rect.fromLTRB(-46, -250, 46, 4), 8, (c, p) => PropArt.barrier(c, p));
    _sheets['pod'] = _render(const Rect.fromLTRB(-48, -48, 48, 48), 8, (c, p) => PropArt.spikePod(c, p));
    _sheets['chest'] = _render(const Rect.fromLTRB(-70, -120, 70, 6), 6, (c, p) => PropArt.chest(c, p));
    _sheets['chest_open'] = _render(const Rect.fromLTRB(-70, -120, 70, 6), 1, (c, p) => PropArt.chest(c, 0, open: 1));
    _sheets['gate'] = _render(const Rect.fromLTRB(-96, -96, 96, 96), 12, (c, p) => PropArt.gate(c, p));
    _sheets['enemy_slime'] = _render(const Rect.fromLTRB(-56, -86, 56, 6), 8, (c, p) => EnemyArt.paint(c, EnemyKind.slime, p));
    _sheets['enemy_bat'] = _render(const Rect.fromLTRB(-62, -74, 62, 4), 8, (c, p) => EnemyArt.paint(c, EnemyKind.bat, p));
    _sheets['enemy_stone'] = _render(const Rect.fromLTRB(-84, -140, 84, 6), 8, (c, p) => EnemyArt.paint(c, EnemyKind.stone, p));
    _sheets['enemy_goblin'] = _render(const Rect.fromLTRB(-96, -150, 70, 6), 8, (c, p) => EnemyArt.paint(c, EnemyKind.goblin, p));
  }

  void dispose() {
    for (final s in _sheets.values) {
      s.dispose();
    }
    _sheets.clear();
  }
}
