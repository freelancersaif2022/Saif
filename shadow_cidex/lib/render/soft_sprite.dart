import 'dart:ui' as ui;
import 'dart:ui';

/// Soft radial puff used for smoke, fog wisps and dust. Generated once.
class SoftSprite {
  SoftSprite._();

  static ui.Image? _image;
  static final Map<int, ColorFilter> _filters = {};
  static final Paint _paint = Paint()..filterQuality = FilterQuality.low;
  static const double _size = 64;
  static final Rect _src = Rect.fromLTWH(0, 0, _size, _size);

  static ui.Image get image => _image ??= _make();

  static ui.Image _make() {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    final p = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(_size / 2, _size / 2),
        _size / 2,
        const [Color(0xFFFFFFFF), Color(0xAAFFFFFF), Color(0x33FFFFFF), Color(0x00FFFFFF)],
        const [0.0, 0.35, 0.7, 1.0],
      );
    c.drawCircle(const Offset(_size / 2, _size / 2), _size / 2, p);
    return rec.endRecording().toImageSync(_size.toInt(), _size.toInt());
  }

  /// Draws a soft puff of [color] (its alpha is respected) with [radius].
  static void draw(Canvas c, Offset center, double radius, Color color, {BlendMode blend = BlendMode.srcOver}) {
    final a = (color.a * 255).round();
    if (a <= 0) return;
    final key = (color.r * 255).round() << 16 | (color.g * 255).round() << 8 | (color.b * 255).round();
    final filter = _filters[key] ??= ColorFilter.mode(color.withAlpha(255), BlendMode.modulate);
    _paint
      ..colorFilter = filter
      ..blendMode = blend
      ..color = Color.fromARGB(a, 0, 0, 0);
    c.drawImageRect(image, _src, Rect.fromCircle(center: center, radius: radius), _paint);
  }
}
