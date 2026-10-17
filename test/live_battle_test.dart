import 'package:flutter_test/flutter_test.dart';
import 'package:voicebeast_arena/game/battle_engine.dart';
import 'package:voicebeast_arena/game/battle_session.dart';
import 'package:voicebeast_arena/game/monster_factory.dart';
import 'package:voicebeast_arena/net/live_link.dart';

void main() {
  test('live invite round-trips', () {
    final inv = LiveInvite(addresses: ['192.168.1.20', '192.168.43.1'], port: 40123, monsterCode: MonsterFactory.opponentForStage(4).toChallengeCode(), nonce: 'abc123');
    final back = LiveInvite.decode('Join me! ${inv.encode()}')!;
    expect(back.addresses, inv.addresses);
    expect(back.port, 40123);
    expect(back.nonce, 'abc123');
    expect(back.monsterCode, inv.monsterCode);
    expect(LiveInvite.decode('VBA1.notlive'), isNull);
  });

  test('battle events survive the network and flip sides', () {
    final a = Fighter(MonsterFactory.opponentForStage(2));
    final b = Fighter(MonsterFactory.opponentForStage(9));
    final ev = BattleEvent(type: EventType.attack, byPlayer: true, move: a.moveOf(MoveKind.special), damage: 42, crit: true, effectiveness: 1.5);
    final back = BattleEvent.fromJson(ev.toJson(), a, b);
    expect(back.damage, 42);
    expect(back.crit, isTrue);
    expect(back.move.kind, MoveKind.special);
    expect(back.flipped().byPlayer, isFalse);
  });

  test('two phones play a full live battle and always agree', () async {
    final hostBeast = MonsterFactory.opponentForStage(30)..name = 'Hosty';
    final guestBeast = MonsterFactory.opponentForStage(28)..name = 'Guesty';

    final host = await LiveNet.host();
    final invite = LiveInvite(addresses: ['127.0.0.1'], port: host.port, monsterCode: hostBeast.toChallengeCode(), nonce: 'n0nce');

    final hostFuture = LiveSession.asHost(host, hostBeast, 'n0nce');
    final guest = await LiveSession.asGuest(invite, guestBeast);
    final hostS = await hostFuture;

    expect(hostS.foe.monster.name, 'Guesty');
    expect(guest.foe.monster.name, 'Hosty');

    var rounds = 0;
    while (!hostS.over && rounds < 60) {
      rounds++;
      Move pick(BattleSession s) {
        final ready = s.me.moves.where(s.me.isReady).toList();
        return ready[rounds % ready.length];
      }

      // Both players choose at the same time.
      final results = await Future.wait([hostS.submit(pick(hostS)), guest.submit(pick(guest))]);
      final hostEvents = results[0];
      final guestEvents = results[1];

      // Same events, mirrored.
      expect(guestEvents.length, hostEvents.length);
      for (var i = 0; i < hostEvents.length; i++) {
        expect(guestEvents[i].byPlayer, !hostEvents[i].byPlayer);
        expect(guestEvents[i].damage, hostEvents[i].damage);
        expect(guestEvents[i].type, hostEvents[i].type);
      }
      // Same HP on both screens.
      expect(guest.me.hp, hostS.foe.hp);
      expect(guest.foe.hp, hostS.me.hp);
    }

    expect(hostS.over, isTrue, reason: 'battle should finish');
    expect(guest.over, isTrue);
    expect(guest.iWon, !hostS.iWon, reason: 'exactly one winner');

    await hostS.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(guest.lost.value, isTrue, reason: 'guest notices the host left');
    await guest.dispose();
  });

  test('wrong room code is rejected', () async {
    final host = await LiveNet.host();
    final invite = LiveInvite(addresses: ['127.0.0.1'], port: host.port, monsterCode: MonsterFactory.opponentForStage(1).toChallengeCode(), nonce: 'wrong');
    final hostFuture = LiveSession.asHost(host, MonsterFactory.opponentForStage(1), 'right');
    final guestFuture = LiveSession.asGuest(invite, MonsterFactory.opponentForStage(2));
    await expectLater(hostFuture, throwsA(anything));
    await expectLater(guestFuture, throwsA(anything));
  });
}
