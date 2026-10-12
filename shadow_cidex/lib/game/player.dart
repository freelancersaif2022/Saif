import 'dart:math' as math;
import 'dart:ui';

import '../audio.dart';
import '../core/utils.dart';
import '../render/humanoid.dart';
import 'battle.dart';

enum PState { idle, run, air, attack, smash, hurt, dead }

/// The Shadow Warrior.
class Player {
  Player(this.b, this.x);

  final Battle b;
  double x;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double facing = 1;
  bool onGround = true;
  int airJumps = 1;
  double health = maxHealth;
  static const double maxHealth = 100;

  PState state = PState.idle;
  double st = 0;
  final Pose pose = Pose();
  final Pose _target = Pose();
  final Skeleton skel = Skeleton();

  static const HumanoidStyle style = HumanoidStyle(
    height: 150,
    headband: true,
    bandColor: Color(0xFF9A1424),
    eye: Color(0xFF8FE6FF),
    eyeGlow: 0.9,
    rim: Color(0xFF9AB8E0),
    rimStrength: 0.7,
    bladeColor: Color(0xFFD8E8FF),
    bladeGlow: Color(0xFF5FB8FF),
  );

  double walkPhase = 0;
  double invuln = 0;
  double flash = 0;
  double powerCharge = 1;
  static const double powerReload = 5;
  double _coyote = 0;
  double _jumpBuffer = 0;
  int combo = 0;
  bool _queued = false;
  final Set<Object> _hitSet = <Object>{};
  int _smashPhase = 0;
  double _footT = 0;
  double _fallSpeed = 0;
  double alpha = 1;
  bool _deathReported = false;
  final List<Offset> _trailBase = [];
  final List<Offset> _trailTip = [];

  bool get alive => state != PState.dead;
  Rect get box => Rect.fromLTRB(x - 20, y - 146, x + 20, y);

  static const List<double> _comboDur = [0.34, 0.34, 0.44];
  static const List<double> _activeStart = [0.08, 0.08, 0.12];
  static const List<double> _activeEnd = [0.2, 0.2, 0.26];
  static const List<double> _comboDmg = [17, 17, 28];
  static const List<double> _comboKnock = [220, 240, 520];

  // ------------------------------------------------------------------ update

  void update(double dt) {
    st += dt;
    invuln = math.max(0, invuln - dt);
    flash = math.max(0, flash - dt * 5);
    if (powerCharge < 1) {
      powerCharge = math.min(1, powerCharge + dt / powerReload);
    }
    final input = b.input;
    final locked = b.controlsLocked || state == PState.dead;
    final moveX = locked ? 0.0 : input.moveX;
    final wantJump = !locked && input.jump;
    final wantAttack = !locked && input.attack;
    final wantPower = !locked && input.power;
    input.jump = false;
    input.attack = false;
    input.power = false;

    if (wantJump) _jumpBuffer = 0.14;
    _jumpBuffer = math.max(0, _jumpBuffer - dt);
    _coyote = onGround ? 0.1 : math.max(0, _coyote - dt);

    switch (state) {
      case PState.dead:
        _updateDead(dt);
        break;
      case PState.hurt:
        vx *= math.max(0, 1 - 6 * dt);
        if (st > 0.32) _toMove();
        break;
      case PState.smash:
        _updateSmash(dt);
        break;
      case PState.attack:
        _updateAttack(dt, moveX, wantAttack);
        if (_jumpBuffer > 0 && st > _activeEnd[combo]) _tryJump();
        break;
      case PState.idle:
      case PState.run:
      case PState.air:
        final targetV = moveX * 390;
        vx += (targetV - vx) * smoothK(onGround ? 16 : 8, dt);
        if (moveX.abs() > 0.15) facing = moveX > 0 ? 1 : -1;
        if (_jumpBuffer > 0) _tryJump();
        if (wantAttack) _startAttack(0);
        if (wantPower && powerCharge >= 1) _startSmash();
        if (state != PState.attack && state != PState.smash) {
          state = !onGround ? PState.air : (vx.abs() > 30 ? PState.run : PState.idle);
        }
        break;
    }
    if (wantPower && powerCharge >= 1 && (state == PState.attack || state == PState.hurt) && alive) {
      _startSmash();
    }

    _physics(dt);
    _animate(dt);
    _footsteps(dt);
    _attackHits();
  }

  void _toMove() {
    state = onGround ? PState.idle : PState.air;
    st = 0;
  }

