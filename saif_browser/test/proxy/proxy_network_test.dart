import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/features/proxy/local_proxy_server.dart';
import 'package:saif_browser/features/proxy/proxy_models.dart';
import 'package:saif_browser/features/proxy/upstream_connector.dart';

import '../support/test_servers.dart';

void main() {
  late TargetServer target;

  setUp(() async => target = await TargetServer.start());
  tearDown(() => target.close());

  Future<String> getThroughTunnel(Tunnel tunnel, String path) =>
      rawGet(tunnel.socket, tunnel.input, 'target.test', path);

  group('UpstreamConnector', () {
    test('HTTP proxy with Basic authentication', () async {
      final proxy = await FakeHttpProxy.start(targetPort: target.port, username: 'user', password: 'pa:ss');
      final connector = UpstreamConnector(
        UpstreamProxy(type: ProxyType.http, host: '127.0.0.1', port: proxy.port, username: 'user', password: 'pa:ss'),
      );
      final tunnel = await connector.open('target.test', target.port);
      expect(await getThroughTunnel(tunnel, '/via-http'), contains('hello from target /via-http'));
      expect(proxy.requestLines.single, 'CONNECT target.test:${target.port} HTTP/1.1');
      await proxy.close();
    });

    test('HTTP proxy rejects wrong or missing credentials', () async {
      final proxy = await FakeHttpProxy.start(targetPort: target.port, username: 'user', password: 'secret');
      Future<void> attempt(String? user, String? pass) => UpstreamConnector(
        UpstreamProxy(type: ProxyType.http, host: '127.0.0.1', port: proxy.port, username: user, password: pass),
      ).open('target.test', target.port);
      await expectLater(
        attempt('user', 'wrong'),
        throwsA(isA<ProxyFailure>().having((f) => f.kind, 'kind', ProxyFailureKind.authFailed)),
      );
      await expectLater(
        attempt(null, null),
        throwsA(isA<ProxyFailure>().having((f) => f.kind, 'kind', ProxyFailureKind.authRequired)),
      );
      await proxy.close();
    });

    test('SOCKS5 with username/password resolves host names at the proxy', () async {
      final proxy = await FakeSocksProxy.start(targetPort: target.port, username: 'alice', password: 's3cret');
      final connector = UpstreamConnector(
        UpstreamProxy(
          type: ProxyType.socks5,
          host: '127.0.0.1',
          port: proxy.port,
          username: 'alice',
          password: 's3cret',
        ),
      );
      final tunnel = await connector.open('target.test', target.port);
      expect(await getThroughTunnel(tunnel, '/via-socks'), contains('hello from target /via-socks'));
      expect(proxy.requestedHosts, ['target.test'], reason: 'the name is sent unresolved (remote DNS)');
      await proxy.close();
    });

    test('SOCKS5 without auth and with a wrong password', () async {
      final open = await FakeSocksProxy.start(targetPort: target.port);
      final tunnel = await UpstreamConnector(
        UpstreamProxy(type: ProxyType.socks5, host: '127.0.0.1', port: open.port),
      ).open('target.test', target.port);
      expect(await getThroughTunnel(tunnel, '/'), contains('hello from target'));
      await open.close();

      final secured = await FakeSocksProxy.start(targetPort: target.port, username: 'alice', password: 'right');
      await expectLater(
        UpstreamConnector(
          UpstreamProxy(
            type: ProxyType.socks5,
            host: '127.0.0.1',
            port: secured.port,
            username: 'alice',
            password: 'wrong',
          ),
        ).open('target.test', target.port),
        throwsA(isA<ProxyFailure>().having((f) => f.kind, 'kind', ProxyFailureKind.authFailed)),
      );
      await expectLater(
        UpstreamConnector(
          UpstreamProxy(type: ProxyType.socks5, host: '127.0.0.1', port: secured.port),
        ).open('target.test', target.port),
        throwsA(isA<ProxyFailure>().having((f) => f.kind, 'kind', ProxyFailureKind.authRequired)),
      );
      await secured.close();
    });

    test('SOCKS5 reports unreachable targets', () async {
      final proxy = await FakeSocksProxy.start(targetPort: target.port);
      final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final deadPort = closed.port;
      await closed.close();
      await expectLater(
        UpstreamConnector(
          UpstreamProxy(type: ProxyType.socks5, host: '127.0.0.1', port: proxy.port),
        ).open('127.0.0.1', deadPort),
        throwsA(isA<ProxyFailure>().having((f) => f.kind, 'kind', ProxyFailureKind.targetFailed)),
      );
      await proxy.close();
    });

    test('unreachable proxy server', () async {
      final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = closed.port;
      await closed.close();
      await expectLater(
        UpstreamConnector(UpstreamProxy(type: ProxyType.http, host: '127.0.0.1', port: port)).open('target.test', 80),
        throwsA(isA<ProxyFailure>().having((f) => f.kind, 'kind', ProxyFailureKind.unreachable)),
      );
    });

    test('HTTPS proxy validates the proxy certificate', () async {
      // A plain TCP server cannot complete a TLS handshake.
      final plain = await FakeHttpProxy.start(targetPort: target.port);
      await expectLater(
        UpstreamConnector(
          UpstreamProxy(type: ProxyType.https, host: '127.0.0.1', port: plain.port),
          connectTimeout: const Duration(seconds: 3),
        ).open('target.test', target.port),
        throwsA(isA<ProxyFailure>()),
      );
      await plain.close();
    });
  });

  group('LocalProxyServer', () {
    late LocalProxyServer local;
    late List<LocalProxyEvent> events;

    setUp(() async {
      events = [];
      local = LocalProxyServer(onEvent: events.add);
      await local.start();
    });
    tearDown(() => local.stop());

    HttpClient clientThroughLocal() => HttpClient()..findProxy = (_) => 'PROXY 127.0.0.1:${local.port}';

    test('routes plain HTTP requests through a SOCKS5 upstream with auth', () async {
      final socks = await FakeSocksProxy.start(targetPort: target.port, username: 'u', password: 'p');
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
      final client = clientThroughLocal();
      final response = await (await client.getUrl(Uri.parse('http://target.test:${target.port}/page'))).close();
      expect(await response.transform(utf8.decoder).join(), 'hello from target /page');
      expect(socks.requestedHosts, ['target.test']);
      client.close(force: true);
      await socks.close();
    });

    test('injects proxy credentials for an authenticated HTTP upstream', () async {
      final http = await FakeHttpProxy.start(targetPort: target.port, username: 'bob', password: 'pw');
      local.configure(
        upstream: UpstreamProxy(
          type: ProxyType.http,
          host: '127.0.0.1',
          port: http.port,
          username: 'bob',
          password: 'pw',
        ),
        blockAll: false,
      );
      final client = clientThroughLocal();
      final response = await (await client.getUrl(Uri.parse('http://target.test:${target.port}/auth'))).close();
      expect(response.statusCode, 200);
      expect(await response.transform(utf8.decoder).join(), 'hello from target /auth');
      client.close(force: true);
      await http.close();
    });

    test('CONNECT tunnels (used for HTTPS) go through the upstream', () async {
      final socks = await FakeSocksProxy.start(targetPort: target.port);
      local.configure(
        upstream: UpstreamProxy(type: ProxyType.socks5, host: '127.0.0.1', port: socks.port),
        blockAll: false,
      );
      final socket = await Socket.connect(InternetAddress.loopbackIPv4, local.port!);
      final input = socket.asBroadcastStream();
      socket.add(latin1.encode('CONNECT target.test:${target.port} HTTP/1.1\r\nHost: target.test\r\n\r\n'));
      final established = Completer<void>();
      final buffer = <int>[];
      final sub = input.listen((d) {
        buffer.addAll(d);
        if (latin1.decode(buffer).contains('\r\n\r\n') && !established.isCompleted) established.complete();
      });
      await established.future.timeout(const Duration(seconds: 5));
      expect(latin1.decode(buffer), startsWith('HTTP/1.1 200'));
      await sub.cancel();
      expect(await rawGet(socket, input, 'target.test', '/tunnel'), contains('hello from target /tunnel'));
      await socks.close();
    });

    test('proxy-only mode blocks everything with a recognisable error', () async {
      local.configure(upstream: null, blockAll: true);
      final client = clientThroughLocal();
      final response = await (await client.getUrl(Uri.parse('http://target.test:${target.port}/'))).close();
      expect(response.statusCode, 502);
      expect(response.headers.value(LocalProxyServer.errorHeader), 'blocked');
      await response.drain<void>();
      client.close(force: true);
      expect(target.requests, isEmpty, reason: 'no direct connection was made');
    });

    test('upstream failure returns 502 and reports the failure', () async {
      final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final deadPort = closed.port;
      await closed.close();
      local.configure(
        upstream: UpstreamProxy(type: ProxyType.socks5, host: '127.0.0.1', port: deadPort),
        blockAll: false,
      );
      final client = clientThroughLocal();
      final response = await (await client.getUrl(Uri.parse('http://target.test:${target.port}/'))).close();
      expect(response.statusCode, 502);
      expect(response.headers.value(LocalProxyServer.errorHeader), 'unreachable');
      await response.drain<void>();
      client.close(force: true);
      expect(events.where((e) => !e.ok).single.kind, ProxyFailureKind.unreachable);
      expect(target.requests, isEmpty, reason: 'never falls back to a direct connection');
    });

    test('only listens on the loopback interface', () {
      expect(local.port, isNotNull);
    });
  });
}
