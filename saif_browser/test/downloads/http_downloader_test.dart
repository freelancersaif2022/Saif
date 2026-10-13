import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/features/downloads/http_downloader.dart';
import 'package:saif_browser/features/proxy/local_proxy_server.dart';
import 'package:saif_browser/features/proxy/proxy_models.dart';

import '../support/test_servers.dart';

void main() {
  final payload = Uint8List.fromList(List<int>.generate(300000, (i) => i % 256));
  late TargetServer target;
  late Directory dir;

  setUp(() async {
    target = await TargetServer.start(download: payload);
    dir = await Directory.systemTemp.createTemp('saif_dl');
  });
  tearDown(() async {
    await target.close();
    await dir.delete(recursive: true);
  });

  test('downloads a file with real progress and headers', () async {
    final progress = <int>[];
    final file = File('${dir.path}/file.bin');
    final task = HttpDownloadTask(
      url: Uri.parse('http://127.0.0.1:${target.port}/file.bin'),
      target: file,
      headers: {'Cookie': 'sid=1', 'User-Agent': 'TestAgent'},
      onProgress: (received, total) {
        expect(total, payload.length);
        progress.add(received);
      },
    );
    expect(await task.run(), payload.length);
    expect(await file.readAsBytes(), payload);
    expect(progress.first, 0);
    expect(progress.last, payload.length);
    expect(target.requests.single.value('cookie'), 'sid=1');
  });

  test('resumes a partial file with an HTTP range request', () async {
    final file = File('${dir.path}/file.bin');
    await file.writeAsBytes(payload.sublist(0, 1000));
    final task = HttpDownloadTask(
      url: Uri.parse('http://127.0.0.1:${target.port}/file.bin'),
      target: file,
      onProgress: (_, _) {},
    );
    expect(await task.run(), payload.length);
    expect(await file.readAsBytes(), payload);
    expect(target.requests.single.value('range'), 'bytes=1000-');
  });

  test('server errors fail the download', () async {
    final task = HttpDownloadTask(
      url: Uri.parse('http://127.0.0.1:${target.port}/missing'),
      target: File('${dir.path}/x'),
      onProgress: (_, _) {},
    );
    await expectLater(task.run(), throwsA(isA<HttpDownloadException>()));
  });

  test('downloads go through the proxy layer when one is set', () async {
    final socks = await FakeSocksProxy.start(targetPort: target.port, username: 'u', password: 'p');
    final local = LocalProxyServer(onEvent: (_) {});
    await local.start();
    local.configure(
      upstream: UpstreamProxy(
        type: ProxyType.socks5,
        host: '127.0.0.1',
        port: socks.port,
        username: 'u',
        password: 'p',
      ),
      blockAll: false,
    );
    final file = File('${dir.path}/proxied.bin');
    final task = HttpDownloadTask(
      url: Uri.parse('http://target.test:${target.port}/file.bin'),
      target: file,
      proxy: '127.0.0.1:${local.port}',
      onProgress: (_, _) {},
    );
    expect(await task.run(), payload.length);
    expect(socks.requestedHosts, ['target.test']);

    local.configure(upstream: null, blockAll: true);
    final blocked = HttpDownloadTask(
      url: Uri.parse('http://target.test:${target.port}/file.bin'),
      target: File('${dir.path}/blocked.bin'),
      proxy: '127.0.0.1:${local.port}',
      onProgress: (_, _) {},
    );
    await expectLater(blocked.run(), throwsA(isA<HttpDownloadException>()));
    await local.stop();
    await socks.close();
  });
}