  void _tryJump() {
    if (onGround || _coyote > 0) {
      vy = -990;
      onGround = false;
      _coyote = 0;
      _jumpBuffer = 0;
      if (state == PState.attack) state = PState.air;
      b.sfx(Sfx.jump, volume: 0.7);
      b.fx.dust(x, y, n: 5, power: 0.6);
    } else if (airJumps > 0) {
      airJumps--;
      vy = -880;
      _jumpBuffer = 0;
      if (state == PState.attack) state = PState.air;
      b.sfx(Sfx.jump, volume: 0.6);
      b.fx.shadowBurst(x, y - 10, n: 8, spread: 0.7);
      b.ring(x, y - 6, 60, 0.35, const Color(0xFF8FB8FF), 3);
    }
  }

  void _startAttack(int step) {
    state = PState.attack;
    st = 0;
    combo = step;
    _queued = false;
    _hitSet.clear();
    _trailBase.clear();
    _trailTip.clear();
    if (onGround) vx = facing * (step == 2 ? 300 : 170);
    b.sfx(Sfx.swordSwing, volume: 0.75, gap: 30);
  }

  void _updateAttack(double dt, double moveX, bool wantAttack) {
    if (moveX.abs() > 0.3 && st < 0.05) facing = moveX > 0 ? 1 : -1;
    vx *= math.max(0, 1 - (onGround ? 9 : 2) * dt);
    if (!onGround) vx += (moveX * 300 - vx) * smoothK(4, dt);
    if (wantAttack && st > _activeStart[combo]) _queued = true;
    if (st >= _comboDur[combo]) {
      if (_queued && combo < 2) {
        _startAttack(combo + 1);
      } else {
        _toMove();
        combo = 0;
      }
    }
  }

  void _startSmash() {
    powerCharge = 0;
    state = PState.smash;
    st = 0;
    _smashPhase = 0;
    _hitSet.clear();
    vy = onGround ? -560 : math.min(vy, -260);
    onGround = false;
    vx = facing * 120;
    b.sfx(Sfx.powerUp, volume: 1.0);
    b.fx.energy(x, y - 80, n: 26, color: const Color(0xFF6FB6FF), speed: 260);
  }

  void _updateSmash(double dt) {
    if (_smashPhase == 0 && st > 0.3) {
      _smashPhase = 1;
      vy = 1700;
    }
    if (_smashPhase == 1 && (onGround || st > 0.9)) {
      _smashPhase = 2;
      st = 0;
      _smashImpact();
    }
    if (_smashPhase == 2 && st > 0.32) {
      _toMove();
    }
  }

  void _smashImpact() {
    vx = 0;
    b.addShake(0.85);
    b.hitStop(0.07);
    b.flashWhite = math.max(b.flashWhite, 0.35);
    b.ring(x, y - 4, 320, 0.55, const Color(0xFF7FC0FF), 10);
    b.ring(x, y - 4, 200, 0.4, const Color(0xFFB09CFF), 6);
    b.ring(x, y - 70, 160, 0.4, const Color(0xFF7FC0FF), 4, flat: 1);
    b.fx.energy(x, y - 30, n: 50, color: const Color(0xFF7FC0FF), speed: 620);
    b.fx.dust(x, y, n: 18, power: 1.6);
    b.fx.debris(x, y, n: 12);
    b.fx.shadowBurst(x, y - 40, n: 18, spread: 1.4);
    for (final h in b.hittables().toList()) {
      final r = h.hurtBox;
      final dx = (r.center.dx - x).abs() - r.width / 2;
      if (dx <= 300 && r.bottom > y - 460 && r.top < y + 40) {
        final dir = r.center.dx >= x ? 1.0 : -1.0;
        h.receiveHit(58, dir, 620, heavy: true);
        b.fx.hitSparks(r.center.dx, r.center.dy, dir, n: 14, color: const Color(0xFF9FD0FF));
      }
    }
    for (final p in b.projectiles) {
      if (p.destructible && (p.x - x).abs() < 300 && p.y > y - 380) {
        p.destroy();
      }
    }
    for (final h in b.hazards) {
      if (h.smashable && (h.x - x).abs() < 300) h.shatter();
    }
  }

