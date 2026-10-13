import 'dart:math' as math;
import 'dart:ui';

import '../audio.dart';
import '../core/utils.dart';
import '../render/humanoid.dart';
import 'battle.dart';
import 'fx.dart';
import 'player_fx.dart';

enum PState { idle, run, air, attack, smash, dash, hurt, dead }

enum _Blade { sheathed, drawing, drawn, sheathing }

class _Ghost {
  _Ghost(this.x, this.y, this.facing, Pose p) {
    pose.copyFrom(p);
  }
  final double x;
  final double y;
  final double facing;
  final Pose pose = Pose();
  double life = 0.28;
}

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

  static const HumanoidStyle style = HumanoidStyle(
    height: 150,
    headband: true,
    bandColor: Color(0xFF9A1424),
    eye: Color(0xFF8FE6FF),
    eyeGlow: 1.0,
    rim: Color(0xFF9AB8E0),
    rimStrength: 0.72,
    bladeColor: Color(0xFFD8E8FF),
    bladeGlow: Color(0xFF5FB8FF),
    hakama: true,
    topknot: true,
    mask: true,
    scarf: true,
    saya: true,
  );

  static const HumanoidStyle _ghostStyle = HumanoidStyle(
    height: 150,
    body: Color(0xFF16305A),
    backTint: Color(0xFF16305A),
    rimStrength: 0,
    eyeGlow: 0,
    hakama: true,
    topknot: true,
    weapon: WeaponType.none,
  );

  final HumanoidRig rig = HumanoidRig(style);
  Pose get pose => rig.pose;
  Skeleton get skel => rig.skel;
  final Skeleton _ghostSkel = Skeleton();

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
  double _spinTick = 0;
  double _footT = 0;
  double alpha = 1;
  bool _deathReported = false;
  final List<Offset> _trailBase = [];
  final List<Offset> _trailTip = [];

  // Sword carried in the scabbard when no enemy is near.
  _Blade _blade = _Blade.sheathed;
  double _bladeT = 0;
  double _calmT = 0;

  // Sprint / dash.
  bool sprinting = false;
  double _dashCd = 0;
  bool _airDash = true;
  double _ghostT = 0;
  final List<_Ghost> _ghosts = [];

  // Boss level regeneration.
  double sinceHurt = 10;
  bool regenerating = false;

  bool get alive => state != PState.dead;
  bool get armed => _blade == _Blade.drawn || (_blade == _Blade.drawing && _bladeT > 0.5) || (_blade == _Blade.sheathing && _bladeT < 0.5);
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
    _dashCd = math.max(0, _dashCd - dt);
    sinceHurt += dt;
    if (powerCharge < 1) {
      powerCharge = math.min(1, powerCharge + dt / powerReload);
    }
    final input = b.input;
    final locked = b.controlsLocked || state == PState.dead;
    final moveX = locked ? 0.0 : input.moveX;
    final wantJump = !locked && input.jump;
    final wantAttack = !locked && input.attack;
    final wantPower = !locked && input.power;
    final wantDash = !locked && input.dash;
    sprinting = !locked && input.sprint && onGround && moveX.abs() > 0.2 && (state == PState.run || state == PState.idle);
    input.jump = false;
    input.attack = false;
    input.power = false;
    input.dash = false;

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
      case PState.dash:
        if (st > 0.2) {
          vx *= 0.45;
          _toMove();
        }
        break;
      case PState.attack:
        _updateAttack(dt, moveX, wantAttack);
        if (_jumpBuffer > 0 && st > _activeEnd[combo]) _tryJump();
        if (wantDash && st > _activeEnd[combo]) _startDash(moveX);
        break;
      case PState.idle:
      case PState.run:
      case PState.air:
        final speed = sprinting ? 650.0 : 390.0;
        final targetV = moveX * speed;
        vx += (targetV - vx) * smoothK(onGround ? 14 : 8, dt);
        if (moveX.abs() > 0.15) facing = moveX > 0 ? 1 : -1;
        if (_jumpBuffer > 0) _tryJump();
        if (wantDash) _startDash(moveX);
        if (wantAttack && state != PState.dash) _startAttack(0);
        if (wantPower && powerCharge >= 1 && state != PState.dash) _startSmash();
        if (state == PState.idle || state == PState.run || state == PState.air) {
          state = !onGround ? PState.air : (vx.abs() > 30 ? PState.run : PState.idle);
        }
        break;
    }
    if (wantPower && powerCharge >= 1 && (state == PState.attack || state == PState.hurt) && alive) {
      _startSmash();
    }

    _updateBlade(dt);
    _regen(dt);
    _physics(dt);
    _animate(dt);
    _footsteps(dt);
    _attackHits();
    _updateGhosts(dt);
  }

  void _toMove() {
    state = onGround ? PState.idle : PState.air;
    st = 0;
  }

  // ------------------------------------------------------------------ sword

  bool _threatNear() {
    final boss = b.boss;
    if (boss != null && !boss.finished) return true;
    for (final e in b.enemies) {
      if (!e.isDead && (e.x - x).abs() < 760) return true;
    }
    return false;
  }

  void _updateBlade(double dt) {
    final threat = _threatNear() && alive;
    _calmT = threat ? 0 : _calmT + dt;
    switch (_blade) {
      case _Blade.sheathed:
        if (threat && (state == PState.idle || state == PState.run || state == PState.air)) _beginDraw();
        break;
      case _Blade.drawing:
        _bladeT += dt / 0.3;
        if (_bladeT >= 1) {
          _blade = _Blade.drawn;
          _bladeT = 0;
        }
        break;
      case _Blade.drawn:
        if (_calmT > 2.6 && (state == PState.idle || state == PState.run)) {
          _blade = _Blade.sheathing;
          _bladeT = 0;
          b.sfx(Sfx.swordSheathe, volume: 0.7);
        }
        break;
      case _Blade.sheathing:
        _bladeT += dt / 0.4;
        if (threat) {
          _beginDraw();
        } else if (_bladeT >= 1) {
          _blade = _Blade.sheathed;
          _bladeT = 0;
        }
        break;
    }
  }

  void _beginDraw() {
    _blade = _Blade.drawing;
    _bladeT = 0;
    b.sfx(Sfx.swordDraw, volume: 0.85, gap: 300);
    final hip = _world(skel.hip + const Offset(8, -4));
    b.fx.hitSparks(hip.dx + facing * 20, hip.dy, facing, n: 6, color: const Color(0xFFBFE0FF));
  }

  void _forceDrawn() {
    if (_blade != _Blade.drawn) {
      if (_blade == _Blade.sheathed || _blade == _Blade.sheathing) {
        b.sfx(Sfx.swordDraw, volume: 0.85, gap: 300);
      }
      _blade = _Blade.drawn;
      _bladeT = 0;
    }
    _calmT = 0;
  }

  // ------------------------------------------------------------------ moves

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

  void _startDash(double moveX) {
    if (_dashCd > 0) return;
    if (!onGround) {
      if (!_airDash) return;
      _airDash = false;
    }
    if (moveX.abs() > 0.15) facing = moveX > 0 ? 1 : -1;
    state = PState.dash;
    st = 0;
    vx = facing * 1150;
    vy = 0;
    invuln = math.max(invuln, 0.24);
    _dashCd = 0.55;
    b.sfx(Sfx.dash, volume: 0.8);
    b.fx.shadowBurst(x, y - 70, n: 10, spread: 0.9);
    b.fx.dust(x, y, n: 6, power: 1.0);
    _ghostT = 0;
  }

  void _startAttack(int step) {
    if (!armed) {
      // Iaido: draw and cut in a single motion.
      _forceDrawn();
      b.fx.hitSparks(x + facing * 30, y - 80, facing, n: 6, color: const Color(0xFFBFE0FF));
    }
    _calmT = 0;
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

  // ------------------------------------------------------------------ shadow storm power

  void _startSmash() {
    _forceDrawn();
    powerCharge = 0;
    state = PState.smash;
    st = 0;
    _smashPhase = 0;
    _spinTick = 0;
    _hitSet.clear();
    vx = 0;
    if (onGround) vy = 0;
    b.sfx(Sfx.powerCharge, volume: 1.0);
    b.slowMotion(0.18, 0.6);
  }

  void _updateSmash(double dt) {
    switch (_smashPhase) {
      case 0:
        // Gather shadow energy.
        vx *= 0.8;
        if (!onGround) vy = math.min(vy, 120);
        for (var i = 0; i < 3; i++) {
          final a = rng.nextDouble() * math.pi * 2;
          final r = randRange(90, 170);
          b.particles.spawn(px: x + math.cos(a) * r, py: y - 80 + math.sin(a) * r, pvx: -math.cos(a) * r * 4, pvy: -math.sin(a) * r * 4, plife: 0.22, psize: randRange(2, 4), pcolor: const Color(0xFF7FC0FF), pkind: PKind.glow);
        }
        if (st > 0.22) {
          _smashPhase = 1;
          st = 0;
          vy = -780;
          vx = facing * 160;
          onGround = false;
          b.sfx(Sfx.swordSwing, volume: 0.9);
          b.ring(x, y - 4, 120, 0.3, const Color(0xFF7FC0FF), 4);
        }
        break;
      case 1:
        // Rising spinning cut: hits everything close several times.
        _spinTick -= dt;
        if (_spinTick <= 0) {
          _spinTick = 0.09;
          _spinHits();
        }
        if (st > 0.3) {
          _smashPhase = 2;
          st = 0;
          vy = 1900;
          vx = 0;
        }
        break;
      case 2:
        if (onGround || st > 0.9) {
          _smashPhase = 3;
          st = 0;
          _smashImpact();
        }
        break;
      default:
        if (st > 0.36) _toMove();
    }
  }

  void _spinHits() {
    b.sfx(Sfx.swordSwing, volume: 0.6, gap: 60);
    final cx = x;
    final cy = y - 80;
    for (final h in b.hittables().toList()) {
      final r = h.hurtBox;
      final nx = clampD(cx, r.left, r.right);
      final ny = clampD(cy, r.top, r.bottom);
      if ((Offset(nx, ny) - Offset(cx, cy)).distance < 175) {
        final dir = r.center.dx >= x ? 1.0 : -1.0;
        h.receiveHit(11, dir, 160);
        b.fx.hitSparks(nx, ny, dir, n: 6, color: const Color(0xFF9FD0FF));
      }
    }
  }

  void _smashImpact() {
    vx = 0;
    b.addShake(1.0);
    b.hitStop(0.09);
    b.slowMotion(0.35, 0.45);
    b.flashWhite = math.max(b.flashWhite, 0.5);
    b.sfx(Sfx.powerUp, volume: 1.0);
    b.sfx(Sfx.shadowWave, volume: 0.9);
    b.ring(x, y - 4, 380, 0.6, const Color(0xFF7FC0FF), 12);
    b.ring(x, y - 4, 240, 0.45, const Color(0xFFB09CFF), 7);
    b.ring(x, y - 90, 200, 0.45, const Color(0xFF7FC0FF), 5, flat: 1);
    b.fx.energy(x, y - 30, n: 70, color: const Color(0xFF7FC0FF), speed: 720);
    b.fx.energy(x, y - 30, n: 30, color: const Color(0xFFB09CFF), speed: 420);
    b.fx.dust(x, y, n: 22, power: 1.9);
    b.fx.debris(x, y, n: 16);
    b.fx.shadowBurst(x, y - 40, n: 22, spread: 1.6);
    b.playerFx.add(GroundCrack(b, x, y));
    for (var i = -2; i <= 2; i++) {
      b.playerFx.add(ShadowSpike(b, x + i * 70 + randRange(-15, 15), y, delay: i.abs() * 0.05, height: 150 - i.abs() * 25.0));
    }
    b.playerFx.add(ShadowWave(b, x + 40, y, 1));
    b.playerFx.add(ShadowWave(b, x - 40, y, -1));
    for (final h in b.hittables().toList()) {
      final r = h.hurtBox;
      final dx = (r.center.dx - x).abs() - r.width / 2;
      if (dx <= 340 && r.bottom > y - 480 && r.top < y + 40) {
        final dir = r.center.dx >= x ? 1.0 : -1.0;
        h.receiveHit(62, dir, 680, heavy: true);
        b.fx.hitSparks(r.center.dx, r.center.dy, dir, n: 16, color: const Color(0xFF9FD0FF));
      }
    }
    for (final p in b.projectiles) {
      if (p.destructible && (p.x - x).abs() < 340 && p.y > y - 400) p.destroy();
    }
    for (final h in b.hazards) {
      if (h.smashable && (h.x - x).abs() < 340) h.shatter();
    }
  }

  // ------------------------------------------------------------------ regen

  void _regen(double dt) {
    regenerating = false;
    if (!b.cfg.isBoss || !alive || health >= maxHealth) return;
    if (sinceHurt < 2.5) return;
    regenerating = true;
    health = math.min(maxHealth, health + 32 * dt);
    if (rng.nextDouble() < 0.35) {
      b.particles.spawn(px: x + randRange(-24, 24), py: y - randRange(10, 130), pvy: -randRange(50, 120), plife: 0.7, psize: randRange(1.5, 3), pcolor: const Color(0xFF7FFFD0), pkind: PKind.glow);
    }
  }

  // ------------------------------------------------------------------ physics

  void _physics(double dt) {
    if (state == PState.dead && onGround) {
      vx *= math.max(0, 1 - 5 * dt);
    }
    final prevY = y;
    var g = 2500.0;
    if (state == PState.attack && !onGround) g = 1500;
    if (state == PState.dash) g = 0;
    if (state == PState.smash && _smashPhase == 0) g = 300;
    vy = math.min(vy + g * dt, 1900);
    x += vx * dt;
    y += vy * dt;
    x = clampD(x, 30, b.cfg.length - 30);
    final wasGround = onGround;
    final land = vy >= 0 ? b.landingY(x, 40, prevY, y) : null;
    if (land != null) {
      y = land;
      if (!wasGround && vy > 500) {
        b.sfx(Sfx.land, volume: clampD(vy / 1500, 0.3, 0.8));
        b.fx.dust(x, y, n: 6, power: 0.7);
      }
      vy = 0;
      onGround = true;
      airJumps = 1;
      _airDash = true;
    } else if (onGround && !b.supportedAt(x, 40, y)) {
      onGround = false;
    }
    if (y < -1 && vy == 0 && state != PState.dash && !b.supportedAt(x, 40, y)) onGround = false;
  }

  void _footsteps(double dt) {
    if (!onGround || state != PState.run) {
      _footT = 0.12;
      return;
    }
    _footT -= dt;
    if (_footT <= 0) {
      _footT = sprinting ? 0.2 : 0.29;
      b.sfx(Sfx.footstep, volume: 0.45, gap: 100);
      if (rng.nextDouble() < (sprinting ? 0.9 : 0.5)) b.fx.dust(x - facing * 10, y, n: sprinting ? 3 : 2, power: sprinting ? 0.7 : 0.4);
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
    sinceHurt = 0;
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

  bool get _sheathedLook => !armed;

  void _animate(double dt) {
    var rate = 16.0;
    final target = rig.target;
    switch (state) {
      case PState.idle:
        if (_blade == _Blade.drawing) {
          target.quickDraw(_bladeT);
          rate = 30;
        } else if (_blade == _Blade.sheathing) {
          target.quickDraw(1 - _bladeT);
          rate = 24;
        } else if (_sheathedLook) {
          target.sheathedIdle(b.time);
        } else {
          target.idle(b.time);
        }
        break;
      case PState.run:
        final speed = vx.abs();
        walkPhase += dt * (5 + speed / 38);
        if (_sheathedLook || sprinting) {
          if (speed > 220) {
            target.ninjaRun(walkPhase, clampD(speed / 300, 0.3, 1.1));
          } else {
            target.walk(walkPhase, clampD(speed / 300, 0.3, 1));
            target.bUpper = -0.05;
            target.bFore = 1.2;
            target.fUpper = 0.2 + math.sin(walkPhase) * 0.3;
            target.fFore = 0.5;
          }
          if (!_sheathedLook) {
            target.fUpper = 1.0;
            target.fFore = 1.7;
            target.weapon = 1.5;
          }
        } else {
          target.walk(walkPhase, clampD(speed / 300, 0.3, 1), run: speed > 220);
        }
        if (_blade == _Blade.drawing) target.quickDraw(_bladeT);
        rate = 20;
        break;
      case PState.air:
        if (vy < 0) {
          target.jump();
        } else {
          target.fall();
        }
        if (_sheathedLook) {
          target.fUpper = -0.6;
          target.fFore = -0.2;
        }
        rate = 12;
        break;
      case PState.dash:
        target.dash();
        if (_sheathedLook) {
          target.fUpper = -1.2;
          target.fFore = -1.0;
        }
        rate = 30;
        break;
      case PState.attack:
        final t = st;
        final s = _activeStart[combo];
        final e = _activeEnd[combo];
        final k = t < s ? 0.0 : clampD((t - s) / (e - s), 0, 1);
        switch (combo) {
          case 0:
            if (t < s) {
              target.windUp(clampD(t / s, 0, 1));
            } else {
              target.slashDown(k);
            }
            break;
          case 1:
            target.slashUp(t < s ? 0 : k);
            break;
          default:
            target.thrust(t < s ? 0 : k);
        }
        rate = 38;
        break;
      case PState.smash:
        switch (_smashPhase) {
          case 0:
            target.windUp(1);
            target.fThigh = 1.1;
            target.fShin = -0.2;
            target.bThigh = -0.6;
            target.bShin = -1.4;
            rate = 26;
            break;
          case 1:
            target.spinSlash(clampD(st / 0.3, 0, 1) * 2 % 1.0);
            rate = 60;
            break;
          case 2:
            target.windUp(1);
            target.weapon = 0.2;
            target.fUpper = 1.0;
            target.fFore = 0.6;
            rate = 30;
            break;
          default:
            target.smashImpact();
            rate = 34;
        }
        break;
      case PState.hurt:
        target.hurt();
        rate = 26;
        break;
      case PState.dead:
        target.collapsed(clampD(st / 0.7, 0, 1));
        target.rot = -1.45 * easeOutCubic(clampD(st / 0.8, 0, 1));
        rate = 12;
        break;
    }
    pose.blend(target, smoothK(rate, dt));
    rig.compute();
    final wind = 0.35 + clampD(vx.abs() / 900, 0, 0.6);
    rig.updateCloth(dt, x, y, facing, b.time, wind: wind);
    // Blade trail while swinging.
    final swinging = state == PState.attack || (state == PState.smash && (_smashPhase == 1 || _smashPhase == 2));
    if (swinging && armed) {
      _trailBase.add(_world(skel.fHand + skel.wDir * 10));
      _trailTip.add(_world(skel.wTip));
      if (_trailBase.length > (_smashPhase == 1 ? 10 : 7)) {
        _trailBase.removeAt(0);
        _trailTip.removeAt(0);
      }
    } else if (_trailBase.isNotEmpty) {
      _trailBase.removeAt(0);
      _trailTip.removeAt(0);
    }
  }

  void _updateGhosts(double dt) {
    final fast = state == PState.dash || sprinting || (state == PState.smash && _smashPhase == 2);
    if (fast) {
      _ghostT -= dt;
      if (_ghostT <= 0) {
        _ghostT = state == PState.dash ? 0.025 : 0.06;
        if (_ghosts.length < 8) _ghosts.add(_Ghost(x, y, facing, pose));
      }
    }
    for (final g in _ghosts) {
      g.life -= dt;
    }
    _ghosts.removeWhere((g) => g.life <= 0);
  }

  Offset _world(Offset local) => Offset(x + local.dx * facing, y + local.dy);

  // ------------------------------------------------------------------ render

  static final Paint _shadow = Paint()..color = const Color(0x88000000);
  static final Paint _glow = Paint()..blendMode = BlendMode.plus;

  void render(Canvas c) {
    if (alpha <= 0.01) return;
    // Contact shadow on the surface below.
    final groundY = _surfaceBelow();
    final hgt = (groundY - y).abs();
    final sw = 70 * clampD(1 - hgt / 500, 0.3, 1);
    _shadow.color = fade(const Color(0x99000000), alpha * clampD(1 - hgt / 600, 0.2, 1));
    c.drawOval(Rect.fromCenter(center: Offset(x, groundY), width: sw, height: 10), _shadow);

    // Speed afterimages.
    for (final g in _ghosts) {
      _ghostSkel.compute(g.pose, _ghostStyle);
      c.save();
      c.translate(g.x, g.y);
      c.scale(g.facing, 1);
      HumanoidPainter.draw(c, _ghostSkel, g.pose, _ghostStyle, alpha: (g.life / 0.28) * 0.35);
      c.restore();
    }

    if (_trailBase.length >= 2) {
      HumanoidPainter.drawTrail(c, _trailBase, _trailTip, state == PState.smash ? const Color(0xFF8FC8FF) : const Color(0xFFBFD8FF));
    }
    final a = alpha;
    final blink = invuln > 0 && alive && state != PState.dash && ((invuln * 16).floor() % 2 == 0);
    c.save();
    c.translate(x, y);
    c.scale(facing, 1);
    if (pose.rot != 0) c.rotate(pose.rot);
    HumanoidPainter.draw(c, skel, pose, style,
        time: b.time,
        alpha: a,
        flash: blink ? math.max(flash, 0.55) : flash,
        rimDx: facing,
        wind: clampD(-vx * facing / 400, -1, 1) + 0.3,
        eyeBoost: state == PState.smash ? 1.4 : (state == PState.dash ? 0.8 : 0),
        sheathed: armed ? 0 : 1,
        cloth: rig.cloth);
    if (state == PState.smash && _smashPhase < 3) {
      final pulse = 0.25 + 0.12 * math.sin(b.time * 30);
      _glow.color = fade(const Color(0xFF4F9CFF), pulse);
      c.drawCircle(skel.wTip, 24, _glow);
      c.drawCircle(skel.fHand, 16, _glow);
      _glow.color = fade(const Color(0xFF4F9CFF), pulse * 0.4);
      c.drawCircle(skel.hip + const Offset(0, -40), 70, _glow);
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
