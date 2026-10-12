import 'dart:math' as math;
import 'dart:ui';

enum BoxMaterial { building, sandbag, concrete, crate }

/// Axis-aligned solid block. Visible blocks are rendered as textured 3D boxes;
/// invisible ones are collision hulls for billboard props.
class BoxObstacle {
  BoxObstacle({
    required this.x0,
    required this.y0,
    required this.x1,
    required this.y1,
    required this.height,
    required this.material,
    this.visible = true,
    this.blocksSight = true,
    this.blocksBullets = true,
  }) : texOffset = (x0 * 0.37 + y0 * 0.11) % 256;

  final double x0;
  final double y0;
  final double x1;
  final double y1;
  final double height;
  final BoxMaterial material;
  final bool visible;
  final bool blocksSight;
  final bool blocksBullets;
  final double texOffset;

  double get cx => (x0 + x1) * 0.5;
  double get cy => (y0 + y1) * 0.5;

  bool contains(double x, double y) => x >= x0 && x <= x1 && y >= y0 && y <= y1;

  bool overlaps(double ax0, double ay0, double ax1, double ay1, double margin) =>
      ax0 < x1 + margin && ax1 > x0 - margin && ay0 < y1 + margin && ay1 > y0 - margin;
}

enum PropKind { tree, deadTree, rock, tankWreck, truckWreck, hedgehog, barrel, debris }

class BillboardProp {
  BillboardProp(this.kind, this.x, this.y, this.width, this.height, this.flip);

  final PropKind kind;
  final double x;
  final double y;
  final double width;
  final double height;
  final bool flip;
}

class RoadSegment {
  const RoadSegment(this.rect, this.vertical);

  final Rect rect;
  final bool vertical;
}

enum ZoneKind { checkpoint, district, depot, motorPool, square }

class MapZone {
  const MapZone(this.kind, this.rect, this.color);

  final ZoneKind kind;
  final Rect rect;
  final Color color;
}

class Decal {
  Decal(this.x, this.y, this.size);

  double x;
  double y;
  double size;
}

class FireSpot {
  FireSpot(this.x, this.y, this.z, this.intensity, this.smokeColumn);

  final double x;
  final double y;
  final double z;
  final double intensity;
  final bool smokeColumn;
  double emitAcc = 0;
  double smokeAcc = 0;
}

/// Procedurally laid out battlefield with a uniform spatial grid for fast
/// collision, bullet and line-of-sight queries.
class BattleMap {
  static const double size = 3600;
  static const double cell = 200;
  static const int cols = 18;
  static const double margin = 60;

  final List<BoxObstacle> boxes = <BoxObstacle>[];
  final List<BillboardProp> props = <BillboardProp>[];
  final List<RoadSegment> roads = <RoadSegment>[];
  final List<MapZone> zones = <MapZone>[];
  final List<Decal> decals = <Decal>[];
  final List<FireSpot> fires = <FireSpot>[];
  final List<List<int>> _grid = List<List<int>>.generate(cols * cols, (_) => <int>[]);

  final double startX = 1810;
  final double startY = 2380;

  late math.Random _r;

  double _rand(double a, double b) => a + _r.nextDouble() * (b - a);

