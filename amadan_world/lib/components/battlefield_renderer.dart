import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' hide TextStyle;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;

import '../entities/enemy.dart';
import '../entities/projectiles.dart';
import '../entities/soldier_rig.dart';
import '../game/amadan_game.dart';
import '../systems/battle_map.dart';
import '../systems/projection.dart';
import '../utils/asset_paths.dart';
import '../utils/image_store.dart';
import '../utils/math_utils.dart';
import '../weapons/weapon_data.dart';

/// Reusable vertex buffers for textured / colored triangle batches.
class _Mesh {
  _Mesh(this.capacity)
      : pos = Float32List(capacity * 2),
        tex = Float32List(capacity * 2),
        col = Int32List(capacity);

  final int capacity;
  final Float32List pos;
  final Float32List tex;
  final Int32List col;
  int n = 0;

  void reset() => n = 0;

  bool hasRoom(int k) => n + k <= capacity;

  void vert(double x, double y, double u, double v, int c) {
    if (n >= capacity) return;
    final i = n * 2;
    pos[i] = x;
    pos[i + 1] = y;
    tex[i] = u;
    tex[i + 1] = v;
    col[n] = c;
    n++;
  }

  void drawTextured(Canvas canvas, Paint paint) {
    if (n < 3) return;
    final count = n - n % 3;
    final v = ui.Vertices.raw(
      VertexMode.triangles,
      Float32List.sublistView(pos, 0, count * 2),
      textureCoordinates: Float32List.sublistView(tex, 0, count * 2),
    );
    canvas.drawVertices(v, BlendMode.srcOver, paint);
    v.dispose();
  }

  void drawColored(Canvas canvas, Paint paint) {
    if (n < 3) return;
    final count = n - n % 3;
    final v = ui.Vertices.raw(
      VertexMode.triangles,
      Float32List.sublistView(pos, 0, count * 2),
      colors: Int32List.sublistView(col, 0, count),
    );
    canvas.drawVertices(v, BlendMode.dst, paint);
    v.dispose();
  }
}

class _Item {
  double key = 0;
  int type = 0;
  int index = 0;
}

const int _tBox = 0;
const int _tProp = 1;
const int _tPlayer = 2;
const int _tEnemy = 3;
const int _tPickup = 4;

class _Material {
  _Material(this.wall, this.top, this.wallScale, this.topScale, this.sideShade);

  final Paint wall;
  final Paint top;
  final double wallScale;
  final double topScale;
  final double sideShade;
}

/// Renders the whole 3D-projected battlefield: sky, perspective ground,
/// roads, decals, depth-sorted blocks / props / soldiers, effects and tracers.
class BattlefieldRenderer extends Component with HasGameReference<AmadanGame> {
  BattlefieldRenderer() : super(priority: 0);

  static const int _rows = 24;
  static const int _cols = 16;
  static const Color haze = Color(0xFF4E3828);
  static const int _hazeR = 0x4E;
  static const int _hazeG = 0x38;
  static const int _hazeB = 0x28;

  static final Float64List _identity = Float64List.fromList(<double>[
    1, 0, 0, 0, //
    0, 1, 0, 0, //
    0, 0, 1, 0, //
    0, 0, 0, 1, //
  ]);

  late final Image _skyline;
  late final Paint _groundPaint;
  late final Paint _roadPaint;
  late final Paint _craterPaint;
  late final Map<BoxMaterial, _Material> _materials;
  late final Map<PropKind, Image> _propImages;
  late final Map<PropKind, Rect> _propSrc;

  final _Mesh _groundMesh = _Mesh((_rows) * (_cols) * 6 + 12);
  final _Mesh _mesh = _Mesh(4096);
  final Paint _colorPaint = Paint();
  final Paint _spritePaint = Paint()..filterQuality = FilterQuality.low;
  final List<Paint> _fogPaints = <Paint>[];
  final Paint _shadowPaint = Paint()..color = const Color(0x5A000000);
  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round;
  final Paint _tracerGlow = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..blendMode = BlendMode.plus;
  final Paint _tracerCore = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..blendMode = BlendMode.plus;
  Paint? _skyPaint;
  double _skyForH = -1;

  final Float64List _gsx = Float64List((_rows + 1) * (_cols + 1));
  final Float64List _gsy = Float64List((_rows + 1) * (_cols + 1));
  final Float64List _gwx = Float64List((_rows + 1) * (_cols + 1));
  final Float64List _gwy = Float64List((_rows + 1) * (_cols + 1));
  final Float64List _gfog = Float64List(_rows + 1);

  final List<_Item> _itemPool = List<_Item>.generate(1400, (_) => _Item());
  final List<_Item> _items = <_Item>[];
  int _itemCount = 0;

  final Map<int, TextPainter> _popupText = <int, TextPainter>{};
  TextPainter? _headshotText;

