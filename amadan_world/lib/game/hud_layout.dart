import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Screen-space layout shared by the Flame HUD and the Flutter controls so
/// both always agree, on any resolution, aspect ratio or display cutout.
class HudLayout {
  HudLayout(this.size, EdgeInsets padding) {
    final w = size.width;
    final h = size.height;
    unit = math.min(h, w * 0.56);
    left = math.max(padding.left, 10.0) + 6;
    right = w - math.max(padding.right, 10.0) - 6;
    top = math.max(padding.top, 6.0) + 6;
    bottom = h - math.max(padding.bottom, 6.0) - 6;

    final m = (unit * 0.3).clamp(92.0, 172.0);
    minimap = Rect.fromLTWH(right - m, top, m, m);
    final p = (unit * 0.1).clamp(38.0, 52.0);
    pauseButton = Rect.fromLTWH(minimap.left - 12 - p, top, p, p);
    final panelW = (w * 0.27).clamp(170.0, 300.0);
    statusPanel = Rect.fromLTWH(left, top, panelW, (unit * 0.23).clamp(70.0, 118.0));

    fireRadius = (unit * 0.12).clamp(40.0, 66.0);
    fireCenter = Offset(right - fireRadius - unit * 0.03, bottom - fireRadius - unit * 0.04);
    aimRadius = fireRadius * 0.64;
    aimCenter = Offset(fireCenter.dx - fireRadius - aimRadius - unit * 0.035, fireCenter.dy + fireRadius * 0.22);
    reloadRadius = fireRadius * 0.56;
    reloadCenter = Offset(fireCenter.dx - fireRadius * 1.05 - reloadRadius * 0.4,
        fireCenter.dy - fireRadius - reloadRadius - unit * 0.025);
    sprintRadius = fireRadius * 0.56;
    sprintCenter = Offset(fireCenter.dx + fireRadius * 0.25, fireCenter.dy - fireRadius - sprintRadius - unit * 0.09);

    final ammoW = (unit * 0.36).clamp(110.0, 180.0);
    final ammoH = (unit * 0.13).clamp(44.0, 64.0);
    ammoPanel = Rect.fromLTWH(aimCenter.dx - aimRadius - 14 - ammoW, bottom - ammoH, ammoW, ammoH);

    joystickRadius = (unit * 0.15).clamp(50.0, 86.0);
    joystickZone = Rect.fromLTRB(0, h * 0.28, math.min(w * 0.44, ammoPanel.left - 8), h);
    joystickRest = Offset(left + joystickRadius + unit * 0.05, bottom - joystickRadius - unit * 0.05);
  }

  final Size size;
  late final double unit;
  late final double left;
  late final double right;
  late final double top;
  late final double bottom;
  late final Rect minimap;
  late final Rect pauseButton;
  late final Rect statusPanel;
  late final Rect ammoPanel;
  late final double fireRadius;
  late final Offset fireCenter;
  late final double aimRadius;
  late final Offset aimCenter;
  late final double reloadRadius;
  late final Offset reloadCenter;
  late final double sprintRadius;
  late final Offset sprintCenter;
  late final double joystickRadius;
  late final Rect joystickZone;
  late final Offset joystickRest;
}
