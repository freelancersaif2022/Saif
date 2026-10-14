import 'dart:math' as math;
import 'dart:ui' as ui;

class TroopStyle {
  final ui.Color primary;
  final ui.Color dark;
  final ui.Color metal;
  final ui.Color skin;
  final ui.Color accent;
  final int helm;
  final int weapon;
  final double bulk;
  final bool enemy;

  const TroopStyle({
    required this.primary,
    required this.dark,
    required this.metal,
    required this.skin,
    required this.accent,
    required this.helm,
    required this.weapon,
    this.bulk = 1.0,
    this.enemy = false,
  });
}

ui.Color _lighten(ui.Color c, double f) => ui.Color.lerp(c, const ui.Color(0xFFFFFFFF), f)!;
ui.Color _darken(ui.Color c, double f) => ui.Color.lerp(c, const ui.Color(0xFF000000), f)!;

class Sprites {
  static final Sprites I = Sprites._();
  Sprites._();

  static const int frames = 6;
  static const double w = 96;
  static const double h = 144;

  // 0..3 friendly troops, 4 grunt, 5 brute, 6 boss
  static const List<TroopStyle> styles = <TroopStyle>[
    TroopStyle(
        primary: ui.Color(0xFF2E7BE8), dark: ui.Color(0xFF1A4BA0), metal: ui.Color(0xFFB9C7DA),
        skin: ui.Color(0xFFF2C29B), accent: ui.Color(0xFFFFD25A), helm: 0, weapon: 0),
    TroopStyle(
        primary: ui.Color(0xFF3F8CFF), dark: ui.Color(0xFF1C3F8F), metal: ui.Color(0xFFD6DEE8),
        skin: ui.Color(0xFFEBB68C), accent: ui.Color(0xFFFFFFFF), helm: 1, weapon: 1),
    TroopStyle(
        primary: ui.Color(0xFF2459C9), dark: ui.Color(0xFF14306E), metal: ui.Color(0xFF9AA8BF),
        skin: ui.Color(0xFFD9A074), accent: ui.Color(0xFF7FD3FF), helm: 2, weapon: 2, bulk: 1.15),
    TroopStyle(
        primary: ui.Color(0xFF1F66FF), dark: ui.Color(0xFF0F2F8A), metal: ui.Color(0xFFFFD25A),
        skin: ui.Color(0xFFC98E62), accent: ui.Color(0xFFFFF1B0), helm: 3, weapon: 3, bulk: 1.05),
    TroopStyle(
        primary: ui.Color(0xFFD6353A), dark: ui.Color(0xFF7F1519), metal: ui.Color(0xFF6B6B74),
        skin: ui.Color(0xFFC9885F), accent: ui.Color(0xFFFFB347), helm: 4, weapon: 4, enemy: true),
    TroopStyle(
        primary: ui.Color(0xFFB3222A), dark: ui.Color(0xFF5E0E12), metal: ui.Color(0xFF4A4A52),
        skin: ui.Color(0xFFA96B47), accent: ui.Color(0xFFFF7A3C), helm: 5, weapon: 5, bulk: 1.2, enemy: true),
    TroopStyle(
        primary: ui.Color(0xFF8A1117), dark: ui.Color(0xFF3B0508), metal: ui.Color(0xFF2D2D33),
        skin: ui.Color(0xFF7D4A3A), accent: ui.Color(0xFFFFC94A), helm: 6, weapon: 5, bulk: 1.25, enemy: true),
  ];

  final List<List<ui.Image>> _img = <List<ui.Image>>[];

  Future<void> load() async {
    if (_img.isNotEmpty) return;
    for (var s = 0; s < styles.length; s++) {
      final list = <ui.Image>[];
      final k = s == 6 ? 2.2 : 1.5;
      for (var f = 0; f < frames; f++) {
        list.add(await _render(styles[s], f / frames, k));
      }
      _img.add(list);
    }
  }

  ui.Image get(int style, int frame) {
    final l = _img[style];
    return l[frame % frames];
  }

  Future<ui.Image> _render(TroopStyle s, double phase, double k) async {
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    c.scale(k);
    _drawHumanoid(c, s, phase);
    final pic = rec.endRecording();
    final im = await pic.toImage((w * k).ceil(), (h * k).ceil());
    pic.dispose();
    return im;
  }
}

ui.Paint _fill(ui.Color c) => ui.Paint()..color = c;

ui.Paint _stroke(ui.Color c, double wd) => ui.Paint()
  ..color = c
  ..style = ui.PaintingStyle.stroke
  ..strokeWidth = wd
  ..strokeCap = ui.StrokeCap.round
  ..strokeJoin = ui.StrokeJoin.round;