  void _physics(double dt) {
    if (state == PState.dead && onGround) {
      vx *= math.max(0, 1 - 5 * dt);
    }
    final prevY = y;
    var g = 2500.0;
    if (state == PState.attack && !onGround) g = 1500;
    vy = math.min(vy + g * dt, 1900);
    x += vx * dt;
    y += vy * dt;
    x = clampD(x, 30, b.cfg.length - 30);
    final wasGround = onGround;
    final land = vy >= 0 ? b.landingY(x, 40, prevY, y) : null;
    if (land != null) {
      y = land;
      if (!wasGround) {
        _fallSpeed = vy;
        if (_fallSpeed > 500) {
          b.sfx(Sfx.land, volume: clampD(_fallSpeed / 1500, 0.3, 0.8));
          b.fx.dust(x, y, n: 6, power: 0.7);
        }
      }
      vy = 0;
      onGround = true;
      airJumps = 1;
    } else if (onGround && !b.supportedAt(x, 40, y)) {
      onGround = false;
    } else if (!onGround) {
      onGround = false;
    }
    if (y < -1 && vy == 0 && !b.supportedAt(x, 40, y)) onGround = false;
  }

  void _footsteps(double dt) {
    if (!onGround || state != PState.run) {
      _footT = 0.12;
      return;
    }
    _footT -= dt;
    if (_footT <= 0) {
      _footT = 0.29;
      b.sfx(Sfx.footstep, volume: 0.45, gap: 120);
      if (rng.nextDouble() < 0.5) b.fx.dust(x - facing * 10, y, n: 2, power: 0.4);
    }
  }

  void _attackHits() {
    if (state != PState.attack) return;
    final s = _activeStart[combo];
    final e = _activeEnd[combo];
    if (st < s || st > e) return;
    final reach = combo == 2 ? 150.0 : 135.0;
    final top = y - (combo == 1 ? 210 : 175);
    final hb = facing > 0 ? Rect.fromLTRB(x - 10, top, x + reach, y + 10) : Rect.fromLTRB(x - reach, top, x + 10, y + 10);
    var any = false;
    for (final h in b.hittables().toList()) {
      if (_hitSet.contains(h)) continue;
      final r = h.hurtBox;
      if (!r.overlaps(hb)) continue;
      _hitSet.add(h);
      any = true;
      final hit = r.intersect(hb);
      h.receiveHit(_comboDmg[combo], facing, _comboKnock[combo], heavy: combo == 2);
      b.fx.hitSparks(hit.center.dx, hit.center.dy, facing, n: combo == 2 ? 14 : 9);
      b.fx.shadowBurst(hit.center.dx, hit.center.dy, n: 5, spread: 0.6);
    }
    if (any) {
      b.sfx(Sfx.swordHit, volume: 0.85, gap: 30);
      b.hitStop(combo == 2 ? 0.07 : 0.045);
      b.addShake(combo == 2 ? 0.3 : 0.16);
    }
    for (final h in b.hazards) {
      if (h.smashable && hb.contains(Offset(h.x, h.y - 20))) h.shatter();
    }
  }

  // ------------------------------------------------------------------ damage

  void damage(double dmg, double fromX, {double knock = 320, double lift = 0}) {
    if (!alive || invuln > 0 || b.state == BattleState.complete || b.state == BattleState.finished) return;
    health -= dmg;
    flash = 1;
    invuln = 0.75;
    b.flashRed = 1;
    b.addShake(0.35 + math.min(0.4, dmg / 60));
    b.sfx(Sfx.playerHurt, volume: 0.85);
    b.fx.shadowBurst(x, y - 80, n: 8, spread: 0.8, color: const Color(0xFF14080C));
    final dir = x >= fromX ? 1.0 : -1.0;
    if (health <= 0) {
      health = 0;
      _die(dir);
      return;
    }
    if (state != PState.smash) {
      state = PState.hurt;
      st = 0;
      vx = dir * knock;
      if (lift > 0) {
        vy = -lift;
        onGround = false;
      }
      facing = -dir;
    }
  }

  void heal(double amount) {
    if (!alive) return;
    health = math.min(maxHealth, health + amount);
  }

  void _die(double dir) {
    state = PState.dead;
    st = 0;
    vx = dir * 260;
    vy = math.min(vy, -320);
    onGround = false;
    facing = -dir;
    b.sfx(Sfx.playerDeath, volume: 1.0);
    b.slowMotion(1.0, 0.35);
    b.addShake(0.6);
  }

  void _updateDead(double dt) {
    if (st > 1.3) {
      alpha = math.max(0, 1 - (st - 1.3) / 1.0);
      if (alpha > 0) {
        b.fx.disintegrate(Rect.fromLTRB(x - 70, y - 40, x + 70, y), n: 3, glow: const Color(0xFF8FE6FF));
      }
    }
    if (st > 2.6 && !_deathReported) {
      _deathReported = true;
      b.playerDeathFinished();
    }
  }

