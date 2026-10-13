import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../art/dragon_art.dart';
import '../../models/dragon_model.dart';
import '../game_config.dart';
import '../input_state.dart';
import 'environment_component.dart';

/// Events the dragon reports to the game (sounds, particles, stats).
enum DragonEvent { jumped, landed, flightStarted, flightEnded, sprintStarted, sprintEnded, fellInGap }

/// The player's dragon: movement physics, meters, timers and rendering.
class DragonComponent extends Component {
  DragonComponent(this.def, {super.priority});

  final DragonDef def;
  final DragonPose pose = DragonPose();

  double x = 300;
  double y = GameConfig.groundY;
  double vy = 0;
  bool grounded = true;
  double _coyote = 0;
  double _jumpBuffer = 0;

  bool flying = false;
  double energy = GameConfig.maxFlightEnergy;
  double _energyDelay = 0;
  double get maxEnergy => GameConfig.maxFlightEnergy * def.flightCapacity;

  bool sprinting = false;
  double stamina = GameConfig.maxStamina;
  double _staminaDelay = 0;

  double attackCooldown = 0;
  double specialCooldown = 0;

  int health = GameConfig.maxHealth;
  double invulnerable = 0;
  double waterShield = 0;
  double natureShield = 0;
  int natureHits = 0;
  double dash = 0;
  double hurtT = 0;
  bool dead = false;
  double deadT = 0;

  /// Rescue hover after falling into a gap.
  double rescue = 0;
  double _mouth = 0;
  double _land = 0;
  double _blinkT = 2;
  double _time = 0;
  double maxX = 700;
  double minX = GameConfig.minPlayerX;
  double startX = 300;
  double _trailT = 0;
  final List<Offset> _afterImages = [];

  final List<DragonEvent> events = [];

  bool get shielded => waterShield > 0 || dash > 0;
  bool get canBeHurt => !dead && invulnerable <= 0 && !shielded;

  /// Hitbox in world units (smaller than the art for fairness).
  Rect get hitbox {
    final h = flying || !grounded ? 70.0 : 82.0;
    return Rect.fromLTWH(x - 34, y - h - 8, 82, h);
  }

  Offset get mouth => Offset(x + 78 * GameConfig.dragonScale, y - 100 * GameConfig.dragonScale);

  void reset() {
    x = startX;
    y = GameConfig.groundY;
    vy = 0;
    grounded = true;
    flying = false;
    sprinting = false;
    energy = maxEnergy;
    stamina = GameConfig.maxStamina;
    attackCooldown = 0;
    specialCooldown = 0;
    health = GameConfig.maxHealth;
    invulnerable = 0;
    waterShield = natureShield = dash = 0;
    natureHits = 0;
    dead = false;
    deadT = 0;
    rescue = 0;
    events.clear();
  }

  void triggerMouth([double t = 0.3]) => _mouth = t;