ui.Paint _lin(ui.Offset a, ui.Offset b, List<ui.Color> cs, [List<double>? st]) =>
    ui.Paint()..shader = ui.Gradient.linear(a, b, cs, st);

ui.Paint _rad(ui.Offset c, double r, List<ui.Color> cs, [List<double>? st]) =>
    ui.Paint()..shader = ui.Gradient.radial(c, r, cs, st);

const ui.Color _ink = ui.Color(0xFF14151F);

void _drawHumanoid(ui.Canvas c, TroopStyle s, double phase) {
  final ang = phase * math.pi * 2;
  final s1 = math.sin(ang);
  final s2 = -s1;
  final bob = -(math.cos(ang * 2).abs()) * 3.0;
  final b = s.bulk;
  final tl = 48 - 18 * b;
  final tr = 48 + 18 * b;

  // ground shadow
  c.drawOval(ui.Rect.fromCenter(center: const ui.Offset(48, 138), width: 58 * b, height: 13),
      _fill(const ui.Color(0x66000000)));

  c.save();
  c.translate(0, bob);

  // legs
  _leg(c, s, 48 - 9 * b, s1);
  _leg(c, s, 48 + 9 * b, s2);

  // back arm
  final lHand = _arm(c, s, tl, -1, s2);

  // torso
  final torso = ui.RRect.fromLTRBR(tl, 56, tr, 96, const ui.Radius.circular(10));
  c.drawRRect(
      torso,
      _lin(ui.Offset(tl, 56), ui.Offset(tr, 96),
          [_lighten(s.primary, 0.3), s.primary, s.dark], [0.0, 0.5, 1.0]));
  c.drawRRect(torso, _stroke(_ink, 2));

  final plate = ui.Path()
    ..moveTo(tl + 4, 60)
    ..lineTo(tr - 4, 60)
    ..lineTo(tr - 7, 84)
    ..quadraticBezierTo(48, 92, tl + 7, 84)
    ..close();
  c.drawPath(
      plate,
      _lin(ui.Offset(tl, 60), ui.Offset(tr, 86),
          [_lighten(s.metal, 0.4), s.metal, _darken(s.metal, 0.35)], [0.0, 0.5, 1.0]));
  c.drawPath(plate, _stroke(_ink, 1.4));
  c.drawCircle(const ui.Offset(48, 72), 4.2, _fill(s.accent));
  c.drawCircle(const ui.Offset(48, 72), 4.2, _stroke(_ink, 1));

  // belt
  c.drawRect(ui.Rect.fromLTRB(tl, 90, tr, 96), _fill(const ui.Color(0xFF3A271A)));
  c.drawCircle(const ui.Offset(48, 93), 3, _fill(const ui.Color(0xFFFFC94A)));

  // shoulder pads
  for (final px in <double>[tl - 1, tr + 1]) {
    c.drawCircle(
        ui.Offset(px, 62),
        9,
        _rad(ui.Offset(px - 3, 59), 12,
            [_lighten(s.metal, 0.5), s.metal, _darken(s.metal, 0.4)], [0.0, 0.5, 1.0]));
    c.drawCircle(ui.Offset(px, 62), 9, _stroke(_ink, 1.4));
  }

  // shield
  if (s.weapon == 1 || s.weapon == 3) {
    final sc = ui.Offset(lHand.dx - 3, lHand.dy - 6);
    c.drawCircle(
        sc,
        14,
        _rad(ui.Offset(sc.dx - 4, sc.dy - 4), 20,
            [_lighten(s.metal, 0.55), s.metal, _darken(s.metal, 0.45)], [0.0, 0.5, 1.0]));
    c.drawCircle(sc, 14, _stroke(_ink, 2));
    c.drawCircle(sc, 9.5, _stroke(s.accent, 2));
    c.drawLine(ui.Offset(sc.dx, sc.dy - 6), ui.Offset(sc.dx, sc.dy + 6), _stroke(s.primary, 3));
    c.drawLine(ui.Offset(sc.dx - 6, sc.dy), ui.Offset(sc.dx + 6, sc.dy), _stroke(s.primary, 3));
  }

  // front arm + weapon
  final rHand = _arm(c, s, tr, 1, s1);
  _weapon(c, s, rHand);

  // head
  const hc = ui.Offset(48, 38);
  c.drawCircle(
      hc,
      20,
      _rad(const ui.Offset(42, 31), 32,
          [_lighten(s.skin, 0.3), s.skin, _darken(s.skin, 0.3)], [0.0, 0.55, 1.0]));
  c.drawCircle(hc, 20, _stroke(_ink, 2));

  // eyes
  for (final ex in <double>[40.5, 55.5]) {
    c.drawOval(ui.Rect.fromCenter(center: ui.Offset(ex, 41), width: 8.5, height: 10),
        _fill(const ui.Color(0xFFFFFFFF)));
    c.drawCircle(ui.Offset(ex + 0.5, 42), 3.1,
        _fill(s.enemy ? const ui.Color(0xFF7A0A0A) : const ui.Color(0xFF1B2A44)));
    c.drawCircle(ui.Offset(ex + 1.2, 41), 1.1, _fill(const ui.Color(0xFFFFFFFF)));
  }
  // brows
  if (s.enemy) {
    c.drawLine(const ui.Offset(35.5, 35), const ui.Offset(45.5, 39.5), _stroke(_ink, 3));
    c.drawLine(const ui.Offset(60.5, 35), const ui.Offset(50.5, 39.5), _stroke(_ink, 3));
  } else {
    c.drawLine(const ui.Offset(36, 36.5), const ui.Offset(45, 35.5), _stroke(_ink, 2.4));
    c.drawLine(const ui.Offset(51, 35.5), const ui.Offset(60, 36.5), _stroke(_ink, 2.4));
  }
  // nose
  c.drawCircle(const ui.Offset(48, 46), 2.3, _fill(_darken(s.skin, 0.18)));
  // mouth
  if (s.enemy) {
    final m = ui.RRect.fromRectAndRadius(
        ui.Rect.fromCenter(center: const ui.Offset(48, 52), width: 15, height: 7), const ui.Radius.circular(2));
    c.drawRRect(m, _fill(const ui.Color(0xFF3B0A0A)));
    c.drawRect(ui.Rect.fromLTWH(41, 48.8, 14, 2.4), _fill(const ui.Color(0xFFFFFFFF)));
    c.drawRect(ui.Rect.fromLTWH(43, 54, 10, 1.8), _fill(const ui.Color(0xFFFFFFFF)));
    c.drawRRect(m, _stroke(_ink, 1.2));
  } else {
    c.drawArc(ui.Rect.fromCenter(center: const ui.Offset(48, 49), width: 13, height: 9), 0.25,
        math.pi - 0.5, false, _stroke(_ink, 2.2));
  }

  _helmet(c, s);
  c.restore();
}

