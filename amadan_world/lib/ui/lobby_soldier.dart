import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../entities/soldier_rig.dart';
import '../utils/asset_paths.dart';
import '../utils/image_store.dart';
import '../weapons/weapon_data.dart';

/// The large animated soldier shown in the lobby. It breathes, shifts its
/// weight, slowly turns and racks the newly selected weapon.
class LobbySoldier extends StatefulWidget {
  const LobbySoldier({super.key, required this.weapon});

  final WeaponSpec weapon;

  @override
  State<LobbySoldier> createState() => _LobbySoldierState();
}

class _LobbySoldierState extends State<LobbySoldier> with SingleTickerProviderStateMixin {
  late final AnimationController _clock =
      AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();
  final SoldierRenderer _renderer = SoldierRenderer();
  final RigPose _pose = RigPose();
  double _switchStart = -10;

  late final RigLook _look = RigLook(
    uniform: const Color(0xFF4E5A3A),
    vest: const Color(0xFF3A4230),
    skin: const Color(0xFFC4946E),
    helmet: const Color(0xFF4A5436),
    gear: const Color(0xFF3E4230),
    boots: const Color(0xFF231F1A),
    gloves: const Color(0xFF2A2822),
    headGear: HeadGear.helmet,
    camo: ImageStore.tryGet(AssetPaths.camoPlayer),
    visor: const Color(0xFF1A1C1E),
  );

  @override
  void didUpdateWidget(covariant LobbySoldier oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weapon.type != widget.weapon.type) {
      _switchStart = _clock.value * 120;
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SoldierPainter(this),
        size: Size.infinite,
      ),
    );
  }
}

class _SoldierPainter extends CustomPainter {
  _SoldierPainter(this.state) : super(repaint: state._clock);

  final _LobbySoldierState state;

  static final Paint _spot = Paint();
  static final Paint _shadow = Paint()..color = const Color(0x88000000);

  @override
  void paint(Canvas canvas, Size size) {
    final t = state._clock.value * 120;
    final pose = state._pose;
    pose.time = t;
    pose.move = 0;
    pose.sprint = 0;
    pose.facing = 0.42 + math.sin(t * 0.35) * 0.22;
    pose.aim = 0.2 + 0.2 * (0.5 + 0.5 * math.sin(t * 0.21));
    final since = t - state._switchStart;
    pose.reload = since >= 0 && since < 0.9 ? since / 0.9 : -1;
    pose.recoil = 0;
    pose.hit = 0;
    pose.death = 0;

    final feet = Offset(size.width * 0.5, size.height * 0.9);
    final scale = size.height * 0.8 / 80;

    _spot.shader = RadialGradient(
      colors: const [Color(0x66FFB060), Color(0x22FF8030), Color(0x00000000)],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCenter(center: feet, width: scale * 120, height: scale * 34));
    canvas.drawOval(Rect.fromCenter(center: feet, width: scale * 120, height: scale * 34), _spot);
    canvas.drawOval(Rect.fromCenter(center: feet, width: scale * 42, height: scale * 10), _shadow);

    canvas.save();
    canvas.translate(feet.dx, feet.dy);
    canvas.scale(scale, scale);
    state._renderer.draw(canvas, pose, state._look, state.widget.weapon.model, detailed: true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SoldierPainter oldDelegate) => false;
}
