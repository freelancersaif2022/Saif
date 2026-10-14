import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'sprites.dart';

class Cam {
  double w = 0;
  double h = 0;
  double horizon = 0;
  double ground = 0;
  double roadW = 0;
  static const double k = 0.05;

  void layout(double w, double h) {
    this.w = w;
    this.h = h;
    horizon = h * 0.30;
    ground = h * 0.83;
    roadW = w * 0.46;
  }

  double scale(double z) {
    final zz = z < -15 ? -15.0 : z;
    return 1.0 / (1.0 + zz * k);
  }

  double sx(double x, double z) => w / 2 + x * roadW * scale(z);
  double sy(double z) => horizon + (ground - horizon) * scale(z);
}

ui.Color _lerp(ui.Color a, ui.Color b, double t) => ui.Color.lerp(a, b, t)!;

class SceneRenderer {
  final Cam cam = Cam();
  ui.Picture? _bg;
  double _w = 0;
  double _h = 0;
  ui.Paint? _vignette;
  ui.Paint? _fogPaint;
  ui.Rect _fogRect = ui.Rect.zero;
  final Map<String, TextPainter> _text = <String, TextPainter>{};

  final ui.Paint _p = ui.Paint();
  final ui.Paint _spritePaint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
  final ui.Paint _flashPaint = ui.Paint()
    ..filterQuality = ui.FilterQuality.medium
    ..colorFilter = const ui.ColorFilter.mode(ui.Color(0xAAFFFFFF), ui.BlendMode.srcATop);
  final ui.Paint _fadePaint = ui.Paint()..filterQuality = ui.FilterQuality.medium;

  final ui.Path _grassA = ui.Path();
  final ui.Path _grassB = ui.Path();
  final ui.Path _roadA = ui.Path();
  final ui.Path _roadB = ui.Path();
  final ui.Path _curbA = ui.Path();
  final ui.Path _curbB = ui.Path();
  final ui.Path _dash = ui.Path();

  // ---------------------------------------------------------------- layout

  void layout(double w, double h) {
    if (w == _w && h == _h && _bg != null) return;
    _w = w;
    _h = h;
    cam.layout(w, h);
    _bg?.dispose();
    _bg = _buildBackdrop(w, h);
    _vignette = ui.Paint()
      ..shader = ui.Gradient.radial(
        ui.Offset(w / 2, h * 0.55),
        h * 0.80,
        const [ui.Color(0x00000000), ui.Color(0x00000000), ui.Color(0xAA000000)],
        const [0.0, 0.55, 1.0],
      );
    final yTop = cam.sy(92) - 6;
    final yBot = cam.sy(40);
    _fogRect = ui.Rect.fromLTRB(0, yTop, w, yBot);
    _fogPaint = ui.Paint()
      ..shader = ui.Gradient.linear(
        ui.Offset(0, yTop),
        ui.Offset(0, yBot),
        const [ui.Color(0xFFE9B07C), ui.Color(0xEEE9B07C), ui.Color(0x00E9B07C)],
        const [0.0, 0.45, 1.0],
      );
  }