  void generate(int seed) {
    _r = math.Random(seed);
    boxes.clear();
    props.clear();
    roads.clear();
    zones.clear();
    decals.clear();
    fires.clear();
    for (final c in _grid) {
      c.clear();
    }

    roads.addAll(const [
      RoadSegment(Rect.fromLTRB(0, 1700, size, 1900), false),
      RoadSegment(Rect.fromLTRB(0, 600, size, 760), false),
      RoadSegment(Rect.fromLTRB(0, 2800, size, 2960), false),
      RoadSegment(Rect.fromLTRB(1720, 0, 1900, size), true),
      RoadSegment(Rect.fromLTRB(600, 0, 760, size), true),
      RoadSegment(Rect.fromLTRB(2820, 0, 2980, size), true),
    ]);

    zones.addAll(const [
      MapZone(ZoneKind.checkpoint, Rect.fromLTRB(1480, 1460, 2140, 2140), Color(0xFFE0A030)),
      MapZone(ZoneKind.district, Rect.fromLTRB(760, 760, 1720, 1700), Color(0xFF9A9AA0)),
      MapZone(ZoneKind.depot, Rect.fromLTRB(1900, 760, 2820, 1700), Color(0xFF6FAF5A)),
      MapZone(ZoneKind.motorPool, Rect.fromLTRB(1900, 1900, 2820, 2800), Color(0xFF5A8FC0)),
      MapZone(ZoneKind.square, Rect.fromLTRB(760, 1900, 1720, 2800), Color(0xFFB0A060)),
    ]);

    _buildCheckpoint();
    _buildDistrict();
    _buildDepot();
    _buildMotorPool();
    _buildSquare();
    _buildOuterBlocks();
    _buildRoadClutter();
    _buildBorders();

    for (var i = 0; i < 46; i++) {
      final x = _rand(150, size - 150);
      final y = _rand(150, size - 150);
      if (_nearStart(x, y, 220)) continue;
      decals.add(Decal(x, y, _rand(90, 230)));
    }

    for (var i = 0; i < boxes.length; i++) {
      _register(i);
    }
  }

  bool _nearStart(double x, double y, double r) =>
      (x - startX) * (x - startX) + (y - startY) * (y - startY) < r * r;

  bool _free(double x0, double y0, double x1, double y1, double gap) {
    if (x0 < margin || y0 < margin || x1 > size - margin || y1 > size - margin) return false;
    for (final b in boxes) {
      if (b.overlaps(x0, y0, x1, y1, gap)) return false;
    }
    for (final road in roads) {
      if (x0 < road.rect.right && x1 > road.rect.left && y0 < road.rect.bottom && y1 > road.rect.top) {
        return false;
      }
    }
    if (_nearStart((x0 + x1) / 2, (y0 + y1) / 2, 260)) return false;
    return true;
  }

  void _addBox(double x0, double y0, double x1, double y1, double h, BoxMaterial m,
      {bool visible = true, bool sight = true, bool bullets = true}) {
    boxes.add(BoxObstacle(
      x0: x0,
      y0: y0,
      x1: x1,
      y1: y1,
      height: h,
      material: m,
      visible: visible,
      blocksSight: sight,
      blocksBullets: bullets,
    ));
  }

  bool _tryBuilding(Rect area, double minW, double maxW, double minD, double maxD, double minH, double maxH) {
    for (var attempt = 0; attempt < 24; attempt++) {
      final w = _rand(minW, maxW);
      final d = _rand(minD, maxD);
      final x0 = _rand(area.left + 40, area.right - 40 - w);
      final y0 = _rand(area.top + 40, area.bottom - 40 - d);
      if (area.right - 40 - w < area.left + 40 || area.bottom - 40 - d < area.top + 40) return false;
      if (_free(x0, y0, x0 + w, y0 + d, 70)) {
        final h = (_rand(minH, maxH) / 55).round() * 55.0;
        _addBox(x0, y0, x0 + w, y0 + d, h, BoxMaterial.building);
        if (_r.nextDouble() < 0.4) {
          fires.add(FireSpot(x0 + w * _rand(0.2, 0.8), y0 + d * _rand(0.2, 0.8), h, _rand(0.6, 1.0), true));
        }
        if (_r.nextDouble() < 0.6) {
          _addProp(PropKind.debris, x0 + _rand(0, w), y0 + d + _rand(25, 60), withHull: false);
        }
        return true;
      }
    }
    return false;
  }

