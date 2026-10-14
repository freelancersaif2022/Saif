import 'dart:convert';
import 'dart:io';

import 'package:alien_survival_3d/engine/asset_server.dart';
import 'package:alien_survival_3d/engine/game_bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBundle extends CachingAssetBundle {
  final files = <String, String>{
    'assets/game/index.html': '<html>engine</html>',
    'assets/game/game.js': 'window.game={}',
    'assets/game/audio/ui_click.ogg': 'OggS....',
  };

  @override
  Future<ByteData> load(String key) async {
    final f = files[key];
    if (f == null) throw FlutterError('missing $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(f)));
  }
}

void main() {
  group('AssetServer', () {
    late AssetServer server;
    late HttpClient client;
    setUp(() async {
      server = AssetServer(bundle: FakeBundle());
      await server.start();
      client = HttpClient();
    });
    tearDown(() async {
      client.close(force: true);
      await server.stop();
    });

    Future<(int, String, String?)> get(String path, {String method = 'GET'}) async {
      final req = await client.openUrl(method, Uri.parse('http://127.0.0.1:${server.port}$path'));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      return (res.statusCode, body, res.headers.contentType?.mimeType);
    }

    test('serves engine files with the right content types', () async {
      var (code, body, type) = await get('/index.html?host=1');
      expect(code, 200);
      expect(body, '<html>engine</html>');
      expect(type, 'text/html');
      (code, body, type) = await get('/game.js');
      expect((code, type), (200, 'text/javascript'));
      (code, _, type) = await get('/audio/ui_click.ogg');
      expect((code, type), (200, 'audio/ogg'));
      (code, body, _) = await get('/');
      expect(body, '<html>engine</html>');
    });

    test('blocks traversal, unknown types and non-GET methods', () async {
      expect((await get('/../pubspec.yaml')).$1, anyOf(403, 404));
      // percent-encoded dot segments are normalised away by Uri, so they cannot escape the root
      expect((await get('/%2e%2e/secret.js')).$1, anyOf(403, 404));
      expect((await get('/missing.js')).$1, 404);
      expect((await get('/data.bin')).$1, 403);
      expect((await get('/index.html', method: 'POST')).$1, 405);
    });

    test('asset key mapping', () {
      expect(server.assetKeyFor('/'), 'assets/game/index.html');
      expect(server.assetKeyFor('/audio/x.ogg'), 'assets/game/audio/x.ogg');
      expect(server.assetKeyFor('/a/../../b.js'), isNull);
      expect(server.assetKeyFor('/noext'), isNull);
    });

    test('page URI targets the loopback server in host mode', () {
      final u = server.pageUri();
      expect(u.host, '127.0.0.1');
      expect(u.port, server.port);
      expect(u.queryParameters['host'], '1');
    });
  });

  group('EngineEvent.parse', () {
    test('parses every engine message', () {
      expect(EngineEvent.parse('{"type":"loading","progress":0.5}'), isA<EngineLoading>().having((e) => e.progress, 'progress', 0.5));
      expect(EngineEvent.parse('{"type":"ready"}'), isA<EngineReady>());
      expect(EngineEvent.parse('{"type":"paused","user":true}'), isA<EnginePaused>());
      expect(EngineEvent.parse('{"type":"resumed"}'), isA<EngineResumed>());
      expect(EngineEvent.parse('{"type":"restarted"}'), isA<EngineRestarted>());
      final go = EngineEvent.parse('{"type":"gameOver","stats":{"score":10,"wave":2}}');
      expect(go, isA<EngineGameOver>().having((e) => e.stats['score'], 'score', 10));
      expect(EngineEvent.parse('{"type":"haptic","kind":"heavy"}'), isA<EngineHaptic>().having((e) => e.heavy, 'heavy', true));
      final lay = EngineEvent.parse('{"type":"layoutDone","layout":{"fire":{"x":0.8,"y":0.6},"bad":{"x":"?"}}}');
      expect(lay, isA<EngineLayout>().having((e) => e.done, 'done', true).having((e) => e.layout.keys.toList(), 'keys', ['fire']));
      expect(EngineEvent.parse('{"type":"perf","fps":41}'), isA<EnginePerf>());
      expect(EngineEvent.parse('{"type":"error","message":"boom"}'), isA<EngineError>().having((e) => e.message, 'm', 'boom'));
    });

    test('ignores malformed messages', () {
      expect(EngineEvent.parse('not json'), isNull);
      expect(EngineEvent.parse('[1,2]'), isNull);
      expect(EngineEvent.parse('{"type":"unknown"}'), isNull);
      expect(EngineEvent.parse('{"type":"loading","progress":"x"}'), isA<EngineLoading>().having((e) => e.progress, 'p', 0));
    });
  });

  test('bundled engine assets exist and match the engine sound table', () {
    final dir = Directory('assets/game');
    expect(File('${dir.path}/index.html').existsSync(), isTrue);
    expect(File('${dir.path}/game.js').lengthSync(), greaterThan(100000));
    final src = File('engine_src/src/audio/audio.js').readAsStringSync();
    final table = src.substring(src.indexOf('SOUNDS = {'), src.indexOf('const MAX_VOICES'));
    final names = RegExp(r'([a-z_0-9]+): \[').allMatches(table.replaceAll(RegExp(r'//.*'), '')).map((m) => m.group(1)!).toSet();
    expect(names.length, greaterThan(80));
    for (final n in names) {
      expect(File('assets/game/audio/$n.ogg').existsSync(), isTrue, reason: 'missing sound $n');
    }
  });
}
