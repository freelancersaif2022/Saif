import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../entities/enemy.dart';
import '../entities/player.dart';
import '../game/amadan_game.dart';
import '../game/hud_layout.dart';
import '../systems/battle_map.dart';
import 'minimap_builder.dart';

/// Lays out a text once and re-lays it out only when the string changes.
class CachedText {
  CachedText(this.style);

  TextStyle style;
  String _text = '';
  TextPainter? _painter;

  TextPainter painter(String text) {
    final existing = _painter;
    if (existing != null && text == _text) return existing;
    existing?.dispose();
    _text = text;
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    _painter = tp;
    return tp;
  }

  /// Paints [text] with its left edge at x (alignX 0), centre (0.5) or right (1).
  Size paint(Canvas canvas, String text, Offset at, {double alignX = 0, double alignY = 0}) {
    final tp = painter(text);
    tp.paint(canvas, Offset(at.dx - tp.width * alignX, at.dy - tp.height * alignY));
    return tp.size;
  }

  void dispose() {
    _painter?.dispose();
    _painter = null;
  }
}

/// Screen-space heads-up display: vitals, score, mini-map, ammo, boss bar
/// and wave banners.
class HudComponent extends Component with HasGameReference<AmadanGame> {
  HudComponent(this.minimap) : super(priority: 20);

  final ui.Image minimap;

  static const double _mapViewRadius = 1150;

  final Paint _panel = Paint()..color = const Color(0x8C0A0C0E);
  final Paint _panelEdge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = const Color(0x55E0C8A0);
  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;
  final Paint _imagePaint = Paint()..filterQuality = FilterQuality.low;

  final CachedText _hpText = CachedText(const TextStyle(color: Color(0xFFF2EBDD), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2));
  final CachedText _scoreText = CachedText(const TextStyle(color: Color(0xFFFFD27A), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0));
  final CachedText _infoText = CachedText(const TextStyle(color: Color(0xFFD8D0C0), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4));
  final CachedText _ammoText = CachedText(const TextStyle(color: Color(0xFFF6F0E2), fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 0.5));
  final CachedText _magText = CachedText(const TextStyle(color: Color(0xFFB8AE9C), fontSize: 13, fontWeight: FontWeight.w700));
  final CachedText _weaponText = CachedText(const TextStyle(color: Color(0xFFD8CDB8), fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.6));
  final CachedText _reloadText = CachedText(const TextStyle(color: Color(0xFFFFB050), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2));
  final CachedText _bossText = CachedText(const TextStyle(color: Color(0xFFFF8A6A), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3));
  final CachedText _bannerText = CachedText(const TextStyle(color: Color(0xFFF4E6C8), fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 6, shadows: [Shadow(color: Color(0xFF000000), blurRadius: 10)]));
  final CachedText _bannerWarn = CachedText(const TextStyle(color: Color(0xFFFF5A3A), fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 5, shadows: [Shadow(color: Color(0xFF000000), blurRadius: 10)]));
  final CachedText _northText = CachedText(const TextStyle(color: Color(0xFFE8DCC0), fontSize: 10, fontWeight: FontWeight.w900));

  @override
  void onRemove() {
    for (final t in [_hpText, _scoreText, _infoText, _ammoText, _magText, _weaponText, _reloadText, _bossText, _bannerText, _bannerWarn, _northText]) {
      t.dispose();
    }
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final g = game;
    if (!g.isReady) return;
    final layout = HudLayout(Size(g.size.x, g.size.y), g.safeInsets);
    _drawStatus(canvas, layout);
    _drawMinimap(canvas, layout);
    if (g.phase == GamePhase.playing) {
      _drawAmmo(canvas, layout);
    }
    _drawBossBar(canvas, layout);
    _drawBanner(canvas, layout);
  }