  ui.Picture _buildBackdrop(double w, double h) {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    final hz = cam.horizon;

    // sky
    c.drawRect(
      ui.Rect.fromLTWH(0, 0, w, hz + 6),
      ui.Paint()
        ..shader = ui.Gradient.linear(
          ui.Offset(0, 0),
          ui.Offset(0, hz),
          const [ui.Color(0xFF16204D), ui.Color(0xFF5B3F86), ui.Color(0xFFD9764F), ui.Color(0xFFF8C078)],
          const [0.0, 0.42, 0.8, 1.0],
        ),
    );
    // sun glow
    final sunC = ui.Offset(w * 0.5, hz - h * 0.015);
    c.drawCircle(
      sunC,
      h * 0.26,
      ui.Paint()
        ..shader = ui.Gradient.radial(
          sunC,
          h * 0.26,
          const [ui.Color(0xCCFFE6A8), ui.Color(0x55FFB866), ui.Color(0x00FF9A44)],
          const [0.0, 0.35, 1.0],
        ),
    );
    c.drawCircle(sunC, h * 0.045, ui.Paint()..color = const ui.Color(0xFFFFF2C8));

    // clouds
    final cl = ui.Paint()..color = const ui.Color(0x40FFD8C0);
    for (var i = 0; i < 6; i++) {
      final cx = w * (0.1 + 0.17 * i);
      final cy = hz * (0.25 + 0.11 * ((i * 7) % 5));
      c.drawOval(ui.Rect.fromCenter(center: ui.Offset(cx, cy), width: w * 0.28, height: h * 0.022), cl);
      c.drawOval(ui.Rect.fromCenter(center: ui.Offset(cx + w * 0.05, cy - h * 0.01), width: w * 0.16, height: h * 0.018), cl);
    }

    // mountains
    for (var layer = 0; layer < 2; layer++) {
      final path = ui.Path()..moveTo(0, hz + 2);
      final amp = h * (layer == 0 ? 0.075 : 0.05);
      final base = h * (layer == 0 ? 0.03 : 0.012);
      final steps = 28;
      for (var i = 0; i <= steps; i++) {
        final x = w * i / steps;
        final y = hz - base - amp * (0.5 + 0.5 * math.sin(x * 0.012 + layer * 2.3) * 0.7 + 0.35 * math.sin(x * 0.031 + layer));
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, hz + 2)
        ..close();
      c.drawPath(
        path,
        ui.Paint()
          ..shader = ui.Gradient.linear(
            ui.Offset(0, hz - amp - base),
            ui.Offset(0, hz),
            layer == 0
                ? const [ui.Color(0xFF3A2A5E), ui.Color(0xFF7A4A72)]
                : const [ui.Color(0xFF53396B), ui.Color(0xFFA5606A)],
          ),
      );
    }

    // distant enemy fortress silhouette
    final fc = ui.Paint()..color = const ui.Color(0xFF3A2236);
    final fx = w * 0.5;
    final fh = h * 0.05;
    c.drawRect(ui.Rect.fromLTWH(fx - w * 0.09, hz - fh, w * 0.18, fh + 2), fc);
    for (var i = 0; i < 7; i++) {
      c.drawRect(ui.Rect.fromLTWH(fx - w * 0.09 + i * w * 0.0275, hz - fh - h * 0.008, w * 0.014, h * 0.008), fc);
    }
    for (final side in <double>[-1, 1]) {
      final tx = fx + side * w * 0.11;
      c.drawRect(ui.Rect.fromLTWH(tx - w * 0.022, hz - fh * 1.7, w * 0.044, fh * 1.7 + 2), fc);
      final roof = ui.Path()
        ..moveTo(tx - w * 0.03, hz - fh * 1.7)
        ..lineTo(tx, hz - fh * 2.4)
        ..lineTo(tx + w * 0.03, hz - fh * 1.7)
        ..close();
      c.drawPath(roof, ui.Paint()..color = const ui.Color(0xFF6A1E2A));
    }
    // smoke columns
    final sm = ui.Paint()..color = const ui.Color(0x553A2A40);
    for (var i = 0; i < 5; i++) {
      final sx = w * (0.18 + 0.16 * i);
      for (var j = 0; j < 4; j++) {
        c.drawCircle(ui.Offset(sx + j * 5.0, hz - h * 0.02 - j * h * 0.022), h * (0.012 + 0.006 * j), sm);
      }
    }

    // ground base below the horizon
    c.drawRect(
      ui.Rect.fromLTWH(0, hz, w, h - hz),
      ui.Paint()..color = const ui.Color(0xFF3F5B2F),
    );
    return rec.endRecording();
  }

  void drawBackdrop(ui.Canvas c) {
    final bg = _bg;
    if (bg != null) c.drawPicture(bg);
  }

  // ---------------------------------------------------------------- ground

  void drawGround(ui.Canvas c, double scroll) {
    const step = 4.0;
    _grassA.reset();
    _grassB.reset();
    _roadA.reset();
    _roadB.reset();
    _curbA.reset();
    _curbB.reset();
    _dash.reset();

    final w = cam.w;
    final cx = w / 2;
    final kMin = (scroll / step).floor() - 2;
    for (var k = kMin; k < kMin + 28; k++) {
      final z0 = k * step - scroll;
      final z1 = z0 + step;
      if (z0 > 96) break;
      final yFar = cam.sy(z1);
      final yNear = cam.sy(z0) + 1.5;
      if (yNear < cam.horizon) continue;
      final even = (k & 1) == 0;
      final gr = ui.Rect.fromLTRB(0, yFar, w, yNear);
      (even ? _grassA : _grassB).addRect(gr);

      final s0 = cam.scale(z0);
      final s1 = cam.scale(z1);
      final rw0 = cam.roadW * s0;
      final rw1 = cam.roadW * s1;
      final road = ui.Path()
        ..moveTo(cx - rw1, yFar)
        ..lineTo(cx + rw1, yFar)
        ..lineTo(cx + rw0, yNear)
        ..lineTo(cx - rw0, yNear)
        ..close();
      (even ? _roadA : _roadB).addPath(road, ui.Offset.zero);

      // curbs
      final cw0 = rw0 * 0.085;
      final cw1 = rw1 * 0.085;
      final curb = ui.Path()
        ..moveTo(cx - rw1 - cw1, yFar)
        ..lineTo(cx - rw1, yFar)
        ..lineTo(cx - rw0, yNear)
        ..lineTo(cx - rw0 - cw0, yNear)
        ..close()
        ..moveTo(cx + rw1, yFar)
        ..lineTo(cx + rw1 + cw1, yFar)
        ..lineTo(cx + rw0 + cw0, yNear)
        ..lineTo(cx + rw0, yNear)
        ..close();
      (even ? _curbA : _curbB).addPath(curb, ui.Offset.zero);

      if (even) {
        for (final lx in <double>[-0.5, 0.0, 0.5]) {
          final hw0 = rw0 * 0.012;
          final hw1 = rw1 * 0.012;
          _dash
            ..moveTo(cx + lx * rw1 - hw1, yFar)
            ..lineTo(cx + lx * rw1 + hw1, yFar)
            ..lineTo(cx + lx * rw0 + hw0, yNear)
            ..lineTo(cx + lx * rw0 - hw0, yNear)
            ..close();
        }
      }
    }

    c.drawPath(_grassA, _p..color = const ui.Color(0xFF4C7035)..style = ui.PaintingStyle.fill);
    c.drawPath(_grassB, _p..color = const ui.Color(0xFF446530));
    c.drawPath(_roadA, _p..color = const ui.Color(0xFF9A8468));
    c.drawPath(_roadB, _p..color = const ui.Color(0xFF8F7A5F));
    c.drawPath(_curbA, _p..color = const ui.Color(0xFFD83A3A));
    c.drawPath(_curbB, _p..color = const ui.Color(0xFFF2EBDD));
    c.drawPath(_dash, _p..color = const ui.Color(0x33FFF4D6));

    // road lighting (center sheen)
    final yH = cam.horizon;
    c.drawRect(
      ui.Rect.fromLTRB(cx - cam.roadW * 1.3, yH, cx + cam.roadW * 1.3, cam.h),
      _p
        ..shader = ui.Gradient.linear(
          ui.Offset(cx - cam.roadW, 0),
          ui.Offset(cx + cam.roadW, 0),
          const [ui.Color(0x33000000), ui.Color(0x00000000), ui.Color(0x33000000)],
          const [0.0, 0.5, 1.0],
        ),
    );
    _p.shader = null;

    // roadside props
    const pstep = 6.0;
    final kk = (scroll / pstep).floor();
    for (var i = kk + 17; i >= kk - 1; i--) {
      final z = i * pstep - scroll;
      if (z < -3 || z > 92) continue;
      final hsh = ((i * 2654435761) >> 4) & 0xFFFF;
      final side = (i & 1) == 0 ? -1.0 : 1.0;
      final off = 1.45 + (hsh % 100) / 100.0 * 0.9;
      final sc = cam.scale(z);
      final px = cam.sx(side * off, z);
      final py = cam.sy(z);
      final kind = hsh % 3;
      if (kind == 0) {
        _drawTree(c, px, py, sc);
      } else if (kind == 1) {
        _drawRock(c, px, py, sc);
      } else {
        _drawPole(c, px, py, sc, side < 0);
      }
    }
  }