  void _addProp(PropKind kind, double x, double y, {bool withHull = true}) {
    if (x < 30 || y < 30 || x > size - 30 || y > size - 30) return;
    final flip = _r.nextBool();
    switch (kind) {
      case PropKind.tree: {
        final h = _rand(230, 300);
        props.add(BillboardProp(kind, x, y, h * 0.8, h, flip));
        if (withHull) _addBox(x - 12, y - 12, x + 12, y + 12, 260, BoxMaterial.concrete, visible: false, sight: false);
        break;
      }
      case PropKind.deadTree: {
        final h = _rand(220, 300);
        props.add(BillboardProp(kind, x, y, h * 0.8, h, flip));
        if (withHull) _addBox(x - 10, y - 10, x + 10, y + 10, 260, BoxMaterial.concrete, visible: false, sight: false);
        break;
      }
      case PropKind.rock: {
        final w = _rand(110, 170);
        props.add(BillboardProp(kind, x, y, w, w * 0.66, flip));
        if (withHull) _addBox(x - w * 0.38, y - w * 0.2, x + w * 0.38, y + w * 0.2, w * 0.5, BoxMaterial.concrete, visible: false);
        break;
      }
      case PropKind.tankWreck: {
        props.add(BillboardProp(kind, x, y, 290, 170, flip));
        if (withHull) _addBox(x - 128, y - 52, x + 128, y + 52, 110, BoxMaterial.concrete, visible: false);
        fires.add(FireSpot(x + _rand(-60, 60), y, 70, _rand(0.7, 1.0), _r.nextDouble() < 0.7));
        break;
      }
      case PropKind.truckWreck: {
        props.add(BillboardProp(kind, x, y, 280, 164, flip));
        if (withHull) _addBox(x - 124, y - 50, x + 124, y + 50, 120, BoxMaterial.concrete, visible: false);
        if (_r.nextDouble() < 0.6) {
          fires.add(FireSpot(x + _rand(-80, 80), y, 60, _rand(0.5, 0.9), _r.nextDouble() < 0.5));
        }
        break;
      }
      case PropKind.hedgehog: {
        props.add(BillboardProp(kind, x, y, 92, 74, flip));
        if (withHull) {
          _addBox(x - 30, y - 22, x + 30, y + 22, 60, BoxMaterial.concrete, visible: false, sight: false, bullets: false);
        }
        break;
      }
      case PropKind.barrel: {
        props.add(BillboardProp(kind, x, y, 30, 45, flip));
        if (withHull) _addBox(x - 13, y - 13, x + 13, y + 13, 46, BoxMaterial.concrete, visible: false, sight: false);
        break;
      }
      case PropKind.debris: {
        props.add(BillboardProp(kind, x, y, 150, 75, flip));
        break;
      }
    }
  }

  void _buildCheckpoint() {
    const cx = 1810.0;
    const cy = 1800.0;
    // Sandbag L-walls on each corner of the crossing.
    for (final sx in const [-1.0, 1.0]) {
      for (final sy in const [-1.0, 1.0]) {
        final ox = cx + sx * 190;
        final oy = cy + sy * 190;
        _addBox(math.min(ox, ox + sx * 150), oy - 14, math.max(ox, ox + sx * 150), oy + 14, 50, BoxMaterial.sandbag);
        _addBox(ox - 14, math.min(oy, oy + sy * 120), ox + 14, math.max(oy, oy + sy * 120), 50, BoxMaterial.sandbag);
      }
    }
    // Jersey barriers staggered across the lanes.
    _addBox(1735, 1560, 1815, 1584, 46, BoxMaterial.concrete);
    _addBox(1820, 1500, 1890, 1524, 46, BoxMaterial.concrete);
    _addBox(1990, 1760, 2014, 1840, 46, BoxMaterial.concrete);
    _addBox(1590, 1770, 1614, 1850, 46, BoxMaterial.concrete);
    _addBox(1745, 2050, 1815, 2074, 46, BoxMaterial.concrete);
    for (final p in const [
      Offset(1640, 1540),
      Offset(2000, 1560),
      Offset(1610, 2060),
      Offset(2040, 2080),
      Offset(1930, 1640),
    ]) {
      _addProp(PropKind.hedgehog, p.dx, p.dy);
    }
    _addBox(1560, 1580, 1640, 1640, 46, BoxMaterial.crate);
    _addBox(1990, 1980, 2040, 2030, 92, BoxMaterial.crate);
    _addBox(2040, 1990, 2086, 2036, 46, BoxMaterial.crate);
    fires.add(FireSpot(1680, 1980, 0, 0.8, false));
  }

