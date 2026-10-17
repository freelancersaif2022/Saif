import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../game/battle_engine.dart';
import '../game/battle_session.dart';
import '../game/monster_factory.dart';
import '../models/element.dart';
import '../models/monster.dart';
import '../services/ads/ad_service.dart';
import '../services/game_store.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_fx.dart';
import '../widgets/feedback.dart';
import '../widgets/monster_view.dart';
import '../widgets/ui.dart';

enum BattleMode { ladder, friendGhost, live }

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.session, required this.player, required this.enemy, this.ladderStage, this.mode = BattleMode.ladder});
  final BattleSession session;
  final Monster player;
  final Monster enemy;
  final int? ladderStage;
  final BattleMode mode;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _Popup {
  _Popup(this.id, this.text, this.color, this.onPlayer, {this.big = false, this.slot = 0});
  final int id;
  final int slot; // stacks simultaneous popups instead of overlapping them
  final String text;
  final Color color;
  final bool onPlayer;
  final bool big;
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  BattleSession get _s => widget.session;
  bool get _live => widget.mode == BattleMode.live;

  late final AnimationController _pLunge = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  late final AnimationController _eLunge = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  late final AnimationController _pHit = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final AnimationController _eHit = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  final _fx = BattleFxController();
  final _stackKey = GlobalKey();
  final _pKey = GlobalKey();
  final _eKey = GlobalKey();
  double _shakeAmp = 0;

  bool _busy = false;
  bool _waiting = false; // live: my move is locked, waiting for the friend
  bool _finished = false;
  bool _pGuard = false;
  bool _eGuard = false;
  bool _pFaint = false;
  bool _eFaint = false;
  late int _pHp = _s.me.hp;
  late int _eHp = _s.foe.hp;
  String _log = '';
  final List<_Popup> _popups = [];
  int _popupId = 0;

  // Live turn timer.
  static const _turnSeconds = 20;
  Timer? _turnTimer;
  int _turnLeft = _turnSeconds;

  @override
  void initState() {
    super.initState();
    _log = switch (widget.mode) {
      BattleMode.ladder => 'A wild ${widget.enemy.name} appears!',
      BattleMode.friendGhost => "Your friend's ${widget.enemy.name} wants a fight!",
      BattleMode.live => 'LIVE vs ${widget.enemy.name}! Pick your move!',
    };
    Sfx.play(Fx.whoosh);
    Sfx.music(MusicTrack.battle);
    _s.lost.addListener(_onLost);
    if (_live) _startTurnTimer();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _s.lost.removeListener(_onLost);
    _s.dispose();
    for (final c in [_pLunge, _eLunge, _pHit, _eHit, _shake, _intro]) {
      c.dispose();
    }
    _fx.dispose();
    Sfx.music(MusicTrack.menu);
    super.dispose();
  }

  Future<void> _wait(int ms) => Future.delayed(Duration(milliseconds: ms));

  // ---- Live helpers ---------------------------------------------------------
  void _startTurnTimer() {
    _turnTimer?.cancel();
    _turnLeft = _turnSeconds;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _busy || _finished) return;
      setState(() => _turnLeft--);
      if (_turnLeft <= 3 && _turnLeft > 0) Sfx.play(Fx.countdown, volume: 0.6);
      if (_turnLeft <= 0) {
        t.cancel();
        // Time's up: attack automatically so the battle never stalls.
        final auto = _s.me.moves.firstWhere((m) => m.kind == MoveKind.special && _s.me.isReady(m), orElse: () => _s.me.moveOf(MoveKind.claw));
        _useMove(auto);
      }
    });
  }

  Future<void> _onLost() async {
    if (!_s.lost.value || _finished || !mounted) return;
    if (_s.over) return; // normal end; friend just left the result screen
    _finished = true;
    _turnTimer?.cancel();
    final store = GameScope.read(context);
    // The friend left mid-battle: victory by forfeit (half rewards).
    widget.player.wins++;
    widget.player.addXp(20);
    store.recordBattle(won: true);
    store.addCoins(40);
    Sfx.play(Fx.win);
    await AppDialog.show(
      context: context,
      title: 'Friend left',
      message: '${widget.enemy.name} fled the battle. Victory by forfeit! +40 coins.',
      accent: AppColors.gold,
      hero: const IconBadge(icon: Icons.wifi_off_rounded, color: AppColors.gold, size: 72),
      primaryLabel: 'OK',
      dismissible: false,
    );
    if (mounted) Navigator.of(context).pop();
  }

  // ---- Popups & geometry ------------------------------------------------------
  void _popup(String text, Color color, bool onPlayer, {bool big = false}) {
    final slot = _popups.where((x) => x.onPlayer == onPlayer).length;
    final p = _Popup(_popupId++, text, color, onPlayer, big: big, slot: slot);
    setState(() => _popups.add(p));
    Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _popups.remove(p));
    });
  }

  Offset _center(GlobalKey k) {
    final box = k.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.hasSize) return Offset.zero;
    return stack.globalToLocal(box.localToGlobal(box.size.center(Offset.zero)));
  }

  double _sizeOf(GlobalKey k) => (k.currentContext?.findRenderObject() as RenderBox?)?.size.width ?? 160;

  void _screenShake(double amp) {
    _shakeAmp = amp;
    _shake.forward(from: 0);
  }

  // ---- Turn flow --------------------------------------------------------------
  Future<void> _useMove(Move move) async {
    if (_busy || _finished) return;
    if (!_s.me.isReady(move)) {
      AppToast.show('${move.name} is recharging (${_s.me.cooldownOf(move)} turn${_s.me.cooldownOf(move) > 1 ? 's' : ''}).', type: ToastType.info);
      return;
    }
    _turnTimer?.cancel();
    final hpBefore = (_s.me.hp, _s.foe.hp);
    setState(() {
      _busy = true;
      _waiting = _live;
      if (_live) _log = _s.friendChose.value ? 'Both ready… FIGHT!' : 'Waiting for ${widget.enemy.name}…';
    });
    List<BattleEvent> events;
    try {
      events = await _s.submit(move);
    } on LiveDisconnected {
      return; // _onLost handles it
    } catch (e) {
      if (!mounted) return;
      AppToast.show('Connection problem. Please try again.', type: ToastType.error);
      setState(() {
        _busy = false;
        _waiting = false;
      });
      return;
    }
    if (!mounted) return;
    // HP bars drain event by event, starting from before the round.
    setState(() {
      _waiting = false;
      _pHp = hpBefore.$1;
      _eHp = hpBefore.$2;
      _pGuard = events.any((e) => e.byPlayer && e.type == EventType.guard);
      _eGuard = events.any((e) => !e.byPlayer && e.type == EventType.guard);
    });
    for (final ev in events) {
      if (!mounted) return;
      setState(() => _log = ev.describe(widget.player.name, widget.enemy.name));
      await _animate(ev);
      await _wait(180);
    }
    if (!mounted) return;
    setState(() {
      _pHp = _s.me.hp;
      _eHp = _s.foe.hp;
      _pGuard = false;
      _eGuard = false;
      _busy = false;
      if (!_s.over && _live) _log = 'Your move!';
    });
    if (_s.over) {
      await _onBattleOver();
    } else if (_live) {
      Sfx.play(Fx.turn, volume: 0.6);
      _startTurnTimer();
    }
  }

  Future<void> _animate(BattleEvent ev) async {
    final mine = ev.byPlayer;
    final lunge = mine ? _pLunge : _eLunge;
    final hit = mine ? _eHit : _pHit;
    final from = _center(mine ? _pKey : _eKey);
    final to = _center(mine ? _eKey : _pKey);
    final targetSize = _sizeOf(mine ? _eKey : _pKey);
    final attacker = mine ? _s.me.monster : _s.foe.monster;
    final targetIsPlayer = !mine;

    void land() {
      Sfx.play(ev.crit ? Fx.crit : Fx.hit);
      Sfx.haptic(heavy: ev.crit);
      hit.forward(from: 0);
      _screenShake(ev.crit ? 14 : 7);
      setState(() {
        if (targetIsPlayer) {
          _pHp = max(0, _pHp - ev.damage);
        } else {
          _eHp = max(0, _eHp - ev.damage);
        }
      });
      _popup('-${ev.damage}', ev.crit ? AppColors.gold : Colors.white, targetIsPlayer, big: ev.crit);
      if (ev.crit) _popup('CRITICAL!', AppColors.gold, targetIsPlayer);
      if (ev.effectiveness > 1) _popup('SUPER EFFECTIVE!', AppColors.success, targetIsPlayer);
      if (ev.effectiveness < 1) _popup('resisted', AppColors.textDim, targetIsPlayer);
    }

    switch (ev.type) {
      case EventType.attack when ev.move.kind == MoveKind.claw:
        Sfx.play(Fx.whoosh, volume: 0.7);
        await lunge.forward(from: 0);
        Sfx.play(Fx.slash);
        _fx.add(FxEffect(FxKind.slash, from: from, to: to, crit: ev.crit, size: targetSize, duration: 0.55));
        await _wait(90);
        land();
        await lunge.reverse();
        await _wait(220);
      case EventType.attack:
        // Special: wind up, launch an element projectile, impact on arrival.
        await lunge.animateTo(0.35, curve: Curves.easeOut);
        Sfx.element(attacker.element);
        _fx.add(FxEffect(FxKind.projectile, from: from, to: to, element: attacker.element, crit: ev.crit, size: targetSize, duration: 0.95));
        unawaited(lunge.reverse());
        await _wait((BattleFxController.projectileTravel * 1000).round());
        land();
        await _wait(420);
      case EventType.miss:
        await lunge.forward(from: 0);
        Sfx.play(Fx.miss);
        _fx.add(FxEffect(FxKind.miss, from: from, to: to, size: targetSize, duration: 0.45));
        _popup('MISS', AppColors.textDim, targetIsPlayer);
        await lunge.reverse();
        await _wait(150);
      case EventType.roar:
        if (mine) {
          Sfx.roar(widget.player.roarPath);
        } else {
          Sfx.play(Fx.roarBuff);
        }
        Sfx.haptic();
        _fx.add(FxEffect(FxKind.shockwave, from: from, to: from, size: _sizeOf(mine ? _pKey : _eKey), duration: 0.9));
        _screenShake(5);
        _popup('ATK UP!', AppColors.danger, mine, big: true);
        await lunge.animateTo(0.25);
        await lunge.reverse();
        await _wait(600);
      case EventType.guard:
        Sfx.play(Fx.guard);
        final sz = _sizeOf(mine ? _pKey : _eKey);
        _fx.add(FxEffect(FxKind.shield, from: from, to: from, size: sz, duration: 0.9));
        if (ev.heal > 0) {
          Sfx.play(Fx.heal, volume: 0.8);
          _fx.add(FxEffect(FxKind.heal, from: from, to: from, size: sz, duration: 0.9));
          setState(() {
            if (mine) {
              _pHp += ev.heal;
            } else {
              _eHp += ev.heal;
            }
          });
        }
        _popup(ev.heal > 0 ? '+${ev.heal}' : 'GUARD', AppColors.success, mine);
        await _wait(600);
      case EventType.faint:
        Sfx.play(Fx.whoosh);
        setState(() {
          if (mine) {
            _eFaint = true;
          } else {
            _pFaint = true;
          }
        });
        await _wait(750);
    }
  }

  // ---- End of battle ------------------------------------------------------------
  Future<void> _onBattleOver() async {
    final store = GameScope.read(context);
    _turnTimer?.cancel();
    if (!_s.iWon && _s.canRevive) {
      final revive = await AppDialog.show<bool>(
        context: context,
        title: 'Your beast fainted!',
        message: 'Watch a short video to revive with 50% HP and keep fighting.',
        accent: AppColors.success,
        hero: const IconBadge(icon: Icons.favorite_rounded, color: AppColors.success, size: 76),
        primaryLabel: 'Revive',
        primaryIcon: Icons.play_circle_fill_rounded,
        primaryColor: AppColors.success,
        onPrimary: () async {
          final nav = Navigator.of(context);
          final ok = await AdService.instance.showRewarded(rewardLabel: 'a revive');
          if (ok) nav.pop(true);
        },
        secondaryLabel: 'Give up',
        onSecondary: () => Navigator.of(context).pop(false),
        dismissible: false,
      );
      if (revive == true && mounted) {
        _s.revive();
        Sfx.play(Fx.levelup);
        setState(() {
          _pFaint = false;
          _pHp = _s.me.hp;
          _log = '${widget.player.name} is back on its feet!';
        });
        _fx.add(FxEffect(FxKind.heal, from: _center(_pKey), to: _center(_pKey), size: _sizeOf(_pKey), duration: 1.0));
        _popup('REVIVED', AppColors.success, true, big: true);
        return;
      }
    }

    _finished = true;
    final won = _s.iWon;
    final stage = widget.ladderStage;
    final firstClear = won && stage != null && stage == store.ladderProgress;
    final boss = stage != null && MonsterFactory.isBoss(stage);

    final coins = switch (widget.mode) {
      BattleMode.ladder => won ? 40 + 8 * stage! : 10,
      BattleMode.friendGhost => won ? 60 : 15,
      BattleMode.live => won ? 80 : 20,
    };
    final xp = won ? 35 + 10 * widget.enemy.level : 12 + 2 * widget.enemy.level;
    final gems = firstClear ? (boss ? 15 : 5) : (widget.mode == BattleMode.live && won ? 3 : 0);
    final stones = firstClear && boss ? 1 : 0;

    final m = widget.player;
    final levels = m.addXp(xp);
    if (won) {
      m.wins++;
    } else {
      m.losses++;
    }
    store.recordBattle(won: won, ladderStage: stage);
    if (gems > 0) store.addGems(gems);
    if (stones > 0) store.addStones(stones);
    Sfx.music(MusicTrack.none);
    Sfx.play(won ? Fx.win : Fx.lose);
    if (levels > 0) Future.delayed(const Duration(milliseconds: 900), () => Sfx.play(Fx.levelup));

    if (!mounted) return;
    final doubled = await AppDialog.show<bool>(
      context: context,
      title: won ? 'VICTORY!' : 'DEFEAT',
      message: won ? '${m.name} crushed ${widget.enemy.name}!' : '${widget.enemy.name} was too strong this time.',
      accent: won ? AppColors.gold : AppColors.danger,
      dismissible: false,
      hero: Stack(
        alignment: Alignment.topCenter,
        children: [
          MonsterView(monster: m, size: 150),
          if (won) const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 40),
        ],
      ),
      body: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 8,
            children: [
              _Reward(Currency.coins, '+$coins'),
              _RewardText(Icons.trending_up_rounded, AppColors.cyan, '+$xp XP'),
              if (gems > 0) _Reward(Currency.gems, '+$gems'),
              if (stones > 0) _Reward(Currency.stones, '+$stones'),
            ],
          ),
          if (levels > 0)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.cyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('LEVEL UP! ${m.name} is now Lv ${m.level}', style: AppText.label.copyWith(color: AppColors.cyan)),
            ),
          if (m.canEvolve && levels > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('✨ Ready to evolve! Open it in your Lair.', style: AppText.small.copyWith(color: const Color(0xFFE040FB))),
            ),
        ],
      ),
      primaryLabel: 'Claim 2× coins',
      primaryIcon: Icons.play_circle_fill_rounded,
      primaryColor: AppColors.success,
      onPrimary: () async {
        final nav = Navigator.of(context);
        final ok = await AdService.instance.showRewarded(rewardLabel: '2× coins');
        if (ok) nav.pop(true);
      },
      secondaryLabel: 'Claim',
      onSecondary: () => Navigator.of(context).pop(false),
    );
    store.addCoins(doubled == true ? coins * 2 : coins);
    if (doubled == true) AppToast.show('+${coins * 2} coins collected!', type: ToastType.reward, title: 'Doubled');
    if (!mounted) return;
    Navigator.of(context).pop();
    AdService.instance.onBattleFinished();
  }

  Future<void> _flee() async {
    if (_finished) return;
    final ok = await AppDialog.confirm(
      context: context,
      title: 'Flee the battle?',
      message: _live ? 'Your friend wins by forfeit.' : 'It counts as a loss and the energy is not refunded.',
      confirmLabel: 'Flee',
      cancelLabel: 'Keep fighting',
      destructive: true,
      icon: Icons.directions_run_rounded,
    );
    if (!ok || !mounted || _finished) return;
    final store = GameScope.read(context);
    widget.player.losses++;
    store.recordBattle(won: false);
    _finished = true;
    Navigator.of(context).pop();
  }

  // ---- UI -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final monsterSize = min(size.width * 0.5, 230.0);
    final title = switch (widget.mode) {
      BattleMode.ladder => 'STAGE ${widget.ladderStage! + 1}',
      BattleMode.friendGhost => 'FRIEND CHALLENGE',
      BattleMode.live => 'LIVE BATTLE',
    };
    return PopScope(
      canPop: _finished,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _flee();
      },
      child: Scaffold(
        body: GameBackground(
          tint: widget.enemy.element.color,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _flee,
                        icon: const Icon(Icons.close_rounded, color: AppColors.textDim),
                      ),
                      const Spacer(),
                      if (_live) const _LiveDot(),
                      Text(title, style: AppText.h3.copyWith(color: AppColors.textDim, letterSpacing: 2)),
                      const Spacer(),
                      SizedBox(
                        width: 48,
                        child: _live ? _TurnTimer(left: _turnLeft, total: _turnSeconds, active: !_busy && !_finished) : null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _shake,
                    builder: (context, child) {
                      final v = _shake.value;
                      final d = v > 0 && v < 1 ? sin(v * pi * 10) * _shakeAmp * (1 - v) : 0.0;
                      return Transform.translate(offset: Offset(d, d * 0.4), child: child);
                    },
                    child: LayoutBuilder(
                      builder: (c, box) {
                        return Stack(
                          key: _stackKey,
                          children: [
                            Positioned(
                              left: -40,
                              right: -40,
                              bottom: 10,
                              height: box.maxHeight * 0.45,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.elliptical(400, 120)),
                                  gradient: RadialGradient(colors: [Colors.white.withValues(alpha: 0.07), Colors.transparent]),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 8,
                              top: 8,
                              child: _HpCard(fighter: _s.foe, hp: _eHp, label: _live ? 'FRIEND' : null),
                            ),
                            Positioned(
                              right: 10,
                              top: box.maxHeight * 0.06,
                              child: _FighterSprite(
                                key: _eKey,
                                monster: widget.enemy,
                                size: monsterSize * 0.9,
                                lunge: _eLunge,
                                hit: _eHit,
                                lungeDir: const Offset(-0.45, 0.4),
                                facingLeft: true,
                                guarding: _eGuard,
                                fainted: _eFaint,
                                intro: _intro,
                                introFrom: const Offset(1.2, 0),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              bottom: box.maxHeight * 0.06,
                              child: _FighterSprite(
                                key: _pKey,
                                monster: widget.player,
                                size: monsterSize,
                                lunge: _pLunge,
                                hit: _pHit,
                                lungeDir: const Offset(0.45, -0.4),
                                guarding: _pGuard,
                                fainted: _pFaint,
                                intro: _intro,
                                introFrom: const Offset(-1.2, 0),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: box.maxHeight * 0.1,
                              child: _HpCard(fighter: _s.me, hp: _pHp, alignRight: true, label: _live ? 'YOU' : null),
                            ),
                            Positioned.fill(child: BattleFxLayer(controller: _fx)),
                            for (final p in _popups)
                              Positioned(
                                key: ValueKey(p.id),
                                left: p.onPlayer ? 20 : null,
                                right: p.onPlayer ? null : 20,
                                width: monsterSize,
                                top: (p.onPlayer ? box.maxHeight * 0.5 : box.maxHeight * 0.2) + p.slot * 44,
                                child: _FloatingText(popup: p),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _s.friendChose,
                  builder: (_, friendReady, _) => _BattleControls(
                    fighter: _s.me,
                    log: _log,
                    busy: _busy || _finished,
                    waiting: _waiting,
                    friendReady: _live && friendReady && !_busy,
                    friendName: widget.enemy.name,
                    onMove: _useMove,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
    child: Container(
      width: 9,
      height: 9,
      margin: const EdgeInsets.only(right: 8),
      decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
    ),
  );
}

class _TurnTimer extends StatelessWidget {
  const _TurnTimer({required this.left, required this.total, required this.active});
  final int left;
  final int total;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final urgent = left <= 5;
    return AnimatedOpacity(
      opacity: active ? 1 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(value: (left / total).clamp(0.0, 1.0), strokeWidth: 4, color: urgent ? AppColors.danger : AppColors.cyan, backgroundColor: Colors.white12),
            Text('${max(0, left)}', style: AppText.h3.copyWith(color: urgent ? AppColors.danger : AppColors.text)),
          ],
        ),
      ),
    );
  }
}

class _FighterSprite extends StatelessWidget {
  const _FighterSprite({
    super.key,
    required this.monster,
    required this.size,
    required this.lunge,
    required this.hit,
    required this.lungeDir,
    required this.guarding,
    required this.fainted,
    required this.intro,
    required this.introFrom,
    this.facingLeft = false,
  });

  final Monster monster;
  final double size;
  final AnimationController lunge;
  final AnimationController hit;
  final Offset lungeDir;
  final bool facingLeft;
  final bool guarding;
  final bool fainted;
  final AnimationController intro;
  final Offset introFrom;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([lunge, hit, intro]),
        builder: (_, _) {
          final l = Curves.easeOutCubic.transform(lunge.value);
          final h = hit.value;
          final knock = h > 0 && h < 1 ? sin(h * pi) * 0.06 : 0.0;
          final introT = Curves.easeOutBack.transform(intro.value);
          final offset = Offset(lungeDir.dx * size * l + introFrom.dx * size * (1 - introT) - lungeDir.dx.sign * knock * size, lungeDir.dy * size * l * 0.6);
          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: (facingLeft ? -1 : 1) * (l * 0.12 - knock * 1.5),
              child: AnimatedOpacity(
                opacity: fainted ? 0 : 1,
                duration: const Duration(milliseconds: 600),
                child: AnimatedSlide(
                  offset: fainted ? const Offset(0, 0.3) : Offset.zero,
                  duration: const Duration(milliseconds: 600),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MonsterView(monster: monster, size: size, facingLeft: facingLeft, flash: h > 0 && h < 0.5 ? 1 - h * 2 : 0),
                      AnimatedOpacity(
                        opacity: guarding ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: size * 0.9,
                          height: size * 0.9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.8), width: 3),
                            gradient: RadialGradient(colors: [Colors.transparent, AppColors.cyan.withValues(alpha: 0.25)]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HpCard extends StatelessWidget {
  const _HpCard({required this.fighter, required this.hp, this.alignRight = false, this.label});
  final Fighter fighter;
  final int hp;
  final bool alignRight;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final m = fighter.monster;
    final ratio = (hp / fighter.maxHp).clamp(0.0, 1.0);
    final color = ratio > 0.5 ? AppColors.success : (ratio > 0.2 ? AppColors.warning : AppColors.danger);
    return Container(
      width: 190,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: m.element.color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label!,
              style: AppText.small.copyWith(fontSize: 10, letterSpacing: 1.5, color: AppColors.textDim, fontWeight: FontWeight.w900),
            ),
          Row(
            children: [
              Text(m.element.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.h3),
              ),
              Text('Lv${m.level}', style: AppText.small.copyWith(color: AppColors.text)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6)),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: ratio),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              builder: (_, v, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: v.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (fighter.buffTurns > 0)
                Text(
                  'ATK↑ ',
                  style: AppText.small.copyWith(color: AppColors.danger, fontWeight: FontWeight.w900),
                ),
              const Spacer(),
              Text('$hp/${fighter.maxHp}', style: AppText.small.copyWith(color: AppColors.text)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FloatingText extends StatelessWidget {
  const _FloatingText({required this.popup});
  final _Popup popup;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      builder: (_, v, _) {
        final scale = v < 0.2 ? 0.6 + v * 3 : 1.2 - (v - 0.2) * 0.25;
        return Transform.translate(
          offset: Offset(0, -60 * v),
          child: Opacity(
            opacity: v < 0.7 ? 1 : (1 - (v - 0.7) / 0.3),
            child: Transform.scale(
              scale: scale,
              child: Text(
                popup.text,
                textAlign: TextAlign.center,
                style: AppText.display.copyWith(
                  fontSize: popup.big ? 40 : 28,
                  color: popup.color,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 3))],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BattleControls extends StatelessWidget {
  const _BattleControls({required this.fighter, required this.log, required this.busy, required this.waiting, required this.friendReady, required this.friendName, required this.onMove});
  final Fighter fighter;
  final String log;
  final bool busy;
  final bool waiting;
  final bool friendReady;
  final String friendName;
  final ValueChanged<Move> onMove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: Color(0xF0120E25),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: AppColors.stroke)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 42,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (waiting) ...[const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan)), const SizedBox(width: 10)],
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      log,
                      key: ValueKey(log),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: AppText.label.copyWith(color: AppColors.text),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: friendReady
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '✓ $friendName is ready — your move!',
                      style: AppText.small.copyWith(color: AppColors.success, fontWeight: FontWeight.w900),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: [
              for (final mv in fighter.moves) _MoveButton(move: mv, element: fighter.monster.element, cooldown: fighter.cooldownOf(mv), disabled: busy, color: _moveColor(mv), onTap: () => onMove(mv)),
            ],
          ),
        ],
      ),
    );
  }

  Color _moveColor(Move m) => switch (m.kind) {
    MoveKind.claw => const Color(0xFF5C6BC0),
    MoveKind.special => fighter.monster.element.color,
    MoveKind.roar => AppColors.danger,
    MoveKind.guard => const Color(0xFF26A69A),
  };
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({required this.move, required this.element, required this.cooldown, required this.disabled, required this.color, required this.onTap});
  final Move move;
  final BeastElement element;
  final int cooldown;
  final bool disabled;
  final Color color;
  final VoidCallback onTap;

  static IconData elementIcon(BeastElement e) => switch (e) {
    BeastElement.inferno => Icons.local_fire_department_rounded,
    BeastElement.frost => Icons.ac_unit_rounded,
    BeastElement.storm => Icons.bolt_rounded,
    BeastElement.tide => Icons.water_drop_rounded,
    BeastElement.terra => Icons.landscape_rounded,
    BeastElement.shadow => Icons.dark_mode_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final ready = cooldown == 0;
    final c = ready ? color : const Color(0xFF3A3458);
    final dark = HSLColor.fromColor(c).withLightness((HSLColor.fromColor(c).lightness - 0.2).clamp(0, 1)).toColor();
    final icon = switch (move.kind) {
      MoveKind.claw => const SwordIcon(size: 24),
      MoveKind.special => Icon(elementIcon(element), color: Colors.white, size: 24),
      MoveKind.roar => const Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
      MoveKind.guard => const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
    };
    return Pressable(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.55 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.only(left: 8, right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c, dark]),
            boxShadow: [BoxShadow(color: dark, offset: const Offset(0, 3))],
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: icon,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      move.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.h3.copyWith(color: Colors.white, fontSize: 15),
                    ),
                    Text(
                      ready ? move.description : 'Recharging…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small.copyWith(color: Colors.white70, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              if (!ready)
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                  child: Text('$cooldown', style: AppText.h3.copyWith(color: Colors.white, fontSize: 14)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Reward extends StatelessWidget {
  const _Reward(this.type, this.text);
  final Currency type;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CurrencyIcon(type, size: 22),
      const SizedBox(width: 4),
      Text(text, style: AppText.h2),
    ],
  );
}

class _RewardText extends StatelessWidget {
  const _RewardText(this.icon, this.color, this.text);
  final IconData icon;
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 4),
      Text(text, style: AppText.h2),
    ],
  );
}
