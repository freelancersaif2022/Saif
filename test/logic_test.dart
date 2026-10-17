import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:voicebeast_arena/audio/voice_analyzer.dart';
import 'package:voicebeast_arena/game/battle_engine.dart';
import 'package:voicebeast_arena/game/monster_factory.dart';
import 'package:voicebeast_arena/models/element.dart';
import 'package:voicebeast_arena/models/monster.dart';

const sr = 16000;

/// Builds 3 s of 16-bit PCM: a harmonic "voice" at [hz] with optional noise.
Uint8List synth(double hz, {double amp = 0.5, double noise = 0.0, double vibrato = 0.0, int seed = 1}) {
  final r = Random(seed);
  final n = sr * 3;
  final bd = ByteData(n * 2);
  var phase = 0.0;
  for (var i = 0; i < n; i++) {
    final t = i / sr;
    final f = hz * (1 + vibrato * sin(2 * pi * 1.5 * t));
    phase += 2 * pi * f / sr;
    final env = min(1.0, t * 10) * min(1.0, (3 - t) * 10);
    var v = 0.6 * sin(phase) + 0.3 * sin(2 * phase) + 0.1 * sin(3 * phase);
    v = v * (1 - noise) + noise * (r.nextDouble() * 2 - 1);
    bd.setInt16(i * 2, (v * amp * env * 32767).round().clamp(-32768, 32767), Endian.little);
  }
  return bd.buffer.asUint8List();
}

VoiceProfile analyze(Uint8List pcm) => VoiceAnalyzer.analyze(AnalysisInput(pcm, sr));

void main() {
  group('VoiceAnalyzer', () {
    test('detects a deep voice pitch', () {
      final p = analyze(synth(110));
      expect(p.pitchHz, closeTo(110, 8));
      expect(p.roughness, lessThan(0.4));
    });

    test('detects a high voice pitch', () {
      final p = analyze(synth(420));
      expect(p.pitchHz, closeTo(420, 25));
    });

    test('louder roar measures louder', () {
      final quiet = analyze(synth(200, amp: 0.08));
      final loud = analyze(synth(200, amp: 0.8));
      expect(loud.loudnessDb, greaterThan(quiet.loudnessDb + 10));
    });

    test('noisy growl is rougher than a clean tone', () {
      final clean = analyze(synth(150));
      final raspy = analyze(synth(150, noise: 0.7));
      expect(raspy.roughness, greaterThan(clean.roughness));
    });

    test('silence is rejected with a friendly message', () {
      expect(() => analyze(Uint8List(sr * 6)), throwsA(isA<VoiceAnalysisException>()));
    });

    test('too short recording is rejected', () {
      expect(() => analyze(synth(200).sublist(0, 2000)), throwsA(isA<VoiceAnalysisException>()));
    });

    test('wav wrapper writes a valid header', () {
      final wav = pcmToWav(synth(200), sr);
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
      expect(wav.length, synth(200).length + 44);
    });
  });

  group('MonsterFactory', () {
    test('deep steady voice → tanky, high voice → fast', () {
      final deep = analyze(synth(95, amp: 0.6));
      final high = analyze(synth(480, amp: 0.6, vibrato: 0.08));
      final d = MonsterFactory.fromVoice(deep, seed: 5);
      final h = MonsterFactory.fromVoice(high, seed: 5);
      expect(d.stats.def, greaterThan(h.stats.def));
      expect(h.stats.spd, greaterThan(d.stats.spd));
      expect(d.element, BeastElement.terra);
    });

    test('voice → monster is deterministic for a seed', () {
      final v = analyze(synth(180));
      final a = MonsterFactory.fromVoice(v, seed: 99);
      final b = MonsterFactory.fromVoice(v, seed: 99);
      expect(a.stats.toList(), b.stats.toList());
      expect(a.name, b.name);
      expect(a.element, b.element);
    });

    test('ladder has 30 stages with growing levels and bosses', () {
      expect(MonsterFactory.totalStages, 30);
      final first = MonsterFactory.opponentForStage(0);
      final last = MonsterFactory.opponentForStage(29);
      expect(last.level, greaterThan(first.level));
      expect(MonsterFactory.isBoss(4), isTrue);
      expect(MonsterFactory.isBoss(3), isFalse);
    });
  });

  group('Monster', () {
    test('challenge code round-trips', () {
      final m = MonsterFactory.opponentForStage(12)..name = 'Grimthar';
      final code = m.toChallengeCode();
      final back = Monster.fromChallengeCode('Battle me! $code thanks')!;
      expect(back.name, 'Grimthar');
      expect(back.seed, m.seed);
      expect(back.element, m.element);
      expect(back.stats.toList(), m.stats.toList());
      expect(back.level, m.level);
      expect(back.stage, m.stage);
    });

    test('tampered challenge code is rejected', () {
      final code = MonsterFactory.opponentForStage(3).toChallengeCode();
      final tampered = code.replaceRange(8, 9, code[8] == 'A' ? 'B' : 'A');
      expect(Monster.fromChallengeCode(tampered), isNull);
      expect(Monster.fromChallengeCode('hello'), isNull);
    });

    test('xp levels up and caps at max level', () {
      final m = MonsterFactory.opponentForStage(0)..level = 1;
      expect(m.addXp(Monster.xpForLevel(1)), 1);
      expect(m.level, 2);
      m.addXp(1000000);
      expect(m.level, Monster.maxLevel);
      expect(m.addXp(100), 0);
    });

    test('json round-trip keeps everything', () {
      final v = analyze(synth(160));
      final m = MonsterFactory.fromVoice(v, seed: 3)
        ..level = 7
        ..xp = 20
        ..wins = 4;
      final back = Monster.fromJson(m.toJson());
      expect(back.toJson(), m.toJson());
    });
  });

  group('BattleEngine', () {
    test('every battle ends and has exactly one winner', () {
      for (var s = 0; s < 40; s++) {
        final a = MonsterFactory.opponentForStage(s % 30);
        final b = MonsterFactory.opponentForStage((s * 7) % 30);
        final e = BattleEngine(a, b, random: Random(s));
        var rounds = 0;
        while (!e.over && rounds < 200) {
          final ready = e.player.moves.where(e.player.isReady).toList();
          e.playRound(ready[rounds % ready.length]);
          rounds++;
        }
        expect(e.over, isTrue, reason: 'battle $s did not finish');
        expect(e.player.fainted != e.enemy.fainted, isTrue);
      }
    });

    test('cooldowns block repeated specials', () {
      final e = BattleEngine(MonsterFactory.opponentForStage(29), MonsterFactory.opponentForStage(0), random: Random(1));
      final special = e.player.moves.firstWhere((m) => m.kind == MoveKind.special);
      e.playRound(special);
      expect(e.player.isReady(special), isFalse);
    });

    test('type advantage multiplies damage', () {
      expect(BeastElement.tide.against(BeastElement.inferno), 1.5);
      expect(BeastElement.inferno.against(BeastElement.tide), 0.7);
      expect(BeastElement.tide.against(BeastElement.frost), 1.0);
    });

    test('revive restores half hp', () {
      final e = BattleEngine(MonsterFactory.opponentForStage(0), MonsterFactory.opponentForStage(29));
      e.player.hp = 0;
      e.revivePlayer();
      expect(e.player.hp, (e.player.maxHp * 0.5).round());
      expect(e.revived, isTrue);
    });
  });
}