  void _buildDistrict() {
    const area = Rect.fromLTRB(760, 760, 1720, 1700);
    for (var i = 0; i < 9; i++) {
      _tryBuilding(area, 170, 300, 130, 240, 160, 400);
    }
    for (var i = 0; i < 6; i++) {
      final x = _rand(area.left + 60, area.right - 60);
      final y = _rand(area.top + 60, area.bottom - 60);
      if (_free(x - 30, y - 30, x + 30, y + 30, 20)) {
        _addProp(i.isEven ? PropKind.debris : PropKind.deadTree, x, y, withHull: i.isOdd);
      }
    }
  }

  void _buildDepot() {
    const area = Rect.fromLTRB(1900, 760, 2820, 1700);
    _tryBuilding(area, 300, 380, 150, 200, 110, 165);
    _tryBuilding(area, 260, 340, 140, 190, 110, 165);
    for (var cluster = 0; cluster < 7; cluster++) {
      final x = _rand(area.left + 80, area.right - 160);
      final y = _rand(area.top + 80, area.bottom - 140);
      if (!_free(x - 10, y - 10, x + 120, y + 100, 30)) continue;
      for (var k = 0; k < 5; k++) {
        final bx = x + (k % 3) * 46.0;
        final by = y + (k ~/ 3) * 50.0;
        _addBox(bx, by, bx + 44, by + 44, _r.nextDouble() < 0.35 ? 92 : 46, BoxMaterial.crate);
      }
    }
    for (var i = 0; i < 2; i++) {
      final x = _rand(area.left + 180, area.right - 180);
      final y = _rand(area.top + 100, area.bottom - 100);
      if (_free(x - 130, y - 55, x + 130, y + 55, 30)) _addProp(PropKind.truckWreck, x, y);
    }
    for (var i = 0; i < 4; i++) {
      final x = _rand(area.left + 80, area.right - 200);
      final y = _rand(area.top + 80, area.bottom - 80);
      if (_free(x, y - 14, x + 140, y + 14, 30)) _addBox(x, y - 14, x + 140, y + 14, 50, BoxMaterial.sandbag);
    }
  }

  void _buildMotorPool() {
    const area = Rect.fromLTRB(1900, 1900, 2820, 2800);
    _tryBuilding(area, 280, 360, 150, 190, 110, 165);
    for (var i = 0; i < 3; i++) {
      for (var a = 0; a < 20; a++) {
        final x = _rand(area.left + 180, area.right - 180);
        final y = _rand(area.top + 100, area.bottom - 100);
        if (_free(x - 140, y - 60, x + 140, y + 60, 40)) {
          _addProp(PropKind.tankWreck, x, y);
          break;
        }
      }
    }
    for (var i = 0; i < 2; i++) {
      for (var a = 0; a < 20; a++) {
        final x = _rand(area.left + 180, area.right - 180);
        final y = _rand(area.top + 100, area.bottom - 100);
        if (_free(x - 135, y - 55, x + 135, y + 55, 40)) {
          _addProp(PropKind.truckWreck, x, y);
          break;
        }
      }
    }
    for (var i = 0; i < 6; i++) {
      final x = _rand(area.left + 60, area.right - 60);
      final y = _rand(area.top + 60, area.bottom - 60);
      if (_free(x - 40, y - 40, x + 40, y + 40, 20)) {
        _addProp(PropKind.barrel, x, y);
        _addProp(PropKind.barrel, x + 30, y + 8);
      }
    }
    for (var i = 0; i < 4; i++) {
      final x = _rand(area.left + 60, area.right - 140);
      final y = _rand(area.top + 60, area.bottom - 60);
      if (_free(x, y - 12, x + 80, y + 12, 30)) _addBox(x, y - 12, x + 80, y + 12, 46, BoxMaterial.concrete);
    }
  }

