import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/monster.dart';
import '../net/live_link.dart';
import 'battle_engine.dart';

class LiveDisconnected implements Exception {
  @override
  String toString() => 'Your friend disconnected.';
}

/// One battle as the screen sees it: "me" vs "foe". Events are always from
/// my point of view (byPlayer == done by me).
abstract class BattleSession {
  Fighter get me;
  Fighter get foe;
  bool get isLive;
  bool get canRevive;
  void revive();
  Future<List<BattleEvent>> submit(Move move);
  Future<void> dispose();

  bool get over => me.fainted || foe.fainted;
  bool get iWon => foe.fainted && !me.fainted;

  /// True once the friend has locked in a move this round (live only).
  final ValueNotifier<bool> friendChose = ValueNotifier(false);

  /// Fires when the live connection drops.
  final ValueNotifier<bool> lost = ValueNotifier(false);
}

/// Classic battle against the AI.
class LocalSession extends BattleSession {
  LocalSession(Monster mine, Monster enemy) : _engine = BattleEngine(mine, enemy);
  final BattleEngine _engine;

  @override
  Fighter get me => _engine.player;
  @override
  Fighter get foe => _engine.enemy;
  @override
  bool get isLive => false;
  @override
  bool get canRevive => !_engine.revived;
  @override
  void revive() => _engine.revivePlayer();
  @override
  Future<List<BattleEvent>> submit(Move move) async => _engine.playRound(move);
  @override
  Future<void> dispose() async {}
}

/// Real-time battle between two phones. The host runs the battle engine and
/// streams each round's results to the guest, so both screens always agree.
class LiveSession extends BattleSession {
  LiveSession._(this._link, this.isHost) {
    _sub = _link.messages.listen(_onMessage, onError: (_) => _lose(), onDone: _lose);
  }

  final LiveLink _link;
  final bool isHost;
  late final StreamSubscription<Map<String, dynamic>> _sub;
  late final Fighter _me;
  late final Fighter _foe;
  BattleEngine? _engine; // host only
  int _round = 0;
  bool _closed = false;

  final List<Map<String, dynamic>> _inbox = [];
  final List<(String, Completer<Map<String, dynamic>>)> _waiters = [];

  static const handshakeTimeout = Duration(seconds: 15);
  static const moveTimeout = Duration(seconds: 45);

  @override
  Fighter get me => _me;
  @override
  Fighter get foe => _foe;
  @override
  bool get isLive => true;
  @override
  bool get canRevive => false;
  @override
  void revive() {}

  // ---- Setup ----------------------------------------------------------------
  static Future<LiveSession> asHost(LiveHost host, Monster mine, String nonce) async {
    final link = await host.waitForGuest();
    final s = LiveSession._(link, true);
    try {
      final hello = await s._expect('hello', timeout: handshakeTimeout);
      final friend = Monster.fromChallengeCode(hello['m'] as String? ?? '');
      if (hello['n'] != nonce || friend == null) throw const FormatException('Invalid friend');
      final seed = Random().nextInt(1 << 31);
      s._engine = BattleEngine(mine, friend, random: Random(seed));
      s._me = s._engine!.player;
      s._foe = s._engine!.enemy;
      link.send({'t': 'start'});
      return s;
    } catch (e) {
      await s.dispose();
      rethrow;
    } finally {
      await host.close();
    }
  }

  static Future<LiveSession> asGuest(LiveInvite invite, Monster mine) async {
    final friend = Monster.fromChallengeCode(invite.monsterCode);
    if (friend == null) throw const FormatException('Invalid invite');
    final link = await LiveNet.join(invite.addresses, invite.port);
    final s = LiveSession._(link, false);
    try {
      link.send({'t': 'hello', 'n': invite.nonce, 'm': mine.toChallengeCode()});
      await s._expect('start', timeout: handshakeTimeout);
      s._me = Fighter(mine);
      s._foe = Fighter(friend);
      return s;
    } catch (e) {
      await s.dispose();
      rethrow;
    }
  }

  // ---- Rounds ---------------------------------------------------------------
  @override
  Future<List<BattleEvent>> submit(Move move) async {
    _round++;
    _link.send({'t': 'chose', 'r': _round});
    if (isHost) {
      Move guestMove;
      try {
        final msg = await _expect('move', timeout: moveTimeout);
        guestMove = _foe.moveOf(MoveKind.values[(msg['k'] as num).toInt()]);
      } on TimeoutException {
        guestMove = _foe.moveOf(MoveKind.claw); // friend went idle: auto-attack
      }
      final events = _engine!.playRound(move, enemyMove: guestMove);
      _link.send({'t': 'round', 'r': _round, 'ev': events.map((e) => e.toJson()).toList(), 'host': _me.snapshot(), 'guest': _foe.snapshot()});
      friendChose.value = false;
      return events;
    } else {
      _link.send({'t': 'move', 'r': _round, 'k': move.kind.index});
      final msg = await _expect('round', timeout: moveTimeout + const Duration(seconds: 15));
      // Host's "player" is the friend here, so events are flipped to my view.
      final events = (msg['ev'] as List).map((j) => BattleEvent.fromJson(Map<String, dynamic>.from(j as Map), _foe, _me).flipped()).toList();
      _foe.applySnapshot(Map<String, dynamic>.from(msg['host'] as Map));
      _me.applySnapshot(Map<String, dynamic>.from(msg['guest'] as Map));
      friendChose.value = false;
      return events;
    }
  }

  // ---- Messaging --------------------------------------------------------------
  void _onMessage(Map<String, dynamic> m) {
    final t = m['t'];
    if (t == 'chose') {
      friendChose.value = true;
      return;
    }
    if (t == 'bye') {
      _lose();
      return;
    }
    final i = _waiters.indexWhere((w) => w.$1 == t);
    if (i >= 0) {
      _waiters.removeAt(i).$2.complete(m);
    } else {
      _inbox.add(m);
    }
  }

  Future<Map<String, dynamic>> _expect(String type, {required Duration timeout}) {
    if (lost.value) return Future.error(LiveDisconnected());
    final i = _inbox.indexWhere((m) => m['t'] == type);
    if (i >= 0) return Future.value(_inbox.removeAt(i));
    final c = Completer<Map<String, dynamic>>();
    final entry = (type, c);
    _waiters.add(entry);
    return c.future.timeout(
      timeout,
      onTimeout: () {
        _waiters.remove(entry);
        throw TimeoutException('No $type from friend');
      },
    );
  }

  void _lose() {
    if (lost.value) return;
    lost.value = true;
    for (final w in _waiters) {
      if (!w.$2.isCompleted) w.$2.completeError(LiveDisconnected());
    }
    _waiters.clear();
  }

  @override
  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    _link.send({'t': 'bye'});
    await _sub.cancel();
    await _link.close();
  }
}