  // ------------------------------------------------------------------ animation

  void _animate(double dt) {
    var rate = 16.0;
    switch (state) {
      case PState.idle:
        _target.idle(b.time);
        break;
      case PState.run:
        final speed = vx.abs();
        walkPhase += dt * (5 + speed / 38);
        _target.walk(walkPhase, clampD(speed / 300, 0.3, 1), run: speed > 220);
        rate = 20;
        break;
      case PState.air:
        if (vy < 0) {
          _target.jump();
        } else {
          _target.fall();
        }
        rate = 12;
        break;
      case PState.attack:
        final t = st;
        final s = _activeStart[combo];
        final e = _activeEnd[combo];
        final k = t < s ? 0.0 : clampD((t - s) / (e - s), 0, 1);
        switch (combo) {
          case 0:
            if (t < s) {
              _target.windUp(clampD(t / s, 0, 1));
            } else {
              _target.slashDown(k);
            }
            break;
          case 1:
            _target.slashUp(t < s ? 0 : k);
            break;
          default:
            _target.thrust(t < s ? 0 : k);
        }
        rate = 38;
        break;
      case PState.smash:
        if (_smashPhase < 2) {
          _target.windUp(1);
          _target.fThigh = 1.0;
          _target.bThigh = 0.3;
          _target.bShin = -0.6;
        } else {
          _target.smashImpact();
        }
        rate = 30;
        break;
      case PState.hurt:
        _target.hurt();
        rate = 26;
        break;
      case PState.dead:
        _target.collapsed(clampD(st / 0.7, 0, 1));
        _target.rot = -1.45 * easeOutCubic(clampD(st / 0.8, 0, 1));
        rate = 12;
        break;
    }
    pose.blend(_target, smoothK(rate, dt));
    skel.compute(pose, style);
    // Blade trail while swinging.
    if (state == PState.attack || (state == PState.smash && _smashPhase == 1)) {
      _trailBase.add(_world(skel.fHand + skel.wDir * 10));
      _trailTip.add(_world(skel.wTip));
      if (_trailBase.length > 7) {
        _trailBase.removeAt(0);
        _trailTip.removeAt(0);
      }
    } else if (_trailBase.isNotEmpty) {
      _trailBase.removeAt(0);
      _trailTip.removeAt(0);
    }
  }

  Offset _world(Offset local) => Offset(x + local.dx * facing, y + local.dy);

  // ------------------------------------------------------------------ render

  static final Paint _shadow = Paint()..color = const Color(0x88000000);

  void render(Canvas c) {
    if (alpha <= 0.01) return;
    // Contact shadow on the surface below.
    final groundY = _surfaceBelow();
    final hgt = (groundY - y).abs();
    final sw = 70 * clampD(1 - hgt / 500, 0.3, 1);
    _shadow.color = fade(const Color(0x99000000), alpha * clampD(1 - hgt / 600, 0.2, 1));
    c.drawOval(Rect.fromCenter(center: Offset(x, groundY), width: sw, height: 10), _shadow);

    if (_trailBase.length >= 2) {
      HumanoidPainter.drawTrail(c, _trailBase, _trailTip, state == PState.smash ? const Color(0xFF8FC8FF) : const Color(0xFFBFD8FF));
    }
    var a = alpha;
    if (invuln > 0 && alive && ((invuln * 18).floor() % 2 == 0)) a *= 0.45;
    c.save();
    c.translate(x, y);
    c.scale(facing, 1);
    if (pose.rot != 0) c.rotate(pose.rot);
    HumanoidPainter.draw(c, skel, pose, style,
        time: b.time, alpha: a, flash: flash, rimDx: facing, wind: clampD(-vx * facing / 400, -1, 1) + 0.3, eyeBoost: state == PState.smash ? 1.2 : 0);
    if (state == PState.smash && _smashPhase < 2) {
      final g = Paint()
        ..blendMode = BlendMode.plus
        ..color = fade(const Color(0xFF4F9CFF), 0.25 + 0.1 * math.sin(b.time * 30));
      c.drawCircle(skel.wTip, 22, g);
      c.drawCircle(skel.fHand, 16, g);
    }
    c.restore();
  }

  double _surfaceBelow() {
    var best = 0.0;
    for (final p in b.cfg.platforms) {
      if (x >= p.x && x <= p.x + p.width && p.top >= y - 1 && p.top < best) best = p.top;
    }
    return best;
  }
}
