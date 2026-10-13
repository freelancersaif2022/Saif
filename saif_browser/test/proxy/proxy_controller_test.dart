// Test doubles hand socket and stream ownership to the code under test.
// ignore_for_file: close_sinks

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/app/providers.dart';
import 'package:saif_browser/features/proxy/local_proxy_server.dart';
import 'package:saif_browser/features/proxy/proxy_controller.dart';
import 'package:saif_browser/features/proxy/proxy_models.dart';

import '../support/fakes.dart';

/// Runs the real local proxy server in-process instead of on an isolate.
class InProcessHandle implements LocalProxyHandle {
  InProcessHandle._(this.server, this._events);

  final LocalProxyServer server;
  final StreamController<LocalProxyEvent> _events;
  UpstreamProxy? upstream;
  bool blockAll = true;
  bool stopped = false;

  static Future<InProcessHandle> start() async {
    final events = StreamController<LocalProxyEvent>.broadcast(sync: true);
    final server = LocalProxyServer(onEvent: events.add);
    await server.start();
    return InProcessHandle._(server, events);
  }

  void emit(LocalProxyEvent event) => _events.add(event);

  @override
  int get port => server.port!;

  @override
  Stream<LocalProxyEvent> get events => _events.stream;

  @override
  void configure({UpstreamProxy? upstream, required bool blockAll}) {
    this.upstream = upstream;
    this.blockAll = blockAll;
    server.configure(upstream: upstream, blockAll: blockAll);
  }

  @override
  Future<void> stop() async {
    stopped = true;
    await server.stop();
    await _events.close();
  }
}

void main() {
  late TestHarness h;
  late InProcessHandle? handle;
  late ProxyFailure? probeFailure;
  late int profileId;

  Future<void> setUpHarness({Map<String, Object> prefs = const {}}) async {
    handle = null;
    probeFailure = null;
    h = await TestHarness.create(
      prefs: prefs,
      overrides: [
        localProxyLauncherProvider.overrideWithValue(() async => handle = await InProcessHandle.start()),
        proxyProbeProvider.overrideWithValue((proxy, host, port) async {
          if (probeFailure != null) throw probeFailure!;
        }),
      ],
    );
    profileId = await h.container
        .read(proxyRepositoryProvider)
        .add(name: 'Office', type: ProxyType.socks5, host: 'proxy.example', port: 1080, username: 'u', password: 'p');
  }

  tearDown(() async {
    await handle?.stop();
    h.dispose();
  });

  ProxyStatus status() => h.container.read(proxyControllerProvider);
  ProxyController controller() => h.container.read(proxyControllerProvider.notifier);

  test('connect routes WebView traffic through the local proxy with decrypted credentials', () async {
    await setUpHarness();
    await controller().connect(profileId);
    expect(status().state, ProxyConnectionState.connected);
    expect(h.engine.proxyUrl, 'http://127.0.0.1:${handle!.port}');
    expect(handle!.upstream!.password, 'p');
    expect(handle!.upstream!.type, ProxyType.socks5);
    expect(controller().downloadRoute(), '127.0.0.1:${handle!.port}');
  });

  test('a failed connection attempt reports Failed and does not touch WebView', () async {
    await setUpHarness();
    probeFailure = const ProxyFailure(ProxyFailureKind.authFailed);
    await controller().connect(profileId);
    expect(status().state, ProxyConnectionState.failed);
    expect(status().failure!.kind, ProxyFailureKind.authFailed);
    expect(h.engine.proxyUrl, isNull);
  });

  test('runtime failures switch to Failed and recover on success', () async {
    await setUpHarness();
    await controller().connect(profileId);
    handle!.emit(const LocalProxyEvent.failure(ProxyFailureKind.unreachable, 'down'));
    expect(status().state, ProxyConnectionState.connected, reason: 'a single failure is tolerated');
    handle!.emit(const LocalProxyEvent.failure(ProxyFailureKind.unreachable, 'down'));
    expect(status().state, ProxyConnectionState.failed);
    expect(h.engine.proxyUrl, isNotNull, reason: 'never silently falls back to direct');
    handle!.emit(const LocalProxyEvent.success());
    expect(status().state, ProxyConnectionState.connected);
  });

  test('a website that cannot be reached is not a proxy failure', () async {
    await setUpHarness();
    await controller().connect(profileId);
    for (var i = 0; i < 3; i++) {
      handle!.emit(const LocalProxyEvent.failure(ProxyFailureKind.targetFailed, 'refused'));
    }
    expect(status().state, ProxyConnectionState.connected);
  });

  test('disconnect restores direct browsing when proxy-only mode is off', () async {
    await setUpHarness();
    await controller().connect(profileId);
    await controller().disconnect();
    expect(status().state, ProxyConnectionState.disconnected);
    expect(h.engine.proxyUrl, isNull);
    expect(handle!.stopped, isTrue);
    expect(controller().downloadRoute(), isNull);
  });

  test('proxy-only mode blocks traffic from startup until a proxy connects', () async {
    await setUpHarness(prefs: {ProxyController.strictKey: true});
    await controller().initialize();
    expect(h.engine.proxyUrl, isNotNull);
    expect(handle!.blockAll, isTrue);
    expect(status().blockingDirect, isTrue);
    expect(() => controller().downloadRoute(), throwsA(isA<ProxyFailure>()));

    await controller().connect(profileId);
    expect(handle!.blockAll, isFalse);
    expect(status().state, ProxyConnectionState.connected);

    await controller().disconnect();
    expect(handle!.blockAll, isTrue, reason: 'disconnecting in proxy-only mode keeps traffic blocked');
    expect(h.engine.proxyUrl, isNotNull);
    expect(status().blockingDirect, isTrue);
  });

  test('proxy-only mode reconnects to the last proxy on launch', () async {
    await setUpHarness(prefs: {ProxyController.strictKey: true});
    await h.container.read(sharedPreferencesProvider).setInt(ProxyController.lastKey, profileId);
    await controller().initialize();
    await pump(10);
    expect(status().state, ProxyConnectionState.connected);
  });

  test('failure while connected keeps traffic blocked instead of going direct', () async {
    await setUpHarness();
    await controller().connect(profileId);
    probeFailure = const ProxyFailure(ProxyFailureKind.unreachable);
    await controller().connect(profileId);
    expect(status().state, ProxyConnectionState.failed);
    expect(h.engine.proxyUrl, isNotNull);
    expect(handle!.blockAll, isTrue);
  });

  test('unsupported WebView reports a clear failure', () async {
    await setUpHarness();
    h.engine.proxySupported = false;
    await controller().connect(profileId);
    expect(status().state, ProxyConnectionState.failed);
    expect(status().failure!.kind, ProxyFailureKind.unsupported);
  });

  test('deleting the active proxy disconnects it', () async {
    await setUpHarness();
    await controller().connect(profileId);
    await h.container.read(proxyRepositoryProvider).delete(profileId);
    await controller().onProfileDeleted(profileId);
    expect(status().state, ProxyConnectionState.disconnected);
  });
}