  void _drawTree(ui.Canvas c, double px, double py, double sc) {
    final u = cam.w * 0.1 * sc;
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(px, py), width: u * 0.9, height: u * 0.22), _p..color = const ui.Color(0x44000000));
    c.drawRect(ui.Rect.fromLTWH(px - u * 0.06, py - u * 0.55, u * 0.12, u * 0.55), _p..color = const ui.Color(0xFF5A3A22));
    final cc = ui.Offset(px, py - u * 0.8);
    c.drawCircle(cc, u * 0.38, _p..color = const ui.Color(0xFF2F5A28));
    c.drawCircle(ui.Offset(cc.dx - u * 0.1, cc.dy - u * 0.1), u * 0.28, _p..color = const ui.Color(0xFF4E8A3A));
    c.drawCircle(ui.Offset(cc.dx - u * 0.14, cc.dy - u * 0.15), u * 0.12, _p..color = const ui.Color(0x558FD066));
  }

  void _drawRock(ui.Canvas c, double px, double py, double sc) {
    final u = cam.w * 0.08 * sc;
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(px, py), width: u * 1.1, height: u * 0.2), _p..color = const ui.Color(0x44000000));
    final r = ui.Path()
      ..moveTo(px - u * 0.5, py)
      ..lineTo(px - u * 0.35, py - u * 0.42)
      ..lineTo(px + u * 0.05, py - u * 0.55)
      ..lineTo(px + u * 0.5, py - u * 0.2)
      ..lineTo(px + u * 0.55, py)
      ..close();
    c.drawPath(r, _p..color = const ui.Color(0xFF7C7A86));
    final r2 = ui.Path()
      ..moveTo(px - u * 0.35, py - u * 0.42)
      ..lineTo(px + u * 0.05, py - u * 0.55)
      ..lineTo(px + u * 0.12, py - u * 0.2)
      ..lineTo(px - u * 0.3, py - u * 0.1)
      ..close();
    c.drawPath(r2, _p..color = const ui.Color(0xFFA9A8B4));
  }

  void _drawPole(ui.Canvas c, double px, double py, double sc, bool blue) {
    final u = cam.w * 0.1 * sc;
    c.drawRect(ui.Rect.fromLTWH(px - u * 0.025, py - u * 1.3, u * 0.05, u * 1.3), _p..color = const ui.Color(0xFF3A2A20));
    final flag = ui.Path()
      ..moveTo(px + u * 0.025, py - u * 1.28)
      ..lineTo(px + u * 0.42, py - u * 1.15)
      ..lineTo(px + u * 0.025, py - u * 0.92)
      ..close();
    c.drawPath(flag, _p..color = blue ? const ui.Color(0xFF2E7BE8) : const ui.Color(0xFFD6353A));
  }

  void drawFog(ui.Canvas c) {
    final fp = _fogPaint;
    if (fp != null) c.drawRect(_fogRect, fp);
  }

  void drawVignette(ui.Canvas c) {
    final v = _vignette;
    if (v != null) c.drawRect(ui.Rect.fromLTWH(0, 0, cam.w, cam.h), v);
  }

  // ---------------------------------------------------------------- sprites

  void drawSprite(ui.Canvas c, int style, int frame, double px, double py, double dh,
      {bool flash = false, double alpha = 1.0}) {
    final im = Sprites.I.get(style, frame);
    final dw = dh * (Sprites.w / Sprites.h);
    final dst = ui.Rect.fromLTWH(px - dw / 2, py - dh + dh * 0.04, dw, dh);
    final src = ui.Rect.fromLTWH(0, 0, im.width.toDouble(), im.height.toDouble());
    if (flash) {
      c.drawImageRect(im, src, dst, _flashPaint);
    } else if (alpha < 0.99) {
      _fadePaint.color = ui.Color.fromARGB((alpha.clamp(0.0, 1.0) * 255).round(), 255, 255, 255);
      c.drawImageRect(im, src, dst, _fadePaint);
    } else {
      c.drawImageRect(im, src, dst, _spritePaint);
    }
  }

  void drawSpriteRotated(ui.Canvas c, int style, double px, double cy, double dh, double rot, double alpha) {
    c.save();
    c.translate(px, cy);
    c.rotate(rot);
    final im = Sprites.I.get(style, 1);
    final dw = dh * (Sprites.w / Sprites.h);
    final dst = ui.Rect.fromLTWH(-dw / 2, -dh / 2, dw, dh);
    final src = ui.Rect.fromLTWH(0, 0, im.width.toDouble(), im.height.toDouble());
    _fadePaint.color = ui.Color.fromARGB((alpha.clamp(0.0, 1.0) * 255).round(), 255, 255, 255);
    c.drawImageRect(im, src, dst, _fadePaint);
    c.restore();
  }

  void drawShadow(ui.Canvas c, double px, double py, double wd) {
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(px, py), width: wd, height: wd * 0.26),
        _p..color = const ui.Color(0x55000000)..style = ui.PaintingStyle.fill);
  }

  void drawHpBar(ui.Canvas c, double px, double top, double wd, double frac, {ui.Color color = const ui.Color(0xFFE53935)}) {
    final h = math.max(3.0, wd * 0.08);
    final r = ui.RRect.fromRectAndRadius(ui.Rect.fromLTWH(px - wd / 2, top, wd, h), ui.Radius.circular(h / 2));
    c.drawRRect(r, _p..color = const ui.Color(0xCC10131C)..style = ui.PaintingStyle.fill);
    final f = frac.clamp(0.0, 1.0).toDouble();
    if (f > 0) {
      final fr = ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(px - wd / 2 + 1, top + 1, math.max(0.0, (wd - 2) * f), math.max(1.0, h - 2)), ui.Radius.circular(h / 2));
      c.drawRRect(fr, _p..color = color);
    }
    c.drawRRect(r, _p..color = const ui.Color(0xFF000000)..style = ui.PaintingStyle.stroke..strokeWidth = 1);
    _p.style = ui.PaintingStyle.fill;
  }

  // ---------------------------------------------------------------- props

  void drawCrate(ui.Canvas c, double px, double py, double hw, double hitFlash, double hpFrac) {
    final ht = hw * 1.5;
    final top = hw * 0.34;
    final front = ui.Rect.fromLTWH(px - hw, py - ht, hw * 2, ht);
    drawShadow(c, px, py, hw * 2.6);
    c.drawRect(
        front,
        _p
          ..shader = ui.Gradient.linear(ui.Offset(px - hw, py - ht), ui.Offset(px + hw, py),
              const [ui.Color(0xFFC98A4B), ui.Color(0xFF9A6234), ui.Color(0xFF6B4122)])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    final topF = ui.Path()
      ..moveTo(px - hw, py - ht)
      ..lineTo(px - hw * 0.82, py - ht - top)
      ..lineTo(px + hw * 0.82, py - ht - top)
      ..lineTo(px + hw, py - ht)
      ..close();
    c.drawPath(topF, _p..color = const ui.Color(0xFFE0A866));
    final line = _p
      ..color = const ui.Color(0xFF3F2512)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, hw * 0.07);
    c.drawRect(front, line);
    c.drawLine(ui.Offset(px - hw, py - ht), ui.Offset(px + hw, py), line);
    c.drawLine(ui.Offset(px + hw, py - ht), ui.Offset(px - hw, py), line);
    c.drawPath(topF, line);
    _p.style = ui.PaintingStyle.fill;
    if (hitFlash > 0) {
      c.drawRect(front, _p..color = ui.Color.fromARGB((hitFlash * 5 * 255).clamp(0, 160).round(), 255, 255, 255));
    }
    if (hpFrac < 0.5) {
      c.drawLine(ui.Offset(px - hw * 0.4, py - ht), ui.Offset(px, py - ht * 0.45), _p..color = const ui.Color(0xFF2A1608)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, hw * 0.06));
      _p.style = ui.PaintingStyle.fill;
    }
  }

  void drawBarrel(ui.Canvas c, double px, double py, double hw, double hitFlash, double time) {
    final ht = hw * 2.1;
    drawShadow(c, px, py, hw * 2.6);
    final body = ui.RRect.fromRectAndRadius(ui.Rect.fromLTWH(px - hw, py - ht, hw * 2, ht), ui.Radius.circular(hw * 0.35));
    c.drawRRect(
        body,
        _p
          ..shader = ui.Gradient.linear(ui.Offset(px - hw, py), ui.Offset(px + hw, py),
              const [ui.Color(0xFF7A1212), ui.Color(0xFFE23A2A), ui.Color(0xFF7A1212)], const [0.0, 0.4, 1.0])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    c.drawRect(ui.Rect.fromLTWH(px - hw, py - ht * 0.62, hw * 2, ht * 0.18), _p..color = const ui.Color(0xFFFFC31F));
    c.drawRect(ui.Rect.fromLTWH(px - hw, py - ht * 0.22, hw * 2, ht * 0.1), _p..color = const ui.Color(0xFF2A2A30));
    final tri = ui.Path()
      ..moveTo(px, py - ht * 0.98)
      ..lineTo(px - hw * 0.28, py - ht * 0.78)
      ..lineTo(px + hw * 0.28, py - ht * 0.78)
      ..close();
    c.drawPath(tri, _p..color = const ui.Color(0xFFFFE066));
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(px, py - ht), width: hw * 2, height: hw * 0.5), _p..color = const ui.Color(0xFFB02820));
    c.drawRRect(body, _p..color = const ui.Color(0xFF200808)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, hw * 0.07));
    _p.style = ui.PaintingStyle.fill;
    // blinking fuse light
    if (((time * 4).floor() & 1) == 0) {
      c.drawCircle(ui.Offset(px, py - ht * 1.04), hw * 0.14, _p..color = const ui.Color(0xFFFFFFA0));
    }
    if (hitFlash > 0) {
      c.drawRRect(body, _p..color = ui.Color.fromARGB((hitFlash * 5 * 255).clamp(0, 170).round(), 255, 255, 255));
    }
  }

  void drawSpikes(ui.Canvas c, double px, double py, double hw, double hitFlash) {
    final sh = math.max(6.0, hw * 0.55);
    var n = (hw * 2 / (sh * 0.9)).round();
    if (n < 3) n = 3;
    if (n > 16) n = 16;
    c.drawRect(ui.Rect.fromLTWH(px - hw, py - sh * 0.18, hw * 2, sh * 0.28), _p..color = const ui.Color(0xFF2B2B33)..style = ui.PaintingStyle.fill);
    final path = ui.Path();
    final sw = hw * 2 / n;
    for (var i = 0; i < n; i++) {
      final x0 = px - hw + i * sw;
      path
        ..moveTo(x0 + sw * 0.08, py)
        ..lineTo(x0 + sw * 0.5, py - sh)
        ..lineTo(x0 + sw * 0.92, py)
        ..close();
    }
    c.drawPath(
        path,
        _p
          ..shader = ui.Gradient.linear(ui.Offset(px, py - sh), ui.Offset(px, py),
              const [ui.Color(0xFFF2F4F8), ui.Color(0xFF8E96A6)])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    c.drawPath(path, _p..color = const ui.Color(0xFF1C1C22)..style = ui.PaintingStyle.stroke..strokeWidth = 1.0);
    _p.style = ui.PaintingStyle.fill;
    if (hitFlash > 0) {
      c.drawRect(ui.Rect.fromLTWH(px - hw, py - sh, hw * 2, sh), _p..color = const ui.Color(0x66FF4040));
    }
  }

  void drawCoin(ui.Canvas c, double px, double py, double r, double spin) {
    final rx = math.max(r * 0.12, r * math.cos(spin).abs());
    final cy = py - r * 1.5;
    c.drawCircle(ui.Offset(px, cy), r * 1.6, _p..color = const ui.Color(0x33FFD040)..blendMode = ui.BlendMode.plus);
    _p.blendMode = ui.BlendMode.srcOver;
    final rect = ui.Rect.fromCenter(center: ui.Offset(px, cy), width: rx * 2, height: r * 2);
    c.drawOval(
        rect,
        _p
          ..shader = ui.Gradient.linear(ui.Offset(px - rx, cy - r), ui.Offset(px + rx, cy + r),
              const [ui.Color(0xFFFFF3A0), ui.Color(0xFFFFC21F), ui.Color(0xFFB87A10)])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    c.drawOval(rect, _p..color = const ui.Color(0xFF7A4E08)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, r * 0.14));
    _p.style = ui.PaintingStyle.fill;
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(px, cy), width: rx * 1.1, height: r * 1.1),
        _p..color = const ui.Color(0x66FFFFFF)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, r * 0.1));
    _p.style = ui.PaintingStyle.fill;
    // shadow
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(px, py), width: r * 1.6, height: r * 0.45), _p..color = const ui.Color(0x44000000));
  }

  TextPainter _tp(String s) {
    return _text.putIfAbsent(s, () {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: ui.Color(0xFFFFFFFF),
            shadows: [ui.Shadow(color: ui.Color(0xFF000000), blurRadius: 6, offset: ui.Offset(0, 3))],
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      return tp;
    });
  }

  void drawGate(ui.Canvas c, double px, double py, double wd, double ht, bool bad, String label, double flash, double time) {
    final half = wd / 2;
    final postW = math.max(3.0, wd * 0.035);
    final pulse = 0.5 + 0.5 * math.sin(time * 5);
    final panelTop = py - ht * 0.88;
    final panelBot = py - ht * 0.08;
    final c1 = bad ? const ui.Color(0xFFFF4B4B) : const ui.Color(0xFF3FA9FF);
    final c2 = bad ? const ui.Color(0xFF8A1020) : const ui.Color(0xFF1B4BC8);
    final a = (0.30 + 0.12 * pulse + flash * 0.6).clamp(0.0, 0.9).toDouble();
    final panel = ui.Rect.fromLTRB(px - half + postW, panelTop, px + half - postW, panelBot);
    c.drawRect(
        panel,
        _p
          ..shader = ui.Gradient.linear(ui.Offset(0, panelTop), ui.Offset(0, panelBot),
              [c1.withAlpha((a * 255).round()), c2.withAlpha((a * 255 * 0.6).round())])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    // scanlines
    final sl = _p..color = ui.Color.fromARGB(40, 255, 255, 255)..style = ui.PaintingStyle.stroke..strokeWidth = 1;
    for (var i = 1; i < 5; i++) {
      final y = panelTop + (panelBot - panelTop) * i / 5;
      c.drawLine(ui.Offset(panel.left, y), ui.Offset(panel.right, y), sl);
    }
    _p.style = ui.PaintingStyle.fill;
    // posts
    for (final sx in <double>[px - half, px + half - postW]) {
      c.drawRect(
          ui.Rect.fromLTWH(sx, py - ht, postW, ht),
          _p
            ..shader = ui.Gradient.linear(ui.Offset(sx, 0), ui.Offset(sx + postW, 0),
                const [ui.Color(0xFFE9EDF4), ui.Color(0xFF8A93A6), ui.Color(0xFF3B4150)])
            ..style = ui.PaintingStyle.fill);
      _p.shader = null;
    }
    // top banner
    final ban = ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTRB(px - half, py - ht - ht * 0.02, px + half, py - ht * 0.84), ui.Radius.circular(ht * 0.05));
    c.drawRRect(
        ban,
        _p
          ..shader = ui.Gradient.linear(ui.Offset(0, ban.top), ui.Offset(0, ban.bottom), [c1, c2])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    c.drawRRect(ban, _p..color = const ui.Color(0xFF101522)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, ht * 0.012));
    _p.style = ui.PaintingStyle.fill;
    // label
    final tp = _tp(label);
    final target = ht * 0.62;
    final s = target / tp.height;
    c.save();
    c.translate(px - tp.width * s / 2, py - ht * 0.52 - tp.height * s / 2);
    c.scale(s);
    tp.paint(c, ui.Offset.zero);
    c.restore();
  }

  void drawMissileTarget(ui.Canvas c, double px, double py, double r, double t01) {
    final a = (0.35 + 0.4 * math.sin(t01 * 30).abs()).clamp(0.0, 1.0).toDouble();
    final col = ui.Color.fromARGB((a * 255).round(), 255, 60, 60);
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(px, py), width: r * 2, height: r * 0.7),
        _p..color = col..style = ui.PaintingStyle.stroke..strokeWidth = math.max(2.0, r * 0.12));
    final rr = r * (0.3 + 0.7 * (1 - t01));
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(px, py), width: rr * 2, height: rr * 0.7),
        _p..color = ui.Color.fromARGB((a * 140).round(), 255, 80, 60)..style = ui.PaintingStyle.fill);
    _p.style = ui.PaintingStyle.fill;
  }

  void drawShell(ui.Canvas c, double px, double py, double r) {
    c.drawCircle(ui.Offset(px, py), r * 1.8, _p..color = const ui.Color(0x55FF8A2A)..blendMode = ui.BlendMode.plus);
    _p.blendMode = ui.BlendMode.srcOver;
    c.drawCircle(
        ui.Offset(px, py),
        r,
        _p
          ..shader = ui.Gradient.radial(ui.Offset(px - r * 0.3, py - r * 0.3), r * 1.4,
              const [ui.Color(0xFF8A8F9C), ui.Color(0xFF22252C)])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
  }

  // ---------------------------------------------------------------- base

  void drawBase(ui.Canvas c, double px, double py, double wd, double hpFrac, double flash, double time) {
    final ht = wd * 0.5;
    final u = wd / 100.0;
    drawShadow(c, px, py + u, wd * 1.05);
    // wall
    final wall = ui.Rect.fromLTWH(px - wd * 0.36, py - ht, wd * 0.72, ht);
    c.drawRect(
        wall,
        _p
          ..shader = ui.Gradient.linear(ui.Offset(0, wall.top), ui.Offset(0, wall.bottom),
              const [ui.Color(0xFFC9C0B0), ui.Color(0xFF8A8172), ui.Color(0xFF5B5448)])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    // stone lines
    final ln = _p..color = const ui.Color(0x33000000)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, u * 0.5);
    for (var i = 1; i < 5; i++) {
      final y = wall.top + wall.height * i / 5;
      c.drawLine(ui.Offset(wall.left, y), ui.Offset(wall.right, y), ln);
    }
    _p.style = ui.PaintingStyle.fill;
    // battlements
    final bw = wd * 0.72 / 11;
    for (var i = 0; i < 11; i += 2) {
      c.drawRect(ui.Rect.fromLTWH(wall.left + i * bw, wall.top - u * 6, bw, u * 6), _p..color = const ui.Color(0xFFB4AB9B));
    }
    // gate door
    final dw = wd * 0.16;
    final door = ui.Path()
      ..moveTo(px - dw, py)
      ..lineTo(px - dw, py - ht * 0.42)
      ..quadraticBezierTo(px, py - ht * 0.78, px + dw, py - ht * 0.42)
      ..lineTo(px + dw, py)
      ..close();
    c.drawPath(door, _p..color = const ui.Color(0xFF1A0E0E));
    c.drawPath(
        door,
        _p
          ..shader = ui.Gradient.radial(ui.Offset(px, py - ht * 0.2), dw * 1.3,
              const [ui.Color(0x88FF4A20), ui.Color(0x00FF4A20)])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    // emblem
    c.drawCircle(ui.Offset(px, py - ht * 0.72), u * 7, _p..color = const ui.Color(0xFF8A1118));
    c.drawCircle(ui.Offset(px, py - ht * 0.72), u * 7, _p..color = const ui.Color(0xFF1A0A0A)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, u * 0.8));
    _p.style = ui.PaintingStyle.fill;
    c.drawCircle(ui.Offset(px - u * 2.4, py - ht * 0.74), u * 1.4, _p..color = const ui.Color(0xFFFFE0C0));
    c.drawCircle(ui.Offset(px + u * 2.4, py - ht * 0.74), u * 1.4, _p..color = const ui.Color(0xFFFFE0C0));
    // towers
    for (final side in <double>[-1, 1]) {
      final tx = px + side * wd * 0.43;
      final tw = wd * 0.15;
      final th = ht * 1.5;
      final tower = ui.Rect.fromLTWH(tx - tw / 2, py - th, tw, th);
      c.drawRect(
          tower,
          _p
            ..shader = ui.Gradient.linear(ui.Offset(tower.left, 0), ui.Offset(tower.right, 0),
                const [ui.Color(0xFFD2C9B8), ui.Color(0xFF8E8576), ui.Color(0xFF574F43)])
            ..style = ui.PaintingStyle.fill);
      _p.shader = null;
      final roof = ui.Path()
        ..moveTo(tx - tw * 0.65, py - th)
        ..lineTo(tx, py - th - ht * 0.5)
        ..lineTo(tx + tw * 0.65, py - th)
        ..close();
      c.drawPath(roof, _p..color = const ui.Color(0xFFB3222A));
      c.drawPath(roof, _p..color = const ui.Color(0xFF3B0A0E)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, u * 0.7));
      _p.style = ui.PaintingStyle.fill;
      // window
      c.drawRect(ui.Rect.fromLTWH(tx - tw * 0.12, py - th * 0.7, tw * 0.24, th * 0.16), _p..color = const ui.Color(0xFF2A1A12));
      // flag
      final fy = py - th - ht * 0.5;
      c.drawLine(ui.Offset(tx, fy), ui.Offset(tx, fy - ht * 0.28), _p..color = const ui.Color(0xFF2A1A12)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, u * 0.7));
      _p.style = ui.PaintingStyle.fill;
      final wave = math.sin(time * 6 + side) * u * 1.5;
      final fl = ui.Path()
        ..moveTo(tx, fy - ht * 0.28)
        ..lineTo(tx + u * 10 + wave, fy - ht * 0.22 + wave * 0.2)
        ..lineTo(tx, fy - ht * 0.14)
        ..close();
      c.drawPath(fl, _p..color = const ui.Color(0xFFE53935));
    }
    // cannon on top
    c.drawRRect(
        ui.RRect.fromRectAndRadius(
            ui.Rect.fromCenter(center: ui.Offset(px, wall.top - u * 9), width: u * 14, height: u * 18), ui.Radius.circular(u * 5)),
        _p..color = const ui.Color(0xFF2B2F38));
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(px, wall.top - u * 17), width: u * 13, height: u * 5), _p..color = const ui.Color(0xFF0C0D10));
    // damage cracks
    if (hpFrac < 0.6) {
      final cr = _p..color = const ui.Color(0xCC1A1410)..style = ui.PaintingStyle.stroke..strokeWidth = math.max(1.0, u * 0.9);
      c.drawLine(ui.Offset(px - wd * 0.25, wall.top), ui.Offset(px - wd * 0.2, py - ht * 0.45), cr);
      c.drawLine(ui.Offset(px - wd * 0.2, py - ht * 0.45), ui.Offset(px - wd * 0.27, py - ht * 0.2), cr);
      _p.style = ui.PaintingStyle.fill;
    }
    if (hpFrac < 0.3) {
      c.drawCircle(ui.Offset(px + wd * 0.2, wall.top - u * 6), u * 7, _p..color = const ui.Color(0x66FF6A20)..blendMode = ui.BlendMode.plus);
      _p.blendMode = ui.BlendMode.srcOver;
    }
    if (flash > 0) {
      c.drawRect(wall, _p..color = ui.Color.fromARGB((flash * 5 * 255).clamp(0, 150).round(), 255, 255, 255));
    }
    drawHpBar(c, px, py - ht * 1.5 - ht * 0.75, wd * 0.7, hpFrac);
  }

  // ---------------------------------------------------------------- cannon

  void drawCannon(ui.Canvas c, double px, double py, double liftPx, double recoil, double flash) {
    final s = cam.w * 0.0026;
    c.save();
    c.translate(px, py);
    c.scale(s);

    // shadow stays on the ground
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(0, 4), width: 160, height: 32),
        _p..color = const ui.Color(0x66000000)..style = ui.PaintingStyle.fill);

    c.translate(0, -liftPx / s);

    // wheels
    for (final sx in <double>[-58.0, 58.0]) {
      final wr = ui.RRect.fromRectAndRadius(
          ui.Rect.fromCenter(center: ui.Offset(sx, -36), width: 26, height: 72), const ui.Radius.circular(11));
      c.drawRRect(
          wr,
          _p
            ..shader = ui.Gradient.linear(ui.Offset(sx - 13, 0), ui.Offset(sx + 13, 0),
                const [ui.Color(0xFF3B2412), ui.Color(0xFF9A6A3C), ui.Color(0xFF3B2412)])
            ..style = ui.PaintingStyle.fill);
      _p.shader = null;
      c.drawRRect(wr, _p..color = const ui.Color(0xFF1B1E26)..style = ui.PaintingStyle.stroke..strokeWidth = 4);
      for (var i = -2; i <= 2; i++) {
        c.drawLine(ui.Offset(sx - 11, -36 + i * 12.0), ui.Offset(sx + 11, -36 + i * 12.0),
            _p..color = const ui.Color(0x66000000)..strokeWidth = 2);
      }
      c.drawCircle(ui.Offset(sx, -36), 6, _p..color = const ui.Color(0xFF6C7380)..style = ui.PaintingStyle.fill);
    }

    // carriage
    final car = ui.Path()
      ..moveTo(-52, -4)
      ..lineTo(52, -4)
      ..lineTo(38, -62)
      ..lineTo(-38, -62)
      ..close();
    c.drawPath(
        car,
        _p
          ..shader = ui.Gradient.linear(const ui.Offset(-52, 0), const ui.Offset(52, 0),
              const [ui.Color(0xFF4B2E18), ui.Color(0xFFA8743F), ui.Color(0xFF4B2E18)], const [0.0, 0.5, 1.0])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    c.drawPath(car, _p..color = const ui.Color(0xFF1E1208)..style = ui.PaintingStyle.stroke..strokeWidth = 3);
    _p.style = ui.PaintingStyle.fill;
    c.drawRect(const ui.Rect.fromLTWH(-48, -30, 96, 8), _p..color = const ui.Color(0xFF2B2F38));

    // barrel with recoil
    final shift = recoil * 18;
    final by = -56 + shift;
    const len = 108.0;
    final barrel = ui.Path()
      ..moveTo(-30, by)
      ..lineTo(-21, by - len)
      ..lineTo(21, by - len)
      ..lineTo(30, by)
      ..close();
    c.drawPath(
        barrel,
        _p
          ..shader = ui.Gradient.linear(const ui.Offset(-30, 0), const ui.Offset(30, 0),
              const [ui.Color(0xFF12141A), ui.Color(0xFF454C59), ui.Color(0xFFA9B3C4), ui.Color(0xFF454C59), ui.Color(0xFF12141A)],
              const [0.0, 0.22, 0.42, 0.7, 1.0])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    // brass bands
    for (final f in <double>[0.28, 0.62]) {
      final y = by - len * f;
      final hw = 30 - 9 * f;
      c.drawRect(ui.Rect.fromLTRB(-hw - 1, y - 5, hw + 1, y + 5),
          _p
            ..shader = ui.Gradient.linear(ui.Offset(-hw, 0), ui.Offset(hw, 0),
                const [ui.Color(0xFF7A5410), ui.Color(0xFFFFD25A), ui.Color(0xFF7A5410)])
            ..style = ui.PaintingStyle.fill);
      _p.shader = null;
    }
    c.drawPath(barrel, _p..color = const ui.Color(0xFF0C0D10)..style = ui.PaintingStyle.stroke..strokeWidth = 3);
    _p.style = ui.PaintingStyle.fill;
    // cascabel
    c.drawCircle(
        ui.Offset(0, by + 4),
        17,
        _p
          ..shader = ui.Gradient.radial(ui.Offset(-5, by - 2), 24, const [ui.Color(0xFFB5BFCF), ui.Color(0xFF3A404D)])
          ..style = ui.PaintingStyle.fill);
    _p.shader = null;
    // muzzle
    final my = by - len;
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(0, my), width: 46, height: 16), _p..color = const ui.Color(0xFF8E98AA));
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(0, my), width: 33, height: 10), _p..color = const ui.Color(0xFF050507));

    if (flash > 0) {
      final f = (flash / 0.12).clamp(0.0, 1.0).toDouble();
      final fc = ui.Offset(0, my - 18);
      c.drawCircle(
          fc,
          70 * (0.6 + 0.4 * f),
          _p
            ..blendMode = ui.BlendMode.plus
            ..shader = ui.Gradient.radial(fc, 70, [ui.Color.fromARGB((f * 255).round(), 255, 220, 120), const ui.Color(0x00FF8A20)])
            ..style = ui.PaintingStyle.fill);
      _p.shader = null;
      _p.blendMode = ui.BlendMode.srcOver;
    }
    c.restore();
  }
}