void _leg(ui.Canvas c, TroopStyle s, double hx, double sw) {
  final lift = math.max(0.0, sw) * 9;
  final fx = hx + sw * 5;
  final fy = 131 - lift;
  c.drawLine(ui.Offset(hx, 92), ui.Offset(fx, fy - 6), _stroke(_darken(s.dark, 0.25), 12));
  c.drawOval(ui.Rect.fromCenter(center: ui.Offset(fx, fy), width: 18, height: 11),
      _fill(const ui.Color(0xFF2B1D14)));
  c.drawOval(ui.Rect.fromCenter(center: ui.Offset(fx - 2, fy - 2), width: 8, height: 4),
      _fill(const ui.Color(0x44FFFFFF)));
}

ui.Offset _arm(ui.Canvas c, TroopStyle s, double sx, double side, double sw) {
  final hx = sx + side * 6;
  final hy = 91 + sw * 6;
  c.drawLine(ui.Offset(sx, 66), ui.Offset(hx, hy), _stroke(s.primary, 12));
  c.drawLine(ui.Offset(sx, 66), ui.Offset((sx + hx) / 2, (66 + hy) / 2), _stroke(s.dark, 12));
  c.drawCircle(ui.Offset(hx, hy), 5.8, _fill(s.skin));
  c.drawCircle(ui.Offset(hx, hy), 5.8, _stroke(_ink, 1.2));
  return ui.Offset(hx, hy);
}

