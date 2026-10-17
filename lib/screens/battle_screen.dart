import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../game/battle_engine.dart';
import '../game/monster_factory.dart';
import '../models/monster.dart';
import '../services/ads/ad_service.dart';
import '../services/game_store.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback.dart';
import '../widgets/monster_view.dart';
import '../widgets/ui.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.player, required this.enemy, this.ladderStage});
  final Monster player;
  final Monster enemy;
  final int? ladderStage;

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
  late final BattleEngine _engine = BattleEngine(widget.player, widget.enemy);
  late final AnimationController _pLunge = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
  late final AnimationController _eLunge = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
  late final AnimationController _pHit = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final AnimationController _eHit = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  bool _busy = false;
  bool _finished = false;
  bool _pGuard = false;
  bool _eGuard = false;
  bool _pFaint = false;
  bool _eFaint = false;
  String _log = '';
  final List<_Popup> _popups = [];
  int _popupId = 0;

  @override
  void initState() {
    super.initState();
    _log = 'A wild ${widget.enemy.name} appears!';
    Sfx.play(Fx.whoosh);
  }

  @override
  void dispose() {
    for (final c in [_pLunge, _eLunge, _pHit, _eHit, _intro]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _wait(int ms) => Future.delayed(Duration(milliseconds: ms));

  void _popup(String text, Color color, bool onPlayer, {bool big = false}) {
    final slot = _popups.where((x) => x.onPlayer == onPlayer).length;
    final p = _Popup(_popupId++, text, color, onPlayer, big: big, slot: slot);
    setState(() => _popups.add(p));
    Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _popups.remove(p));
    });
  }

  Future<void> _useMove(Move move) async {
    if (_busy || _finished) return;
    if (!_engine.player.isReady(move)) {
      AppToast.show('${move.name} is recharging (${_engine.player.cooldownOf(move)} turn${_engine.player.cooldownOf(move) > 1 ? 's' : ''}).', type: ToastType.info);
      return;
    }
    setState(() => _busy = true);
    final events = _engine.playRound(move);
    setState(() {
      _pGuard = _engine.player.guarding;
      _eGuard = _engine.enemy.guarding;
    });
    for (final ev in events) {
      if (!mounted) return;
      setState(() => _log = ev.text);
      await _animate(ev);
      await _wait(250);
    }
    if (!mounted) return;
    setState(() {
      _pGuard = false;
      _eGuard = false;
      _busy = false;
    });
    if (_engine.over) await _onBattleOver();
  }

  Future<void> _animate(BattleEvent ev) async {
    final lunge = ev.byPlayer ? _pLunge : _eLunge;
    final hit = ev.byPlayer ? _eHit : _pHit;
    final targetIsPlayer = !ev.byPlayer;
    switch (ev.type) {
      case EventType.attack:
        Sfx.play(Fx.whoosh, volume: 0.6);
        await lunge.forward(from: 0);
        Sfx.play(ev.crit ? Fx.crit : Fx.hit);
        Sfx.haptic(heavy: ev.crit);
        hit.forward(from: 0);
        setState(() {}); // HP bars animate to the new values
        _popup('-${ev.damage}', ev.crit ? AppColors.gold : Colors.white, targetIsPlayer, big: ev.crit);
        if (ev.effectiveness > 1) _popup('SUPER EFFECTIVE!', AppColors.success, targetIsPlayer);
        if (ev.effectiveness < 1) _popup('resisted', AppColors.textDim, targetIsPlayer);
        await lunge.reverse();
        await _wait(200);
      case EventType.miss:
        await lunge.forward(from: 0);
        _popup('MISS', AppColors.textDim, targetIsPlayer);
        await lunge.reverse();
      case EventType.roar:
        if (ev.byPlayer) {
          Sfx.roar(widget.player.roarPath);
        } else {
          Sfx.play(Fx.whoosh);
        }
        Sfx.haptic();
        _popup('ATK UP!', AppColors.danger, ev.byPlayer, big: true);
        await lunge.forward(from: 0);
        await lunge.reverse();
        await _wait(500);
      case EventType.guard:
        Sfx.play(Fx.guard);
        _popup(ev.heal > 0 ? '+${ev.heal}' : 'GUARD', AppColors.success, ev.byPlayer);
        setState(() {});
        await _wait(500);
      case EventType.faint:
        Sfx.play(Fx.whoosh);
        setState(() {
          if (ev.byPlayer) {
            _eFaint = true;
          } else {
            _pFaint = true;
          }
        });
        await _wait(700);
    }
  }

  Future<void> _onBattleOver() async {
    final store = GameScope.read(context);
    if (!_engine.playerWon && !_engine.revived) {
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
        _engine.revivePlayer();
        Sfx.play(Fx.levelup);
        setState(() {
          _pFaint = false;
          _log = '${widget.player.name} is back on its feet!';
        });
        _popup('REVIVED', AppColors.success, true, big: true);
        return;
      }
    }

    _finished = true;
    final won = _engine.playerWon;
    final stage = widget.ladderStage;
    final firstClear = won && stage != null && stage == store.ladderProgress;
    final boss = stage != null && MonsterFactory.isBoss(stage);
    final isFriend = stage == null;

    final coins = won ? (isFriend ? 60 : 40 + 12 * stage) : (isFriend ? 15 : 10);
    final xp = won ? 35 + 10 * widget.enemy.level : 12 + 2 * widget.enemy.level;
    final gems = firstClear ? (boss ? 15 : 5) : 0;
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
    Sfx.play(won ? Fx.win : Fx.lose);
    if (levels > 0) Future.delayed(const Duration(milliseconds: 700), () => Sfx.play(Fx.levelup));

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
      message: 'It counts as a loss and the energy is not refunded.',
      confirmLabel: 'Flee',
      cancelLabel: 'Keep fighting',
      destructive: true,
      icon: Icons.directions_run_rounded,
    );
    if (!ok || !mounted) return;
    final store = GameScope.read(context);
    widget.player.losses++;
    store.recordBattle(won: false);
    _finished = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final monsterSize = min(size.width * 0.5, 230.0);
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
                      Text(widget.ladderStage != null ? 'STAGE ${widget.ladderStage! + 1}' : 'FRIEND BATTLE', style: AppText.h3.copyWith(color: AppColors.textDim, letterSpacing: 2)),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (c, box) {
                      return Stack(
                        children: [
                          // Arena floor
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
                          // Enemy
                          Positioned(left: 8, top: 8, child: _HpCard(fighter: _engine.enemy)),
                          Positioned(
                            right: 10,
                            top: box.maxHeight * 0.06,
                            child: _FighterSprite(
                              monster: widget.enemy,
                              size: monsterSize * 0.9,
                              lunge: _eLunge,
                              hit: _eHit,
                              lungeDir: const Offset(-0.35, 0.35),
                              facingLeft: true,
                              guarding: _eGuard,
                              fainted: _eFaint,
                              intro: _intro,
                              introFrom: const Offset(1.2, 0),
                            ),
                          ),
                          // Player
                          Positioned(
                            left: 10,
                            bottom: box.maxHeight * 0.06,
                            child: _FighterSprite(
                              monster: widget.player,
                              size: monsterSize,
                              lunge: _pLunge,
                              hit: _pHit,
                              lungeDir: const Offset(0.35, -0.35),
                              guarding: _pGuard,
                              fainted: _pFaint,
                              intro: _intro,
                              introFrom: const Offset(-1.2, 0),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: box.maxHeight * 0.1,
                            child: _HpCard(fighter: _engine.player, alignRight: true),
                          ),
                          // Floating numbers
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
                _BattleControls(engine: _engine, log: _log, busy: _busy || _finished, onMove: _useMove),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FighterSprite extends StatelessWidget {
  const _FighterSprite({
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
    return AnimatedBuilder(
      animation: Listenable.merge([lunge, hit, intro]),
      builder: (_, _) {
        final l = Curves.easeOutCubic.transform(lunge.value);
        final h = hit.value;
        final shake = h > 0 && h < 1 ? sin(h * pi * 8) * 10 * (1 - h) : 0.0;
        final introT = Curves.easeOutBack.transform(intro.value);
        final offset = Offset(lungeDir.dx * size * l + shake + introFrom.dx * size * (1 - introT), lungeDir.dy * size * l * 0.6);
        return Transform.translate(
          offset: offset,
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
        );
      },
    );
  }
}

class _HpCard extends StatelessWidget {
  const _HpCard({required this.fighter, this.alignRight = false});
  final Fighter fighter;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final m = fighter.monster;
    final ratio = fighter.hpRatio.clamp(0.0, 1.0);
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
              Text('${fighter.hp}/${fighter.maxHp}', style: AppText.small.copyWith(color: AppColors.text)),
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
                  fontSize: popup.big ? 40 : 30,
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
  const _BattleControls({required this.engine, required this.log, required this.busy, required this.onMove});
  final BattleEngine engine;
  final String log;
  final bool busy;
  final ValueChanged<Move> onMove;

  @override
  Widget build(BuildContext context) {
    final p = engine.player;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: const BoxDecoration(
        color: Color(0xF0120E25),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: AppColors.stroke)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              key: ValueKey(log),
              height: 40,
              width: double.infinity,
              child: Center(
                child: Text(
                  log,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppText.label.copyWith(color: AppColors.text),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.7,
            children: [for (final mv in p.moves) _MoveButton(move: mv, cooldown: p.cooldownOf(mv), disabled: busy, color: _moveColor(mv), onTap: () => onMove(mv))],
          ),
        ],
      ),
    );
  }

  Color _moveColor(Move m) => switch (m.kind) {
    MoveKind.claw => const Color(0xFF5C6BC0),
    MoveKind.special => engine.player.monster.element.color,
    MoveKind.roar => AppColors.danger,
    MoveKind.guard => const Color(0xFF26A69A),
  };
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({required this.move, required this.cooldown, required this.disabled, required this.color, required this.onTap});
  final Move move;
  final int cooldown;
  final bool disabled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ready = cooldown == 0;
    final c = ready ? color : const Color(0xFF3A3458);
    final dark = HSLColor.fromColor(c).withLightness((HSLColor.fromColor(c).lightness - 0.2).clamp(0, 1)).toColor();
    return Pressable(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.55 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c, dark]),
            boxShadow: [BoxShadow(color: dark, offset: const Offset(0, 3))],
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      move.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.h3.copyWith(color: Colors.white),
                    ),
                    Text(
                      ready ? move.description : 'Recharging…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small.copyWith(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (!ready)
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                  child: Text('$cooldown', style: AppText.h3.copyWith(color: Colors.white)),
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