  void step(double dt, InputState input, GroundComponent ground) {
    _time += dt;
    events.clear();
    if (dead) {
      deadT += dt;
      vy += GameConfig.gravity * 0.6 * dt;
      y = math.min(y + vy * dt, GameConfig.groundY + (ground.solidAt(x) ? 0 : 400));
      _pose(dt);
      return;
    }
    // timers
    if (invulnerable > 0) invulnerable -= dt;
    if (waterShield > 0) waterShield -= dt;
    if (natureShield > 0) {
      natureShield -= dt;
      if (natureShield <= 0) natureHits = 0;
    }
    if (dash > 0) dash -= dt;
    if (hurtT > 0) hurtT -= dt;
    if (attackCooldown > 0) attackCooldown -= dt;
    if (specialCooldown > 0) specialCooldown -= dt;
    if (_mouth > 0) _mouth -= dt;
    if (_land > 0) _land -= dt;

    // horizontal movement
    x += input.horizontal * GameConfig.moveSpeed * dt;
    x = x.clamp(minX, maxX);

    // sprint toggle
    if (input.consumeSprint()) {
      if (sprinting) {
        sprinting = false;
        events.add(DragonEvent.sprintEnded);
      } else if (stamina >= GameConfig.sprintMinStamina) {
        sprinting = true;
        events.add(DragonEvent.sprintStarted);
      }
    }
    if (sprinting) {
      stamina -= GameConfig.staminaDrain * dt;
      _staminaDelay = GameConfig.staminaRegenDelay;
      if (stamina <= 0) {
        stamina = 0;
        sprinting = false;
        events.add(DragonEvent.sprintEnded);
      }
    } else {
      if (_staminaDelay > 0) {
        _staminaDelay -= dt;
      } else {
        stamina = math.min(GameConfig.maxStamina, stamina + GameConfig.staminaRegen * dt);
      }
    }

    // flight toggle
    if (input.consumeFly()) {
      if (flying) {
        _endFlight();
      } else if (energy >= GameConfig.flightMinStart && rescue <= 0) {
        flying = true;
        grounded = false;
        events.add(DragonEvent.flightStarted);
      }
    }

    if (input.consumeJump()) _jumpBuffer = GameConfig.jumpBuffer;
    if (_jumpBuffer > 0) _jumpBuffer -= dt;

    final solidBelow = !ground.spanOverGap(x - 22, x + 30);

    if (rescue > 0) {
      // magical rescue bubble lifting the dragon back up after a fall
      rescue -= dt;
      // keep hovering until there is solid ground below to land on
      if (rescue <= 0 && !ground.solidAt(x)) rescue = 0.15;
      final targetY = GameConfig.flightCruiseY + 80;
      y += (targetY - y) * math.min(1, dt * 4);
      vy = 0;
      grounded = false;
    } else if (flying) {
      energy -= GameConfig.flightDrain * dt;
      _energyDelay = GameConfig.flightRegenDelay;
      final targetY = GameConfig.flightCruiseY;
      final dy = targetY - y;
      vy = dy.sign * math.min(dy.abs() * 6, GameConfig.flightRiseSpeed);
      y += vy * dt;
      if (energy <= 0) {
        energy = 0;
        _endFlight();
      }
    } else {
      if (grounded) {
        _coyote = GameConfig.coyoteTime;
      } else if (_coyote > 0) {
        _coyote -= dt;
      }
      if (_jumpBuffer > 0 && (grounded || _coyote > 0)) {
        vy = -GameConfig.jumpVelocity;
        grounded = false;
        _coyote = 0;
        _jumpBuffer = 0;
        events.add(DragonEvent.jumped);
      }
      // gliding after flight: gentler gravity while descending
      final g = (!grounded && vy > 0 && pose.wingSpread > 0.6) ? GameConfig.gravity * 0.55 : GameConfig.gravity;
      vy += g * dt;
      y += vy * dt;
      if (y >= GameConfig.groundY && solidBelow && vy >= 0 && y - vy * dt <= GameConfig.groundY + 6) {
        if (!grounded) {
          events.add(DragonEvent.landed);
          _land = 0.18;
        }
        y = GameConfig.groundY;
        vy = 0;
        grounded = true;
      } else if (grounded && !solidBelow) {
        grounded = false;
      } else if (y > GameConfig.groundY + 2) {
        grounded = false;
      }
      if (y > GameConfig.worldHeight + 60) {
        events.add(DragonEvent.fellInGap);
      }
    }
    if (!flying && rescue <= 0 && energy < maxEnergy) {
      if (_energyDelay > 0) {
        _energyDelay -= dt;
      } else if (grounded) {
        energy = math.min(maxEnergy, energy + GameConfig.flightRegen * dt);
      }
    }
    _pose(dt);
  }

  void _endFlight() {
    flying = false;
    vy = 0;
    events.add(DragonEvent.flightEnded);
  }

  /// Lifts the dragon back to safety after falling into a gap.
  void startRescue() {
    flying = false;
    sprinting = false;
    rescue = 1.3;
    y = GameConfig.worldHeight + 20;
    vy = 0;
    invulnerable = math.max(invulnerable, 2.2);
  }

  void _pose(double dt) {
    final p = pose;
    p.time = _time;
    p.breath += dt * 3;
    final airborne = !grounded;
    final runTarget = dead ? 0.0 : (grounded ? 1.0 : 0.0);
    p.runAmount += (runTarget - p.runAmount) * math.min(1, dt * 10);
    p.runPhase = (p.runPhase + dt * (sprinting ? 3.4 : 2.4)) % 1.0;
    final spreadTarget = flying || rescue > 0 ? 1.0 : (airborne ? (vy > 0 ? 0.85 : 0.6) : 0.2);
    p.wingSpread += (spreadTarget - p.wingSpread) * math.min(1, dt * 8);
    p.flapAmount = flying || rescue > 0 ? 0.55 : (airborne ? 0.3 : 0.12);
    p.flapPhase += dt * (flying ? 13 : (airborne ? 9 : (sprinting ? 9 : 5)));
    p.tuck += ((airborne ? 1.0 : 0.0) - p.tuck) * math.min(1, dt * 10);
    p.mouthOpen += ((_mouth > 0 ? 1.0 : 0.0) - p.mouthOpen) * math.min(1, dt * 18);
    final tiltTarget = dead
        ? 0.4
        : flying
        ? -0.05 + math.sin(_time * 3) * 0.04
        : (airborne ? (vy.clamp(-900.0, 900.0) / 900) * 0.18 : (sprinting ? 0.08 : 0.02));
    p.tilt += (tiltTarget - p.tilt) * math.min(1, dt * 8);
    p.squash = _land > 0 ? 1 - _land * 0.6 : (airborne && vy < 0 ? 1.05 : 1.0);
    p.flash = hurtT > 0 ? (hurtT / 0.25).clamp(0.0, 1.0) : 0;
    p.dizzy = dead;
    p.glow = (waterShield > 0 || natureShield > 0 || dash > 0) ? 1 : 0;
    _blinkT -= dt;
    if (_blinkT < 0) {
      p.blink = 1;
      if (_blinkT < -0.12) {
        _blinkT = 2 + math.Random().nextDouble() * 3;
        p.blink = 0;
      }
    }
    if (dash > 0) {
      _trailT -= dt;
      if (_trailT <= 0) {
        _trailT = 0.04;
        _afterImages.add(Offset(x, y));
        if (_afterImages.length > 5) _afterImages.removeAt(0);
      }
    } else if (_afterImages.isNotEmpty) {
      _afterImages.clear();
    }
  }