void _weapon(ui.Canvas c, TroopStyle s, ui.Offset hnd) {
  switch (s.weapon) {
    case 0:
    case 1:
      final tip = ui.Offset(hnd.dx + 7, hnd.dy - 42);
      c.drawLine(hnd, tip, _stroke(_ink, 7));
      c.drawLine(hnd, tip, _stroke(const ui.Color(0xFFDCE6F2), 4.5));
      c.drawLine(ui.Offset(hnd.dx + 0.5, hnd.dy - 4), ui.Offset(tip.dx - 0.5, tip.dy + 4), _stroke(const ui.Color(0xFFFFFFFF), 1.4));
      c.drawLine(ui.Offset(hnd.dx - 7, hnd.dy - 6), ui.Offset(hnd.dx + 7, hnd.dy - 3), _stroke(const ui.Color(0xFFFFC94A), 3.5));
      break;
    case 2:
      final top = ui.Offset(hnd.dx + 6, hnd.dy - 36);
      c.drawLine(hnd, top, _stroke(const ui.Color(0xFF5A3A20), 5.5));
      final head = ui.RRect.fromRectAndRadius(
          ui.Rect.fromCenter(center: ui.Offset(top.dx, top.dy - 4), width: 26, height: 15),
          const ui.Radius.circular(3));
      c.drawRRect(
          head,
          _lin(ui.Offset(top.dx - 13, top.dy - 12), ui.Offset(top.dx + 13, top.dy + 4),
              [const ui.Color(0xFFE5ECF5), const ui.Color(0xFF8F9BAE), const ui.Color(0xFF4F5868)]));
      c.drawRRect(head, _stroke(_ink, 1.8));
      break;
    case 3:
      final top = ui.Offset(hnd.dx + 6, hnd.dy - 40);
      c.drawLine(hnd, top, _stroke(const ui.Color(0xFF8A5A22), 4.5));
      final blade = ui.Path()
        ..moveTo(top.dx, top.dy + 4)
        ..quadraticBezierTo(top.dx + 22, top.dy - 6, top.dx + 10, top.dy - 20)
        ..quadraticBezierTo(top.dx + 6, top.dy - 10, top.dx, top.dy - 8)
        ..close();
      c.drawPath(
          blade,
          _lin(ui.Offset(top.dx, top.dy), ui.Offset(top.dx + 20, top.dy - 18),
              [const ui.Color(0xFFFFF1B0), const ui.Color(0xFFFFC94A), const ui.Color(0xFFB8821A)]));
      c.drawPath(blade, _stroke(_ink, 1.8));
      break;
    case 4:
      final top = ui.Offset(hnd.dx + 8, hnd.dy - 34);
      c.drawLine(hnd, top, _stroke(_ink, 10));
      c.drawLine(hnd, top, _stroke(const ui.Color(0xFF7A4B26), 7));
      for (final p in <double>[0.55, 0.75, 0.95]) {
        final sp = ui.Offset(hnd.dx + (top.dx - hnd.dx) * p + 4, hnd.dy + (top.dy - hnd.dy) * p);
        c.drawCircle(sp, 2.2, _fill(const ui.Color(0xFFC9CED8)));
      }
      break;
    default:
      final top = ui.Offset(hnd.dx + 8, hnd.dy - 46);
      c.drawLine(ui.Offset(hnd.dx - 2, hnd.dy + 6), top, _stroke(const ui.Color(0xFF3A2414), 5.5));
      final blade = ui.Path()
        ..moveTo(top.dx, top.dy + 10)
        ..quadraticBezierTo(top.dx + 28, top.dy + 4, top.dx + 16, top.dy - 20)
        ..quadraticBezierTo(top.dx + 8, top.dy - 8, top.dx, top.dy - 4)
        ..close();
      c.drawPath(
          blade,
          _lin(ui.Offset(top.dx, top.dy), ui.Offset(top.dx + 24, top.dy - 16),
              [const ui.Color(0xFFB9C0CC), const ui.Color(0xFF626A78), const ui.Color(0xFF2B2F38)]));
      c.drawPath(blade, _stroke(_ink, 1.8));
      break;
  }
}