  void _buildSquare() {
    const area = Rect.fromLTRB(760, 1900, 1720, 2800);
    _tryBuilding(area, 200, 260, 140, 180, 110, 160);
    for (var gx = 0; gx < 5; gx++) {
      for (var gy = 0; gy < 4; gy++) {
        final x = area.left + 110 + gx * 180 + _rand(-30, 30);
        final y = area.top + 120 + gy * 200 + _rand(-30, 30);
        if (_free(x - 16, y - 16, x + 16, y + 16, 30)) {
          _addProp(_r.nextDouble() < 0.7 ? PropKind.tree : PropKind.deadTree, x, y);
        }
      }
    }
    for (var i = 0; i < 6; i++) {
      final x = _rand(area.left + 80, area.right - 80);
      final y = _rand(area.top + 80, area.bottom - 80);
      if (_free(x - 60, y - 40, x + 60, y + 40, 20)) {
        _addProp(i.isEven ? PropKind.rock : PropKind.debris, x, y);
      }
    }
  }

  void _buildOuterBlocks() {
    const xs = [0.0, 760.0, 1900.0, 2980.0];
    const xe = [600.0, 1720.0, 2820.0, size];
    const ys = [0.0, 760.0, 1900.0, 2960.0];
    const ye = [600.0, 1700.0, 2800.0, size];
    for (var i = 0; i < 4; i++) {
      for (var k = 0; k < 4; k++) {
        final inner = (i == 1 || i == 2) && (k == 1 || k == 2);
        if (inner) continue;
        final area = Rect.fromLTRB(xs[i], ys[k], xe[i], ye[k]);
        final n = 2 + _r.nextInt(3);
        for (var b = 0; b < n; b++) {
          _tryBuilding(area, 160, 280, 130, 220, 110, 330);
        }
        for (var t = 0; t < 6; t++) {
          final x = _rand(area.left + 50, area.right - 50);
          final y = _rand(area.top + 50, area.bottom - 50);
          final roll = _r.nextDouble();
          final kind = roll < 0.45
              ? PropKind.tree
              : roll < 0.65
                  ? PropKind.deadTree
                  : roll < 0.85
                      ? PropKind.rock
                      : PropKind.debris;
          if (_free(x - 60, y - 40, x + 60, y + 40, 20)) _addProp(kind, x, y);
        }
      }
    }
  }

  void _buildRoadClutter() {
    // Wrecks and barriers placed on the roads, away from the start lane.
    final spots = <Offset>[
      const Offset(400, 680),
      const Offset(2500, 680),
      const Offset(1200, 2880),
      const Offset(3300, 1800),
      const Offset(680, 1250),
      const Offset(2900, 2400),
      const Offset(2900, 400),
      const Offset(1810, 300),
    ];
    for (var i = 0; i < spots.length; i++) {
      final p = spots[i];
      if (i.isEven) {
        _addProp(i % 4 == 0 ? PropKind.truckWreck : PropKind.tankWreck, p.dx, p.dy);
      } else {
        _addProp(PropKind.hedgehog, p.dx - 50, p.dy - 20);
        _addProp(PropKind.hedgehog, p.dx + 50, p.dy + 20);
      }
    }
    _addBox(1745, 1180, 1825, 1204, 46, BoxMaterial.concrete);
    _addBox(1800, 1000, 1880, 1024, 46, BoxMaterial.concrete);
    _addBox(1100, 1785, 1124, 1865, 46, BoxMaterial.concrete);
    _addBox(2450, 1735, 2474, 1815, 46, BoxMaterial.concrete);
  }

  void _buildBorders() {
    for (var x = 40.0; x < size; x += 150) {
      _addProp(_r.nextBool() ? PropKind.deadTree : PropKind.tree, x + _rand(-30, 30), 36, withHull: false);
      _addProp(PropKind.hedgehog, x + 70, size - 30, withHull: false);
    }
    for (var y = 120.0; y < size - 100; y += 160) {
      _addProp(_r.nextBool() ? PropKind.deadTree : PropKind.rock, 32, y + _rand(-30, 30), withHull: false);
      _addProp(_r.nextBool() ? PropKind.deadTree : PropKind.rock, size - 32, y + _rand(-30, 30), withHull: false);
    }
  }