  final Paint _p = Paint()..isAntiAlias = true;
  final Paint _s = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  /// Draws the ground shadow. Called by the game before entities so the
  /// shadow sits under obstacles too.
  void renderShadow(Canvas canvas, GroundComponent ground) {
    if (!ground.solidAt(x)) return;
    final h = (GameConfig.groundY - y).clamp(0.0, 400.0);
    final k = 1 - h / 500;
    _p.color = Color.fromRGBO(20, 40, 20, 0.28 * k);
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 6, GameConfig.groundY + 3), width: 120 * k, height: 18 * k), _p);
  }

  @override
  void render(Canvas canvas) {
    final blinkHide = invulnerable > 0 && !dead && hurtT <= 0 && rescue <= 0 && ((invulnerable * 12).floor() % 2 == 0);
    // sprint speed lines
    if (sprinting && !dead) {
      _s
        ..color = const Color(0x88FFFFFF)
        ..strokeWidth = 3;
      for (var i = 0; i < 4; i++) {
        final yy = y - 30 - i * 24 + math.sin(_time * 30 + i) * 4;
        final len = 60.0 + (i % 2) * 30;
        final xx = x - 90 - ((_time * 900 + i * 50) % 120);
        canvas.drawLine(Offset(xx, yy), Offset(xx - len, yy), _s);
      }
    }
    for (var i = 0; i < _afterImages.length; i++) {
      final o = _afterImages[i];
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.saveLayer(const Rect.fromLTWH(-160, -200, 320, 220), Paint()..color = Color.fromRGBO(0, 0, 0, 0.12 + i * 0.05));
      DragonArt.paint(canvas, def, pose, scale: GameConfig.dragonScale);
      canvas.restore();
      canvas.restore();
    }
    if (rescue > 0) {
      _p.color = const Color(0x5590E0FF);
      canvas.drawCircle(Offset(x, y - 60), 90, _p);
    }
    if (!blinkHide) {
      canvas.save();
      canvas.translate(x, y);
      DragonArt.paint(canvas, def, pose, scale: GameConfig.dragonScale);
      canvas.restore();
    }
    // shields
    final c = Offset(x + 6, y - 58);
    if (waterShield > 0) {
      final fade = waterShield < 1 ? (math.sin(_time * 30) * 0.5 + 0.5) : 1.0;
      _p.shader = Gradient.radial(c, 100, [const Color(0x00BFF7FF), Color.fromRGBO(80, 200, 255, 0.45 * fade)]);
      canvas.drawCircle(c, 100, _p);
      _p.shader = null;
      _s
        ..color = Color.fromRGBO(220, 250, 255, 0.9 * fade)
        ..strokeWidth = 3;
      canvas.drawCircle(c, 100, _s);
      canvas.drawArc(Rect.fromCircle(center: c, radius: 80), -2.6, 0.9, false, _s);
    }
    if (natureShield > 0) {
      final fade = natureShield < 1.2 ? (math.sin(_time * 30) * 0.5 + 0.5) : 1.0;
      _s
        ..color = Color.fromRGBO(90, 200, 80, 0.9 * fade)
        ..strokeWidth = 7;
      canvas.drawCircle(c, 92, _s);
      _p.color = Color.fromRGBO(160, 255, 120, 0.85 * fade);
      for (var i = 0; i < 8; i++) {
        final a = _time * 1.5 + i * math.pi / 4;
        final pos = c + Offset(math.cos(a) * 92, math.sin(a) * 92);
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(a);
        canvas.drawOval(const Rect.fromLTWH(-12, -6, 24, 12), _p);
        canvas.restore();
      }
      if (natureHits > 1) {
        _s
          ..color = Color.fromRGBO(255, 220, 90, 0.7 * fade)
          ..strokeWidth = 3;
        canvas.drawCircle(c, 104, _s);
      }
    }
  }
}