void _helmet(ui.Canvas c, TroopStyle s) {
  final isEnemy = s.enemy;
  final base = isEnemy ? _darken(s.metal, 0.1) : s.metal;

  // decorations behind dome
  switch (s.helm) {
    case 4:
      for (final side in <double>[-1, 1]) {
        final hornP = ui.Path()
          ..moveTo(48 + side * 19, 30)
          ..quadraticBezierTo(48 + side * 34, 24, 48 + side * 32, 8)
          ..quadraticBezierTo(48 + side * 24, 20, 48 + side * 11, 22)
          ..close();
        c.drawPath(hornP, _fill(const ui.Color(0xFFEFE4CC)));
        c.drawPath(hornP, _stroke(_ink, 1.6));
      }
      break;
    case 6:
      for (final side in <double>[-1, 1]) {
        final hornP = ui.Path()
          ..moveTo(48 + side * 20, 32)
          ..quadraticBezierTo(48 + side * 44, 28, 48 + side * 40, 2)
          ..quadraticBezierTo(48 + side * 28, 20, 48 + side * 10, 22)
          ..close();
        c.drawPath(
            hornP,
            _lin(ui.Offset(48 + side * 20, 30), ui.Offset(48 + side * 40, 2),
                [const ui.Color(0xFF3B2A22), const ui.Color(0xFFEFE4CC)]));
        c.drawPath(hornP, _stroke(_ink, 1.8));
      }
      break;
    case 3:
      for (final side in <double>[-1, 1]) {
        final wing = ui.Path()
          ..moveTo(48 + side * 14, 24)
          ..lineTo(48 + side * 36, 6)
          ..lineTo(48 + side * 30, 20)
          ..lineTo(48 + side * 38, 18)
          ..lineTo(48 + side * 24, 32)
          ..close();
        c.drawPath(wing, _fill(const ui.Color(0xFFFFF1B0)));
        c.drawPath(wing, _stroke(_ink, 1.5));
      }
      break;
    default:
      break;
  }

  final dome = ui.Path()
    ..moveTo(26, 38)
    ..arcTo(ui.Rect.fromCircle(center: const ui.Offset(48, 38), radius: 22), math.pi, math.pi, false)
    ..quadraticBezierTo(48, 29, 26, 38)
    ..close();
  c.drawPath(
      dome,
      _lin(const ui.Offset(26, 16), const ui.Offset(70, 40),
          [_lighten(base, 0.5), base, _darken(base, 0.45)], [0.0, 0.45, 1.0]));
  c.drawPath(dome, _stroke(_ink, 2));
  final rim = ui.Path()
    ..moveTo(26, 38)
    ..quadraticBezierTo(48, 29, 70, 38);
  c.drawPath(rim, _stroke(s.accent, 3.2));

  switch (s.helm) {
    case 0:
      final plume = ui.Path()
        ..moveTo(44, 17)
        ..quadraticBezierTo(48, 4, 56, 12)
        ..quadraticBezierTo(50, 12, 52, 18)
        ..close();
      c.drawPath(plume, _fill(s.primary));
      c.drawPath(plume, _stroke(_ink, 1.4));
      break;
    case 1:
      c.drawRect(ui.Rect.fromLTWH(46.5, 34, 3, 12), _fill(s.metal));
      c.drawRect(ui.Rect.fromLTWH(46.5, 34, 3, 12), _stroke(_ink, 1));
      final plume = ui.Path()
        ..moveTo(40, 18)
        ..quadraticBezierTo(46, -2, 68, 4)
        ..quadraticBezierTo(54, 8, 56, 18)
        ..close();
      c.drawPath(plume, _fill(s.primary));
      c.drawPath(plume, _stroke(_ink, 1.4));
      break;
    case 2:
      for (final side in <double>[-1, 1]) {
        final cheek = ui.RRect.fromRectAndRadius(
            ui.Rect.fromLTWH(side < 0 ? 24.5 : 65.5, 36, 6, 18), const ui.Radius.circular(3));
        c.drawRRect(cheek, _fill(s.metal));
        c.drawRRect(cheek, _stroke(_ink, 1.3));
      }
      c.drawRect(ui.Rect.fromLTWH(44, 12, 8, 14), _fill(s.primary));
      c.drawRect(ui.Rect.fromLTWH(44, 12, 8, 14), _stroke(_ink, 1.3));
      break;
    case 3:
      c.drawCircle(const ui.Offset(48, 24), 4, _fill(const ui.Color(0xFF52D0FF)));
      c.drawCircle(const ui.Offset(48, 24), 4, _stroke(_ink, 1.2));
      break;
    case 5:
      for (final px in <double>[36, 48, 60]) {
        final sp = ui.Path()
          ..moveTo(px - 4, 22)
          ..lineTo(px, 9)
          ..lineTo(px + 4, 22)
          ..close();
        c.drawPath(sp, _fill(const ui.Color(0xFFC9CED8)));
        c.drawPath(sp, _stroke(_ink, 1.3));
      }
      break;
    case 6:
      final crown = ui.Path()
        ..moveTo(33, 22)
        ..lineTo(36, 8)
        ..lineTo(42, 18)
        ..lineTo(48, 5)
        ..lineTo(54, 18)
        ..lineTo(60, 8)
        ..lineTo(63, 22)
        ..close();
      c.drawPath(crown, _fill(const ui.Color(0xFFFFC94A)));
      c.drawPath(crown, _stroke(_ink, 1.6));
      c.drawCircle(const ui.Offset(48, 16), 2.6, _fill(const ui.Color(0xFFFF3B3B)));
      break;
    default:
      break;
  }
}
