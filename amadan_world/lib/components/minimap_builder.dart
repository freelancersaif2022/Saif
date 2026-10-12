import 'dart:ui';

import '../systems/battle_map.dart';

/// Pixel size of the pre-rendered tactical map.
const int minimapImageSize = 400;

/// Renders the static battlefield layout (zones, roads, blocks, props) once
/// so the HUD mini-map only has to blit a region of it each frame.
Future<Image> buildMinimapImage(BattleMap map) async {
  const s = minimapImageSize / BattleMap.size;
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(s, s);
  canvas.drawRect(const Rect.fromLTWH(0, 0, BattleMap.size, BattleMap.size), Paint()..color = const Color(0xFF1C1F18));

  final zoneFill = Paint();
  final zoneStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 14;
  for (final z in map.zones) {
    zoneFill.color = z.color.withAlpha(46);
    zoneStroke.color = z.color.withAlpha(150);
    canvas.drawRect(z.rect, zoneFill);
    canvas.drawRect(z.rect.deflate(7), zoneStroke);
  }

  final road = Paint()..color = const Color(0xFF4C4A44);
  for (final r in map.roads) {
    canvas.drawRect(r.rect, road);
  }

  final building = Paint()..color = const Color(0xFF0E0F0E);
  final buildingEdge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8
    ..color = const Color(0xFF6E6E66);
  final low = Paint()..color = const Color(0xFF8A7C5C);
  final crate = Paint()..color = const Color(0xFF5E6A3E);
  for (final b in map.boxes) {
    if (!b.visible) continue;
    final rect = Rect.fromLTRB(b.x0, b.y0, b.x1, b.y1);
    switch (b.material) {
      case BoxMaterial.building:
        canvas.drawRect(rect, building);
        canvas.drawRect(rect, buildingEdge);
        break;
      case BoxMaterial.crate:
        canvas.drawRect(rect, crate);
        break;
      case BoxMaterial.sandbag:
      case BoxMaterial.concrete:
        canvas.drawRect(rect.inflate(6), low);
        break;
    }
  }

  final tree = Paint()..color = const Color(0xFF34442A);
  final wreck = Paint()..color = const Color(0xFF3A3026);
  for (final p in map.props) {
    switch (p.kind) {
      case PropKind.tree:
      case PropKind.deadTree:
        canvas.drawCircle(Offset(p.x, p.y), 34, tree);
        break;
      case PropKind.tankWreck:
      case PropKind.truckWreck:
        canvas.drawRect(Rect.fromCenter(center: Offset(p.x, p.y), width: 240, height: 100), wreck);
        break;
      case PropKind.rock:
        canvas.drawCircle(Offset(p.x, p.y), 40, wreck);
        break;
      case PropKind.hedgehog:
      case PropKind.barrel:
      case PropKind.debris:
        break;
    }
  }
  final border = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 30
    ..color = const Color(0xFF7A2A1E);
  canvas.drawRect(const Rect.fromLTWH(15, 15, BattleMap.size - 30, BattleMap.size - 30), border);

  final picture = recorder.endRecording();
  final image = await picture.toImage(minimapImageSize, minimapImageSize);
  picture.dispose();
  return image;
}