  @override
  Future<void> onLoad() async {
    _skyline = ImageStore.get(AssetPaths.skyline);
    _groundPaint = _texturePaint(ImageStore.get(AssetPaths.groundDirt));
    _roadPaint = _texturePaint(ImageStore.get(AssetPaths.groundRoad));
    _craterPaint = _texturePaint(ImageStore.get(AssetPaths.crater), clamp: true);
    final wall = _texturePaint(ImageStore.get(AssetPaths.wallRuin));
    final roof = _texturePaint(ImageStore.get(AssetPaths.roof));
    final sandbag = _texturePaint(ImageStore.get(AssetPaths.sandbag));
    final concrete = _texturePaint(ImageStore.get(AssetPaths.concrete));
    final crate = _texturePaint(ImageStore.get(AssetPaths.crate));
    _materials = <BoxMaterial, _Material>{
      BoxMaterial.building: _Material(wall, roof, 256 / 110, 256 / 220, 0.42),
      BoxMaterial.sandbag: _Material(sandbag, sandbag, 2.0, 2.0, 0.36),
      BoxMaterial.concrete: _Material(concrete, concrete, 1.6, 1.6, 0.36),
      BoxMaterial.crate: _Material(crate, crate, 128 / 46, 128 / 46, 0.4),
    };
    _propImages = <PropKind, Image>{
      PropKind.tree: ImageStore.get(AssetPaths.tree),
      PropKind.deadTree: ImageStore.get(AssetPaths.treeDead),
      PropKind.rock: ImageStore.get(AssetPaths.rock),
      PropKind.tankWreck: ImageStore.get(AssetPaths.tankWreck),
      PropKind.truckWreck: ImageStore.get(AssetPaths.truckWreck),
      PropKind.hedgehog: ImageStore.get(AssetPaths.hedgehog),
      PropKind.barrel: ImageStore.get(AssetPaths.barrel),
      PropKind.debris: ImageStore.get(AssetPaths.debris),
    };
    _propSrc = _propImages.map((k, img) =>
        MapEntry(k, Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble())));
    for (var i = 0; i < 8; i++) {
      final a = (i / 7 * 200).round();
      final p = Paint()..filterQuality = FilterQuality.low;
      if (a > 0) {
        p.colorFilter = ColorFilter.mode(haze.withAlpha(a), BlendMode.srcATop);
      }
      _fogPaints.add(p);
    }
  }

  @override
  void onRemove() {
    for (final tp in _popupText.values) {
      tp.dispose();
    }
    _popupText.clear();
    _headshotText?.dispose();
    _headshotText = null;
    super.onRemove();
  }

  Paint _texturePaint(Image image, {bool clamp = false}) {
    final mode = clamp ? TileMode.clamp : TileMode.repeated;
    return Paint()
      ..filterQuality = FilterQuality.low
      ..shader = ImageShader(image, mode, mode, _identity);
  }

  @override
  void render(Canvas canvas) {
    final g = game;
    if (!g.isReady) return;
    final proj = g.proj;
    canvas.save();
    canvas.translate(g.shakeX, g.shakeY);
    _drawSky(canvas, proj);
    _drawGround(canvas, proj);
    _drawTelegraphs(canvas, proj);
    _collect(proj);
    _drawItems(canvas, proj);
    g.fx.render(canvas, proj);
    _drawBullets(canvas, proj);
    _drawGrenades(canvas, proj);
    _drawReticle(canvas, proj);
    _drawHitMarker(canvas, proj);
    _drawPopups(canvas, proj);
    canvas.restore();
    _drawThreats(canvas, proj);
  }

  // ------------------------------------------------------------------ sky

  void _drawSky(Canvas canvas, Projection proj) {
    final h = proj.height;
    final w = proj.width;
    final horizon = proj.horizonY;
    if (_skyPaint == null || _skyForH != h) {
      _skyForH = h;
      _skyPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, horizon + h * 0.12),
          const <Color>[Color(0xFF0B0C10), Color(0xFF2A1E18), Color(0xFF5A3A26), haze],
          const <double>[0.0, 0.45, 0.85, 1.0],
        );
    }
    canvas.drawRect(Rect.fromLTWH(-30, -30, w + 60, horizon + h * 0.12 + 30), _skyPaint!);
    final sh = h * 0.21;
    final sw = _skyline.width * sh / _skyline.height;
    var x = -((proj.camX * 0.12) % sw);
    final top = horizon + sh * 0.07 - sh;
    final src = Rect.fromLTWH(0, 0, _skyline.width.toDouble(), _skyline.height.toDouble());
    while (x < w + 30) {
      canvas.drawImageRect(_skyline, src, Rect.fromLTWH(x - 1, top, sw + 2, sh), _spritePaint);
      x += sw;
    }
  }

  // ------------------------------------------------------------------ ground

  int _overlay(double shade, double fog) {
    final a = 1 - (1 - shade) * (1 - fog);
    if (a <= 0.004) return 0;
    final k = fog / a;
    final r = (_hazeR * k).round().clamp(0, 255);
    final gg = (_hazeG * k).round().clamp(0, 255);
    final b = (_hazeB * k).round().clamp(0, 255);
    return ((a * 255).round().clamp(0, 255) << 24) | (r << 16) | (gg << 8) | b;
  }

  double _fogAt(double f) => smoothStepD(900, Projection.farClip, f) * 0.94;

  void _drawGround(Canvas canvas, Projection proj) {
    final w = proj.width;
    final fNear = math.max(Projection.nearClip + 10, proj.depthAtScreenY(proj.height + 12) * 0.96);
    const fFar = Projection.farClip;
    final ratio = fFar / fNear;
    const texScale = 1.3;
    for (var i = 0; i <= _rows; i++) {
      final f = (fNear * math.pow(ratio, i / _rows)).toDouble();
      final s = proj.focal / f;
      final wy = proj.camY + Projection.backDist - f;
      final sy = proj.horizonY + Projection.camHeight * s;
      final halfW = (w * 0.5 + 80) / s;
      _gfog[i] = _fogAt(f);
      for (var j = 0; j <= _cols; j++) {
        final idx = i * (_cols + 1) + j;
        final wx = proj.camX - halfW + 2 * halfW * j / _cols;
        _gwx[idx] = wx;
        _gwy[idx] = wy;
        _gsx[idx] = w * 0.5 + (wx - proj.camX) * s;
        _gsy[idx] = sy;
      }
    }
    final gm = _groundMesh..reset();
    for (var i = 0; i < _rows; i++) {
      final c0 = _overlay(0, _gfog[i]);
      final c1 = _overlay(0, _gfog[i + 1]);
      for (var j = 0; j < _cols; j++) {
        final a = i * (_cols + 1) + j;
        final b = a + 1;
        final c = a + _cols + 2;
        final d = a + _cols + 1;
        gm.vert(_gsx[a], _gsy[a], _gwx[a] * texScale, _gwy[a] * texScale, c0);
        gm.vert(_gsx[b], _gsy[b], _gwx[b] * texScale, _gwy[b] * texScale, c0);
        gm.vert(_gsx[c], _gsy[c], _gwx[c] * texScale, _gwy[c] * texScale, c1);
        gm.vert(_gsx[a], _gsy[a], _gwx[a] * texScale, _gwy[a] * texScale, c0);
        gm.vert(_gsx[c], _gsy[c], _gwx[c] * texScale, _gwy[c] * texScale, c1);
        gm.vert(_gsx[d], _gsy[d], _gwx[d] * texScale, _gwy[d] * texScale, c1);
      }
    }
    gm.drawTextured(canvas, _groundPaint);

    _drawRoads(canvas, proj, fNear, fFar);
    _drawDecals(canvas, proj, fNear, fFar);

    gm.drawColored(canvas, _colorPaint);
  }

  void _groundVert(Projection proj, double x, double y, double u, double v) {
    final f = proj.camY + Projection.backDist - y;
    final s = proj.focal / f;
    _mesh.vert(proj.width * 0.5 + (x - proj.camX) * s, proj.horizonY + Projection.camHeight * s, u, v, 0);
  }

  void _drawRoads(Canvas canvas, Projection proj, double fNear, double fFar) {
    final yNear = proj.camY + Projection.backDist - fNear;
    final yFar = proj.camY + Projection.backDist - fFar;
    final halfMax = (proj.width * 0.5 + 80) * fFar / proj.focal;
    final xMin = proj.camX - halfMax;
    final xMax = proj.camX + halfMax;
    _mesh.reset();
    for (final road in game.map.roads) {
      final r = road.rect;
      final y0 = math.max(r.top, yFar);
      final y1 = math.min(r.bottom, yNear);
      final x0 = math.max(r.left, xMin);
      final x1 = math.min(r.right, xMax);
      if (y1 <= y0 || x1 <= x0) continue;
      final fa = proj.camY + Projection.backDist - y1;
      final fb = proj.camY + Projection.backDist - y0;
      final rows = clampD((math.log(fb / fa) * 9).ceilToDouble(), 1, 20).toInt();
      final cols = clampD(((x1 - x0) / 160).ceilToDouble(), 1, 16).toInt();
      if (!_mesh.hasRoom(rows * cols * 6)) {
        _mesh.drawTextured(canvas, _roadPaint);
        _mesh.reset();
      }
      final scale = road.vertical ? 256 / r.width : 256 / r.height;
      for (var i = 0; i < rows; i++) {
        final fA = (fa * math.pow(fb / fa, i / rows)).toDouble();
        final fB = (fa * math.pow(fb / fa, (i + 1) / rows)).toDouble();
        final ya = proj.camY + Projection.backDist - fA;
        final yb = proj.camY + Projection.backDist - fB;
        for (var j = 0; j < cols; j++) {
          final xa = x0 + (x1 - x0) * j / cols;
          final xb = x0 + (x1 - x0) * (j + 1) / cols;
          double u(double x, double y) => road.vertical ? (x - r.left) * scale : (y - r.top) * scale;
          double v(double x, double y) => road.vertical ? y * scale : x * scale;
          _groundVert(proj, xa, ya, u(xa, ya), v(xa, ya));
          _groundVert(proj, xb, ya, u(xb, ya), v(xb, ya));
          _groundVert(proj, xb, yb, u(xb, yb), v(xb, yb));
          _groundVert(proj, xa, ya, u(xa, ya), v(xa, ya));
          _groundVert(proj, xb, yb, u(xb, yb), v(xb, yb));
          _groundVert(proj, xa, yb, u(xa, yb), v(xa, yb));
        }
      }
    }
    _mesh.drawTextured(canvas, _roadPaint);
    _mesh.reset();
  }

  void _drawDecals(Canvas canvas, Projection proj, double fNear, double fFar) {
    _mesh.reset();
    void addDecal(Decal d) {
      final half = d.size * 0.5;
      final fFront = proj.depthOf(d.y + half);
      final fBack = proj.depthOf(d.y - half);
      if (fFront < fNear * 0.8 || fBack > fFar) return;
      final s = proj.focal / math.max(fFront, 1);
      final sx = proj.width * 0.5 + (d.x - proj.camX) * s;
      if (sx + half * s < 0 || sx - half * s > proj.width) return;
      if (!_mesh.hasRoom(24)) {
        _mesh.drawTextured(canvas, _craterPaint);
        _mesh.reset();
      }
      for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
          final xa = d.x - half + d.size * j / 2;
          final xb = d.x - half + d.size * (j + 1) / 2;
          final ya = d.y - half + d.size * i / 2;
          final yb = d.y - half + d.size * (i + 1) / 2;
          final ua = 128.0 * j;
          final ub = 128.0 * (j + 1);
          final va = 128.0 * i;
          final vb = 128.0 * (i + 1);
          _groundVert(proj, xa, ya, ua, va);
          _groundVert(proj, xb, ya, ub, va);
          _groundVert(proj, xb, yb, ub, vb);
          _groundVert(proj, xa, ya, ua, va);
          _groundVert(proj, xb, yb, ub, vb);
          _groundVert(proj, xa, yb, ua, vb);
        }
      }
    }

    for (final d in game.map.decals) {
      addDecal(d);
    }
    for (final d in game.dynamicDecals) {
      addDecal(d);
    }
    _mesh.drawTextured(canvas, _craterPaint);
    _mesh.reset();
  }

  // ------------------------------------------------------------------ sorting

  void _push(double key, int type, int index) {
    if (_itemCount >= _itemPool.length) return;
    final it = _itemPool[_itemCount++];
    it
      ..key = key
      ..type = type
      ..index = index;
  }

  static int _byKey(_Item a, _Item b) => a.key.compareTo(b.key);

  void _collect(Projection proj) {
    final g = game;
    _itemCount = 0;
    final camX = proj.camX;
    final camLine = proj.camY + Projection.backDist;
    final halfScreen = proj.width * 0.5;
    final boxes = g.map.boxes;
    for (var i = 0; i < boxes.length; i++) {
      final b = boxes[i];
      if (!b.visible) continue;
      final fBack = camLine - b.y0;
      final fFront = camLine - b.y1;
      if (fBack < Projection.nearClip + 6 || fFront > Projection.farClip) continue;
      final f = math.max(fFront, Projection.nearClip + 6);
      final s = proj.focal / f;
      final sBack = proj.focal / fBack;
      final l = halfScreen + (b.x0 - camX) * math.max(s, sBack);
      final r = halfScreen + (b.x1 - camX) * math.max(s, sBack);
      final l2 = halfScreen + (b.x0 - camX) * math.min(s, sBack);
      final r2 = halfScreen + (b.x1 - camX) * math.min(s, sBack);
      if (math.max(r, r2) < -40 || math.min(l, l2) > proj.width + 40) continue;
      _push(b.y1, _tBox, i);
    }
    final props = g.map.props;
    for (var i = 0; i < props.length; i++) {
      final p = props[i];
      final f = camLine - p.y;
      if (f < Projection.nearClip + 10 || f > Projection.farClip) continue;
      final s = proj.focal / f;
      final sx = halfScreen + (p.x - camX) * s;
      final hw = p.width * s * 0.5;
      if (sx + hw < 0 || sx - hw > proj.width) continue;
      _push(p.y, _tProp, i);
    }
    _push(_actorKey(g.player.x, g.player.y, camX), _tPlayer, 0);
    final enemies = g.director.pool;
    for (var i = 0; i < enemies.length; i++) {
      final e = enemies[i];
      if (!e.active) continue;
      final f = camLine - e.y;
      if (f < Projection.nearClip + 10 || f > Projection.farClip) continue;
      _push(_actorKey(e.x, e.y, camX), _tEnemy, i);
    }
    final pickups = g.pickups;
    for (var i = 0; i < pickups.length; i++) {
      if (!pickups[i].active) continue;
      _push(pickups[i].y, _tPickup, i);
    }
    _items
      ..clear()
      ..addAll(_itemPool.take(_itemCount));
    _items.sort(_byKey);
  }

  /// Sort key for a soldier. Soldiers standing beside a block on the side
  /// facing the camera must be drawn after that block's visible side wall.
  double _actorKey(double x, double y, double camX) {
    var key = y;
    for (final i in game.map.cellAt(x, y)) {
      final b = game.map.boxes[i];
      if (!b.visible || y < b.y0 || y > b.y1) continue;
      if ((x > b.x1 && camX > b.x1) || (x < b.x0 && camX < b.x0)) {
        if (b.y1 + 0.5 > key) key = b.y1 + 0.5;
      }
    }
    return key;
  }

  void _drawItems(Canvas canvas, Projection proj) {
    final g = game;
    for (final it in _items) {
      switch (it.type) {
        case _tBox:
          _drawBox(canvas, proj, g.map.boxes[it.index]);
          break;
        case _tProp:
          _drawProp(canvas, proj, g.map.props[it.index]);
          break;
        case _tPlayer:
          final p = g.player;
          _drawSoldier(canvas, proj, p.x, p.y, p.pose, g.playerLook, g.weaponSpec.model, 1.0, p.hitFlash * 0.6, 1.0);
          break;
        case _tEnemy:
          _drawEnemy(canvas, proj, g.director.pool[it.index]);
          break;
        case _tPickup:
          _drawPickup(canvas, proj, g.pickups[it.index]);
          break;
      }
    }
  }

  // ------------------------------------------------------------------ blocks

  void _boxVert(Projection proj, double x, double y, double z, double u, double v, int color) {
    final f = proj.camY + Projection.backDist - y;
    final s = proj.focal / f;
    _mesh.vert(proj.width * 0.5 + (x - proj.camX) * s, proj.horizonY + (Projection.camHeight - z) * s, u, v, color);
  }

  void _drawBox(Canvas canvas, Projection proj, BoxObstacle b) {
    final camLine = proj.camY + Projection.backDist;
    final minY = camLine - Projection.nearClip - 4;
    final y0 = b.y0;
    final y1 = math.min(b.y1, minY);
    if (y1 <= y0) return;
    final h = b.height;
    final mat = _materials[b.material]!;
    final p = game.player;
    var alpha = 1.0;
    if (h > 70 && b.y0 > p.y - 40 && b.y0 - p.y < 520 && p.x > b.x0 - 90 && p.x < b.x1 + 90) {
      alpha = 0.3;
    }
    final fFront = camLine - y1;
    final fBack = camLine - y0;
    final fogF = _fogAt(fFront);
    final ws = mat.wallScale;
    final off = b.material == BoxMaterial.crate ? 0.0 : b.texOffset;

    _mesh.reset();
    // Side walls.
    final steps = clampD((math.log(fBack / fFront) * 6).ceilToDouble(), 1, 8).toInt();
    void side(double x) {
      for (var i = 0; i < steps; i++) {
        final fa = (fFront * math.pow(fBack / fFront, i / steps)).toDouble();
        final fb = (fFront * math.pow(fBack / fFront, (i + 1) / steps)).toDouble();
        final ya = camLine - fa;
        final yb = camLine - fb;
        final fogA = _fogAt(fa);
        final fogBb = _fogAt(fb);
        final topA = _overlay(mat.sideShade, fogA);
        final topB = _overlay(mat.sideShade, fogBb);
        final botA = _overlay(math.min(0.9, mat.sideShade + 0.25), fogA);
        final botB = _overlay(math.min(0.9, mat.sideShade + 0.25), fogBb);
        final ua = (ya - y0) * ws + off;
        final ub = (yb - y0) * ws + off;
        _boxVert(proj, x, ya, 0, ua, h * ws, botA);
        _boxVert(proj, x, yb, 0, ub, h * ws, botB);
        _boxVert(proj, x, yb, h, ub, 0, topB);
        _boxVert(proj, x, ya, 0, ua, h * ws, botA);
        _boxVert(proj, x, yb, h, ub, 0, topB);
        _boxVert(proj, x, ya, h, ua, 0, topA);
      }
    }

    if (proj.camX < b.x0) side(b.x0);
    if (proj.camX > b.x1) side(b.x1);

    // Front wall.
    final fTop = _overlay(0.06, fogF);
    final fBot = _overlay(0.32, fogF);
    final u0 = off;
    final u1 = (b.x1 - b.x0) * ws + off;
    _boxVert(proj, b.x0, y1, 0, u0, h * ws, fBot);
    _boxVert(proj, b.x1, y1, 0, u1, h * ws, fBot);
    _boxVert(proj, b.x1, y1, h, u1, 0, fTop);
    _boxVert(proj, b.x0, y1, 0, u0, h * ws, fBot);
    _boxVert(proj, b.x1, y1, h, u1, 0, fTop);
    _boxVert(proj, b.x0, y1, h, u0, 0, fTop);

    _drawMeshPair(canvas, mat.wall, alpha);

    // Roof.
    if (h < Projection.camHeight - 4) {
      final ts = mat.topScale;
      final topSteps = clampD((math.log(fBack / fFront) * 4).ceilToDouble(), 1, 6).toInt();
      for (var i = 0; i < topSteps; i++) {
        final fa = (fFront * math.pow(fBack / fFront, i / topSteps)).toDouble();
        final fb = (fFront * math.pow(fBack / fFront, (i + 1) / topSteps)).toDouble();
        final ya = camLine - fa;
        final yb = camLine - fb;
        final ca = _overlay(0.0, _fogAt(fa));
        final cb = _overlay(0.0, _fogAt(fb));
        _boxVert(proj, b.x0, ya, h, b.x0 * ts, ya * ts, ca);
        _boxVert(proj, b.x1, ya, h, b.x1 * ts, ya * ts, ca);
        _boxVert(proj, b.x1, yb, h, b.x1 * ts, yb * ts, cb);
        _boxVert(proj, b.x0, ya, h, b.x0 * ts, ya * ts, ca);
        _boxVert(proj, b.x1, yb, h, b.x1 * ts, yb * ts, cb);
        _boxVert(proj, b.x0, yb, h, b.x0 * ts, yb * ts, cb);
      }
      _drawMeshPair(canvas, mat.top, alpha);
    }
  }

  void _drawMeshPair(Canvas canvas, Paint texture, double alpha) {
    if (alpha < 1) {
      texture.color = Color.fromRGBO(255, 255, 255, alpha);
      _colorPaint.color = Color.fromRGBO(255, 255, 255, alpha);
    }
    _mesh.drawTextured(canvas, texture);
    _mesh.drawColored(canvas, _colorPaint);
    if (alpha < 1) {
      texture.color = const Color(0xFFFFFFFF);
      _colorPaint.color = const Color(0xFFFFFFFF);
    }
    _mesh.reset();
  }

  // ------------------------------------------------------------------ props

  void _drawProp(Canvas canvas, Projection proj, BillboardProp p) {
    if (!proj.project(p.x, p.y, 0)) return;
    final s = proj.scale;
    final sx = proj.sx;
    final sy = proj.sy;
    final w = p.width * s;
    final h = p.height * s;
    final f = proj.depthOf(p.y);
    if (p.kind == PropKind.tankWreck || p.kind == PropKind.truckWreck || p.kind == PropKind.rock) {
      final sw = w * 0.95;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(sx, sy - 2), width: sw, height: sw * Projection.camHeight / f * 0.9),
          _shadowPaint);
    } else if (p.kind == PropKind.tree || p.kind == PropKind.deadTree) {
      final sw = w * 0.45;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(sx, sy), width: sw, height: sw * Projection.camHeight / f), _shadowPaint);
    }
    final fogIdx = (_fogAt(f) / 0.94 * 7).round().clamp(0, 7);
    final paint = _fogPaints[fogIdx];
    final img = _propImages[p.kind]!;
    final src = _propSrc[p.kind]!;
    final dst = Rect.fromLTWH(sx - w * 0.5, sy - h, w, h);
    if (p.flip) {
      canvas.save();
      canvas.translate(sx, 0);
      canvas.scale(-1, 1);
      canvas.translate(-sx, 0);
      canvas.drawImageRect(img, src, dst, paint);
      canvas.restore();
    } else {
      canvas.drawImageRect(img, src, dst, paint);
    }
  }

  // ------------------------------------------------------------------ soldiers

  void _drawSoldier(Canvas canvas, Projection proj, double x, double y, RigPose pose, RigLook look,
      WeaponModel model, double scale, double flash, double alpha) {
    if (!proj.project(x, y, 0)) return;
    final s = proj.scale;
    final sx = proj.sx;
    final sy = proj.sy;
    final size = s * scale;
    if (sx < -120 * size || sx > proj.width + 120 * size || sy < -20 || sy - 90 * size > proj.height) return;
    final f = proj.depthOf(y);
    final sw = 34 * size * (1 + pose.death * 1.3);
    _shadowPaint.color = Color.fromRGBO(0, 0, 0, 0.38 * alpha);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(sx, sy), width: sw, height: sw * Projection.camHeight / f + 1), _shadowPaint);
    _shadowPaint.color = const Color(0x5A000000);
    canvas.save();
    canvas.translate(sx, sy);
    canvas.scale(size, size);
    game.rig.draw(canvas, pose, look, model, detailed: size > 0.42, flash: flash, alpha: alpha);
    canvas.restore();
  }

  void _drawEnemy(Canvas canvas, Projection proj, Enemy e) {
    var alpha = e.spawnFade;
    if (!e.alive && e.deathTimer > 3.4) {
      alpha = clampD(1 - (e.deathTimer - 3.4), 0, 1);
    }
    if (alpha <= 0.02) return;
    _drawSoldier(canvas, proj, e.x, e.y, e.pose, e.spec.look, e.spec.weapon, e.spec.scale, e.hitFlash, alpha);
    if (e.alive && !e.isBoss && e.barTimer > 0 && proj.project(e.x, e.y, 86 * e.spec.scale)) {
      final s = proj.scale;
      final w = 38 * s;
      final hgt = math.max(3.0, 4.2 * s);
      final a = clampD(e.barTimer, 0, 1);
      final rect = Rect.fromLTWH(proj.sx - w / 2, proj.sy - hgt, w, hgt);
      _fill.color = Color.fromRGBO(0, 0, 0, 0.6 * a);
      canvas.drawRect(rect.inflate(1), _fill);
      _fill.color = Color.fromRGBO(230, 60, 40, a);
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, w * clampD(e.hp / e.maxHp, 0, 1), hgt), _fill);
    }
  }

  void _drawPickup(Canvas canvas, Projection proj, Pickup p) {
    if (p.life < 4 && ((p.life * 7).floor() % 2 == 0)) return;
    final bob = math.sin(game.session.time * 3 + p.x) * 4 + 8;
    if (!proj.project(p.x, p.y, 0)) return;
    final s = proj.scale;
    final groundX = proj.sx;
    final groundY = proj.sy;
    canvas.drawOval(Rect.fromCenter(center: Offset(groundX, groundY), width: 30 * s, height: 10 * s), _shadowPaint);
    final w = 26 * s;
    final top = groundY - (bob + 20) * s;
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(groundX - w / 2, top, w, w * 0.78), Radius.circular(3 * s));
    _fill.color = const Color(0xFF2E5E2C);
    canvas.drawRRect(body, _fill);
    _fill.color = const Color(0xFF4E8C46);
    canvas.drawRRect(body.deflate(1.5 * s), _fill);
    _fill.color = const Color(0xFFF2F2EA);
    final c = body.center;
    canvas.drawRect(Rect.fromCenter(center: c, width: w * 0.5, height: w * 0.16), _fill);
    canvas.drawRect(Rect.fromCenter(center: c, width: w * 0.16, height: w * 0.5), _fill);
    _fill.color = const Color(0x3580FF90);
    canvas.drawCircle(c, w * 0.95, _fill);
  }

  // ------------------------------------------------------------------ overlays in world space

  void _drawTelegraphs(Canvas canvas, Projection proj) {
    final t = game.session.time;
    for (final g in game.grenades) {
      if (!g.active) continue;
      if (!proj.project(g.tx, g.ty, 0)) continue;
      final f = proj.depthOf(g.ty);
      final rx = g.radius * proj.scale;
      final ry = rx * Projection.camHeight / f;
      final rect = Rect.fromCenter(center: Offset(proj.sx, proj.sy), width: rx * 2, height: ry * 2);
      final pulse = 0.5 + 0.5 * math.sin(t * 18);
      _fill.color = Color.fromRGBO(255, 40, 20, 0.1 + 0.14 * g.progress);
      canvas.drawOval(rect, _fill);
      _stroke
        ..strokeWidth = 2.2
        ..color = Color.fromRGBO(255, 70, 40, 0.5 + 0.4 * pulse);
      canvas.drawOval(rect, _stroke);
      final k = 1 - g.progress;
      canvas.drawOval(Rect.fromCenter(center: rect.center, width: rect.width * k, height: rect.height * k), _stroke);
    }
  }

  void _drawGrenades(Canvas canvas, Projection proj) {
    for (final g in game.grenades) {
      if (!g.active) continue;
      final t = g.progress;
      final x = g.sx + (g.tx - g.sx) * t;
      final y = g.sy + (g.ty - g.sy) * t;
      final z = 40 + 680 * t * (1 - t);
      if (!proj.project(x, y, z)) continue;
      final r = math.max(2.5, 6 * proj.scale);
      _fill.color = const Color(0xFF26281E);
      canvas.drawCircle(Offset(proj.sx, proj.sy), r, _fill);
      _fill.color = const Color(0x66FFFFFF);
      canvas.drawCircle(Offset(proj.sx - r * 0.3, proj.sy - r * 0.3), r * 0.4, _fill);
      if ((g.t * 10).floor().isEven) {
        _fill.color = const Color(0xCCFF5030);
        canvas.drawCircle(Offset(proj.sx, proj.sy - r), r * 0.5, _fill);
      }
    }
  }

  void _drawBullets(Canvas canvas, Projection proj) {
    for (final b in game.bullets.pool) {
      if (!b.active) continue;
      final len = math.min(b.travelled, b.fromPlayer ? 90.0 : 60.0);
      if (!proj.project(b.x, b.y, b.z)) continue;
      final hx = proj.sx;
      final hy = proj.sy;
      final s = proj.scale;
      if (!proj.project(b.x - b.dx * len, b.y - b.dy * len, b.z)) continue;
      final tx = proj.sx;
      final ty = proj.sy;
      if ((hx < -20 && tx < -20) || (hx > proj.width + 20 && tx > proj.width + 20)) continue;
      final w = math.max(1.0, b.width * s * 1.6);
      _tracerGlow
        ..strokeWidth = w * 3
        ..color = b.color.withAlpha(70);
      canvas.drawLine(Offset(tx, ty), Offset(hx, hy), _tracerGlow);
      _tracerCore
        ..strokeWidth = w
        ..color = b.color;
      canvas.drawLine(Offset(tx, ty), Offset(hx, hy), _tracerCore);
    }
  }

  void _drawReticle(Canvas canvas, Projection proj) {
    final p = game.player;
    final t = p.target;
    if (!p.aiming || t == null || !t.alive || !t.active) return;
    if (!proj.project(t.x, t.y, 44 * t.spec.scale)) return;
    final r = math.max(16.0, 26 * proj.scale * t.spec.scale);
    final c = Offset(proj.sx, proj.sy);
    final rot = game.session.time * 1.4;
    _stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xE6FF5A3A);
    for (var i = 0; i < 4; i++) {
      final a = rot + i * math.pi / 2;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a - 0.35, 0.7, false, _stroke);
    }
    _stroke.strokeWidth = 1.6;
    canvas.drawLine(c + Offset(-r * 0.35, 0), c + Offset(-r * 0.12, 0), _stroke);
    canvas.drawLine(c + Offset(r * 0.12, 0), c + Offset(r * 0.35, 0), _stroke);
    canvas.drawLine(c + Offset(0, -r * 0.35), c + Offset(0, -r * 0.12), _stroke);
    canvas.drawLine(c + Offset(0, r * 0.12), c + Offset(0, r * 0.35), _stroke);
  }

  void _drawHitMarker(Canvas canvas, Projection proj) {
    final g = game;
    if (g.hitMarker <= 0) return;
    if (!proj.project(g.hitMarkerX, g.hitMarkerY, g.hitMarkerZ)) return;
    final a = g.hitMarker;
    final size = g.hitMarkerKill ? 14.0 : 9.0;
    final gap = 4.0 + (1 - a) * 4;
    final c = Offset(proj.sx, proj.sy);
    _stroke
      ..strokeWidth = g.hitMarkerKill ? 3 : 2
      ..color = g.hitMarkerHead || g.hitMarkerKill
          ? Color.fromRGBO(255, 70, 50, a)
          : Color.fromRGBO(255, 255, 255, a);
    for (final d in const [Offset(1, 1), Offset(-1, 1), Offset(1, -1), Offset(-1, -1)]) {
      canvas.drawLine(c + d * gap, c + d * (gap + size), _stroke);
    }
  }

  TextPainter _popupPainter(int value) {
    return _popupText.putIfAbsent(value, () {
      if (_popupText.length > 40) {
        for (final tp in _popupText.values) {
          tp.dispose();
        }
        _popupText.clear();
      }
      return TextPainter(
        text: TextSpan(
          text: '+$value',
          style: const TextStyle(
            color: Color(0xFFFFE08A),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            shadows: [Shadow(color: Color(0xFF000000), blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    });
  }

  void _drawPopups(Canvas canvas, Projection proj) {
    for (final p in game.popups) {
      if (!p.active) continue;
      if (!proj.project(p.x, p.y, p.z)) continue;
      final tp = _popupPainter(p.value);
      final a = clampD(p.life / 0.4, 0, 1);
      final scale = clampD(proj.scale * 1.1, 0.7, 1.4);
      canvas.save();
      canvas.translate(proj.sx, proj.sy);
      canvas.scale(scale, scale);
      if (a < 1) {
        canvas.saveLayer(
          Rect.fromLTWH(-tp.width / 2 - 40, -tp.height * 2 - 20, tp.width + 80, tp.height * 2 + 30),
          Paint()..color = Color.fromRGBO(255, 255, 255, a),
        );
      }
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height));
      if (p.headshot) {
        final hs = _headshotText ??= TextPainter(
          text: const TextSpan(
            text: 'HEADSHOT',
            style: TextStyle(
              color: Color(0xFFFF6A4A),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: [Shadow(color: Color(0xFF000000), blurRadius: 4)],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        hs.paint(canvas, Offset(-hs.width / 2, -tp.height - hs.height));
      }
      if (a < 1) canvas.restore();
      canvas.restore();
    }
  }

  void _drawThreats(Canvas canvas, Projection proj) {
    final g = game;
    final p = g.player;
    if (!p.alive) return;
    if (!proj.project(p.x, p.y, 40)) return;
    final px = proj.sx;
    final py = proj.sy;
    final w = proj.width;
    final h = proj.height;
    const inset = 34.0;
    for (final e in g.director.pool) {
      if (!e.active || !e.alive || !(e.engaging || e.isBoss)) continue;
      var visible = proj.project(e.x, e.y, 40);
      if (visible) {
        visible = proj.sx > 0 && proj.sx < w && proj.sy > 0 && proj.sy < h;
      }
      if (visible) continue;
      final dx = e.x - p.x;
      final dy = e.y - p.y;
      final len = math.sqrt(dx * dx + dy * dy) + 1e-6;
      final ux = dx / len;
      final uy = dy / len;
      var t = double.infinity;
      if (ux > 0) t = math.min(t, (w - inset - px) / ux);
      if (ux < 0) t = math.min(t, (inset - px) / ux);
      if (uy > 0) t = math.min(t, (h - inset - py) / uy);
      if (uy < 0) t = math.min(t, (inset - py) / uy);
      if (!t.isFinite || t < 0) continue;
      final ix = px + ux * t;
      final iy = py + uy * t;
      final angle = math.atan2(uy, ux);
      final pulse = 0.6 + 0.4 * math.sin(g.session.time * 8 + e.id);
      final size = e.isBoss ? 18.0 : 12.0;
      canvas.save();
      canvas.translate(ix, iy);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(size, 0)
        ..lineTo(-size * 0.6, -size * 0.75)
        ..lineTo(-size * 0.25, 0)
        ..lineTo(-size * 0.6, size * 0.75)
        ..close();
      _fill.color = e.isBoss ? Color.fromRGBO(255, 40, 30, pulse) : Color.fromRGBO(255, 90, 60, 0.85 * pulse);
      canvas.drawPath(path, _fill);
      canvas.restore();
    }
  }
}