  void _register(int index) {
    final b = boxes[index];
    const pad = 40.0;
    final c0 = ((b.x0 - pad) / cell).floor().clamp(0, cols - 1);
    final c1 = ((b.x1 + pad) / cell).floor().clamp(0, cols - 1);
    final r0 = ((b.y0 - pad) / cell).floor().clamp(0, cols - 1);
    final r1 = ((b.y1 + pad) / cell).floor().clamp(0, cols - 1);
    for (var r = r0; r <= r1; r++) {
      for (var c = c0; c <= c1; c++) {
        _grid[r * cols + c].add(index);
      }
    }
  }

  List<int> cellAt(double x, double y) {
    final c = (x / cell).floor().clamp(0, cols - 1);
    final r = (y / cell).floor().clamp(0, cols - 1);
    return _grid[r * cols + c];
  }

  // Result of [resolveCircle].
  double outX = 0;
  double outY = 0;

  /// Pushes a circle out of every overlapping block and keeps it in bounds.
  /// Returns true when a collision happened. The result is in [outX]/[outY].
  bool resolveCircle(double x, double y, double radius) {
    var px = x.clamp(margin, size - margin).toDouble();
    var py = y.clamp(margin, size - margin).toDouble();
    var hit = px != x || py != y;
    for (var iter = 0; iter < 2; iter++) {
      final list = cellAt(px, py);
      for (final i in list) {
        final b = boxes[i];
        final qx = px.clamp(b.x0, b.x1).toDouble();
        final qy = py.clamp(b.y0, b.y1).toDouble();
        final dx = px - qx;
        final dy = py - qy;
        final d2 = dx * dx + dy * dy;
        if (d2 >= radius * radius) continue;
        hit = true;
        if (d2 > 1e-6) {
          final d = math.sqrt(d2);
          px = qx + dx / d * radius;
          py = qy + dy / d * radius;
        } else {
          final left = px - b.x0;
          final right = b.x1 - px;
          final top = py - b.y0;
          final bottom = b.y1 - py;
          final m = math.min(math.min(left, right), math.min(top, bottom));
          if (m == left) {
            px = b.x0 - radius;
          } else if (m == right) {
            px = b.x1 + radius;
          } else if (m == top) {
            py = b.y0 - radius;
          } else {
            py = b.y1 + radius;
          }
        }
      }
    }
    outX = px;
    outY = py;
    return hit;
  }

  /// True when a circle at (x, y) overlaps no block and lies inside the map.
  bool isFree(double x, double y, double radius) {
    if (x < margin + radius || y < margin + radius || x > size - margin - radius || y > size - margin - radius) {
      return false;
    }
    for (final i in cellAt(x, y)) {
      final b = boxes[i];
      if (x > b.x0 - radius && x < b.x1 + radius && y > b.y0 - radius && y < b.y1 + radius) return false;
    }
    return true;
  }

  /// The block a bullet at height [z] collides with, if any.
  BoxObstacle? bulletBlocker(double x, double y, double z) {
    for (final i in cellAt(x, y)) {
      final b = boxes[i];
      if (!b.blocksBullets || b.height < z) continue;
      if (b.contains(x, y)) return b;
    }
    return null;
  }

  /// Samples the segment and reports whether a sight-blocking block is hit.
  bool sightBlocked(double x0, double y0, double x1, double y1) {
    final dx = x1 - x0;
    final dy = y1 - y0;
    final len = math.sqrt(dx * dx + dy * dy);
    final steps = (len / 45).ceil();
    for (var s = 1; s < steps; s++) {
      final t = s / steps;
      final x = x0 + dx * t;
      final y = y0 + dy * t;
      for (final i in cellAt(x, y)) {
        final b = boxes[i];
        if (b.blocksSight && b.height > 55 && b.contains(x, y)) return true;
      }
    }
    return false;
  }

  /// Returns the index of a visible block the probe point is inside (expanded
  /// by [pad]), or -1.
  int probe(double x, double y, double pad) {
    for (final i in cellAt(x, y)) {
      final b = boxes[i];
      if (x > b.x0 - pad && x < b.x1 + pad && y > b.y0 - pad && y < b.y1 + pad) return i;
    }
    return -1;
  }
}