  void _panelRect(Canvas canvas, Rect r, double radius) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(radius));
    canvas.drawRRect(rr, _panel);
    canvas.drawRRect(rr, _panelEdge);
  }

  void _drawStatus(Canvas canvas, HudLayout l) {
    final g = game;
    final p = g.player;
    final r = l.statusPanel;
    _panelRect(canvas, r, 8);
    final pad = r.height * 0.12;
    final barH = math.max(9.0, r.height * 0.15);
    final iconS = barH * 1.25;
    final x0 = r.left + pad;
    final barX = x0 + iconS + 7;
    final barW = r.right - pad - barX;
    var y = r.top + pad;

    // Health icon: a cross.
    _fill.color = const Color(0xFFE04A36);
    final ic = Offset(x0 + iconS / 2, y + barH / 2);
    canvas.drawRect(Rect.fromCenter(center: ic, width: iconS, height: iconS * 0.34), _fill);
    canvas.drawRect(Rect.fromCenter(center: ic, width: iconS * 0.34, height: iconS), _fill);

    final hpT = (p.hp / Player.maxHp).clamp(0.0, 1.0);
    final dispT = (p.displayHp / Player.maxHp).clamp(0.0, 1.0);
    final bg = RRect.fromRectAndRadius(Rect.fromLTWH(barX, y, barW, barH), const Radius.circular(3));
    _fill.color = const Color(0xCC1A1A1A);
    canvas.drawRRect(bg, _fill);
    if (dispT > hpT) {
      _fill.color = const Color(0xCCF0E0C0);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(barX, y, barW * dispT, barH), const Radius.circular(3)), _fill);
    }
    final low = hpT < 0.3;
    final pulse = low ? 0.75 + 0.25 * math.sin(g.session.time * 9) : 1.0;
    final hpColor = Color.lerp(const Color(0xFFD8341E), const Color(0xFF6CC04A), ((hpT - 0.2) / 0.6).clamp(0.0, 1.0))!;
    _fill.color = hpColor.withAlpha((255 * pulse).round());
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(barX, y, barW * hpT, barH), const Radius.circular(3)), _fill);
    _fill.color = const Color(0x33FFFFFF);
    canvas.drawRect(Rect.fromLTWH(barX + 2, y + 1.5, math.max(0.0, barW * hpT - 4), barH * 0.28), _fill);
    _hpText.paint(canvas, '${p.hp.ceil()}', Offset(barX + barW - 4, y + barH / 2), alignX: 1, alignY: 0.5);

    y += barH + pad * 0.7;
    final stH = math.max(5.0, barH * 0.5);
    _fill.color = const Color(0xFF58A8E0);
    final sc = Offset(x0 + iconS / 2, y + stH / 2);
    final arrow = Path()
      ..moveTo(sc.dx - iconS * 0.45, sc.dy + stH * 0.6)
      ..lineTo(sc.dx, sc.dy - stH * 0.9)
      ..lineTo(sc.dx + iconS * 0.45, sc.dy + stH * 0.6)
      ..close();
    canvas.drawPath(arrow, _fill);
    _fill.color = const Color(0xCC1A1A1A);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(barX, y, barW, stH), const Radius.circular(2)), _fill);
    final stT = p.stamina.clamp(0.0, 1.0);
    _fill.color = p.sprinting ? const Color(0xFF7CD0FF) : (stT < 0.15 ? const Color(0xFF8A6A4A) : const Color(0xFF4A94C8));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(barX, y, barW * stT, stH), const Radius.circular(2)), _fill);

    y += stH + pad * 0.8;
    final s = g.session;
    final scoreSize = _scoreText.paint(canvas, 'SCORE ${s.score}', Offset(x0, y));
    _infoText.paint(canvas, 'WAVE ${s.level}   KILLS ${s.kills}', Offset(x0, y + scoreSize.height));
  }

  void _drawMinimap(Canvas canvas, HudLayout l) {
    final g = game;
    final r = l.minimap;
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(10));
    canvas.save();
    canvas.clipRRect(rr);
    _fill.color = const Color(0xFF14160F);
    canvas.drawRect(r, _fill);
    final p = g.player;
    final k = r.width / (_mapViewRadius * 2);
    final c = r.center;
    // Static layer.
    final imgScale = minimapImageSize / BattleMap.size;
    final srcLeft = (p.x - _mapViewRadius) * imgScale;
    final srcTop = (p.y - _mapViewRadius) * imgScale;
    final srcSize = _mapViewRadius * 2 * imgScale;
    _imagePaint.color = const Color(0xE6FFFFFF);
    final full = Rect.fromLTWH(srcLeft, srcTop, srcSize, srcSize);
    final src = full.intersect(Rect.fromLTWH(0, 0, minimap.width.toDouble(), minimap.height.toDouble()));
    if (src.width > 0 && src.height > 0) {
      final sx = r.width / srcSize;
      final dst = Rect.fromLTRB(
        r.left + (src.left - full.left) * sx,
        r.top + (src.top - full.top) * sx,
        r.left + (src.right - full.left) * sx,
        r.top + (src.bottom - full.top) * sx,
      );
      canvas.drawImageRect(minimap, src, dst, _imagePaint);
    }

    // Grid and view cone.
    _stroke
      ..strokeWidth = 1
      ..color = const Color(0x22FFFFFF);
    canvas.drawLine(Offset(c.dx, r.top), Offset(c.dx, r.bottom), _stroke);
    canvas.drawLine(Offset(r.left, c.dy), Offset(r.right, c.dy), _stroke);
    final cone = Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx - r.width * 0.45, r.top)
      ..lineTo(c.dx + r.width * 0.45, r.top)
      ..close();
    _fill.color = const Color(0x14FFF0C0);
    canvas.drawPath(cone, _fill);

    // Pickups.
    for (final pk in g.pickups) {
      if (!pk.active) continue;
      final o = Offset(c.dx + (pk.x - p.x) * k, c.dy + (pk.y - p.y) * k);
      if (!r.inflate(-2).contains(o)) continue;
      _fill.color = const Color(0xFF6CE07A);
      canvas.drawRect(Rect.fromCenter(center: o, width: 5, height: 5), _fill);
    }

    // Enemies.
    final t = g.session.time;
    for (final e in g.director.pool) {
      if (!e.active || !e.alive) continue;
      var o = Offset(c.dx + (e.x - p.x) * k, c.dy + (e.y - p.y) * k);
      final inside = r.deflate(4).contains(o);
      if (!inside) {
        if (!e.isBoss) continue;
        o = Offset(o.dx.clamp(r.left + 6, r.right - 6), o.dy.clamp(r.top + 6, r.bottom - 6));
      }
      if (e.isBoss) {
        final pulse = 4.5 + 1.8 * math.sin(t * 6);
        _fill.color = const Color(0x66FF2A1A);
        canvas.drawCircle(o, pulse + 3, _fill);
        _fill.color = const Color(0xFFFF3A22);
        canvas.drawCircle(o, pulse, _fill);
      } else {
        _fill.color = e.engaging ? const Color(0xFFFF4A32) : const Color(0xFFE08A5A);
        canvas.drawCircle(o, e.spec.kind == EnemyKind.heavy ? 3.6 : 2.8, _fill);
      }
    }

    // Player arrow.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(p.pose.facing + math.pi / 2);
    final arrow = Path()
      ..moveTo(0, -7)
      ..lineTo(5, 5)
      ..lineTo(0, 2.5)
      ..lineTo(-5, 5)
      ..close();
    _fill.color = const Color(0xFFFFFFFF);
    canvas.drawPath(arrow, _fill);
    canvas.restore();
    canvas.restore();

    canvas.drawRRect(rr, _panelEdge);
    _stroke
      ..strokeWidth = 2
      ..color = const Color(0x66000000);
    canvas.drawRRect(rr.deflate(1), _stroke);
    // North marker.
    _fill.color = const Color(0xCC0A0C0E);
    final nc = Offset(c.dx, r.top + 9);
    canvas.drawCircle(nc, 7.5, _fill);
    _northText.paint(canvas, 'N', nc, alignX: 0.5, alignY: 0.5);
  }

  void _drawAmmo(Canvas canvas, HudLayout l) {
    final g = game;
    final w = g.player.weapon;
    final r = l.ammoPanel;
    _panelRect(canvas, r, 8);
    final pad = r.height * 0.14;
    _weaponText.paint(canvas, w.spec.name.toUpperCase(), Offset(r.left + pad, r.top + pad * 0.6));
    final ammoSize = _ammoText.paint(canvas, '${w.ammo}', Offset(r.left + pad, r.bottom - pad * 0.4), alignY: 1);
    _magText.paint(canvas, '/ ${w.spec.magazine}', Offset(r.left + pad + ammoSize.width + 6, r.bottom - pad * 0.9), alignY: 1);

    // Round pips.
    final pipArea = Rect.fromLTRB(r.left + r.width * 0.58, r.top + r.height * 0.42, r.right - pad, r.bottom - pad);
    final n = w.spec.magazine;
    final cols = n > 10 ? 10 : n;
    final rows = (n / cols).ceil();
    final pw = pipArea.width / cols;
    final ph = pipArea.height / rows;
    for (var i = 0; i < n; i++) {
      final cx = pipArea.left + (i % cols) * pw;
      final cy = pipArea.top + (i ~/ cols) * ph;
      _fill.color = i < w.ammo ? const Color(0xFFE8C878) : const Color(0x33FFFFFF);
      canvas.drawRect(Rect.fromLTWH(cx + pw * 0.2, cy + ph * 0.15, pw * 0.6, ph * 0.7), _fill);
    }

    if (w.reloading) {
      final barRect = Rect.fromLTWH(r.left, r.top - 9, r.width, 5);
      _fill.color = const Color(0xAA000000);
      canvas.drawRect(barRect, _fill);
      _fill.color = const Color(0xFFFFB050);
      canvas.drawRect(Rect.fromLTWH(barRect.left, barRect.top, barRect.width * w.reloadProgress, barRect.height), _fill);
      _reloadText.paint(canvas, 'RELOADING', Offset(r.center.dx, barRect.top - 3), alignX: 0.5, alignY: 1);
    } else if (w.ammo == 0) {
      _reloadText.paint(canvas, 'NO AMMO', Offset(r.center.dx, r.top - 5), alignX: 0.5, alignY: 1);
    }
  }

  void _drawBossBar(Canvas canvas, HudLayout l) {
    final boss = game.director.boss;
    if (boss == null || !boss.active || !boss.alive) return;
    final w = math.min(l.size.width * 0.38, l.minimap.left - l.statusPanel.right - 40);
    if (w < 80) return;
    final cx = (l.statusPanel.right + l.pauseButton.left) / 2;
    final top = l.top + 4;
    final nameSize = _bossText.paint(canvas, 'WARLORD', Offset(cx, top), alignX: 0.5);
    final bar = Rect.fromLTWH(cx - w / 2, top + nameSize.height + 3, w, 10);
    _fill.color = const Color(0xCC120808);
    canvas.drawRRect(RRect.fromRectAndRadius(bar.inflate(2), const Radius.circular(3)), _fill);
    final t = (boss.hp / boss.maxHp).clamp(0.0, 1.0);
    final pulse = boss.critical ? 0.7 + 0.3 * math.sin(game.session.time * 10) : 1.0;
    _fill.color = Color.fromRGBO(220, 40, 26, pulse);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bar.left, bar.top, bar.width * t, bar.height), const Radius.circular(2)), _fill);
    _fill.color = const Color(0x40FFFFFF);
    canvas.drawRect(Rect.fromLTWH(bar.left, bar.top + 1, bar.width * t, 3), _fill);
    _stroke
      ..strokeWidth = 1
      ..color = const Color(0x88FF6A4A);
    canvas.drawRRect(RRect.fromRectAndRadius(bar.inflate(2), const Radius.circular(3)), _stroke);
  }

  void _drawBanner(Canvas canvas, HudLayout l) {
    final g = game;
    if (g.bannerTime <= 0 || g.banner.isEmpty) return;
    final t = g.bannerTime;
    final a = (t > 2.2 ? (2.6 - t) / 0.4 : (t < 0.6 ? t / 0.6 : 1.0)).clamp(0.0, 1.0);
    final ct = g.bannerWarning ? _bannerWarn : _bannerText;
    final tp = ct.painter(g.banner);
    final scale = (l.size.width * 0.7 / tp.width).clamp(0.5, 1.2);
    final c = Offset(l.size.width / 2, l.size.height * 0.3);
    final bandH = tp.height * scale + 18;
    _fill.color = Color.fromRGBO(0, 0, 0, 0.45 * a);
    canvas.drawRect(Rect.fromCenter(center: c, width: l.size.width, height: bandH), _fill);
    _fill.color = g.bannerWarning ? Color.fromRGBO(255, 60, 30, 0.8 * a) : Color.fromRGBO(230, 180, 110, 0.7 * a);
    canvas.drawRect(Rect.fromCenter(center: c - Offset(0, bandH / 2), width: l.size.width * 0.5 * a, height: 2), _fill);
    canvas.drawRect(Rect.fromCenter(center: c + Offset(0, bandH / 2), width: l.size.width * 0.5 * a, height: 2), _fill);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale, scale);
    canvas.saveLayer(
      Rect.fromCenter(center: Offset.zero, width: tp.width + 40, height: tp.height + 40),
      Paint()..color = Color.fromRGBO(255, 255, 255, a),
    );
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
    canvas.restore();
  }
}
