import 'dart:io';

import 'package:dragon_land/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every sound effect and music file exists', () {
    for (final s in Sfx.values) {
      expect(File('assets/audio/${s.file}').existsSync(), isTrue, reason: s.file);
    }
    for (final m in MusicTrack.values) {
      expect(File('assets/audio/${m.file}').existsSync(), isTrue, reason: m.file);
    }
  });

  test('every image referenced in lib/ exists', () {
    final pattern = RegExp(r"""['"](?:assets/images/)?([a-z0-9_]+\.png)['"]""");
    final referenced = <String>{};
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      for (final m in pattern.allMatches(f.readAsStringSync())) {
        referenced.add(m.group(1)!);
      }
    }
    // cloud_$i.png is built from an index
    referenced.addAll(['cloud_1.png', 'cloud_2.png', 'cloud_3.png', 'cloud_4.png']);
    expect(referenced, isNotEmpty);
    for (final name in referenced) {
      expect(File('assets/images/$name').existsSync(), isTrue, reason: name);
    }
  });

  test('bundled fonts exist with their licenses', () {
    for (final f in ['LilitaOne-Regular.ttf', 'Fredoka.ttf', 'OFL-LilitaOne.txt', 'OFL-Fredoka.txt']) {
      expect(File('assets/fonts/$f').existsSync(), isTrue, reason: f);
    }
  });
}
