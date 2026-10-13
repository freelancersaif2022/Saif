import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../settings/settings_controller.dart';
import 'local_proxy_server.dart';
import 'proxy_isolate.dart';
import 'proxy_models.dart';
import 'upstream_connector.dart';

/// Starts the local proxy layer; replaced in tests.
typedef LocalProxyLauncher = Future<LocalProxyHandle> Function();

/// The running local proxy layer as seen by the controller.
abstract class LocalProxyHandle {
  int get port;
  Stream<LocalProxyEvent> get events;
  void configure({UpstreamProxy? upstream, required bool blockAll});
  Future<void> stop();
}

class _IsolateHandle implements LocalProxyHandle {
  _IsolateHandle(this._isolate);

  final LocalProxyIsolate _isolate;

  @override
  int get port => _isolate.port;

  @override
  Stream<LocalProxyEvent> get events => _isolate.events;

  @override
  void configure({UpstreamProxy? upstream, required bool blockAll}) =>
      _isolate.configure(upstream: upstream, blockAll: blockAll);

  @override
  Future<void> stop() => _isolate.stop();
}

final localProxyLauncherProvider = Provider<LocalProxyLauncher>(
  (ref) =>
      () async => _IsolateHandle(await LocalProxyIsolate.spawn()),
);

/// Checks that the upstream proxy accepts a tunnel; replaced in tests.
typedef ProxyProbe = Future<void> Function(UpstreamProxy proxy, String host, int port);

final proxyProbeProvider = Provider<ProxyProbe>((ref) {
  return (proxy, host, port) async {
    final tunnel = await UpstreamConnector(proxy).open(host, port);
    tunnel.destroy();
  };
});

final proxyListProvider = FutureProvider<List<ProxyProfile>>((ref) {
  ref.watch(proxyRevisionProvider);
  return ref.read(proxyRepositoryProvider).all();
});

final proxyRevisionProvider = NotifierProvider<_Revision, int>(_Revision.new);

class _Revision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final proxyControllerProvider = NotifierProvider<ProxyController, ProxyStatus>(ProxyController.new);

/// Connects the browser to a saved proxy through the local proxy layer and
/// reports the real connection state.
class ProxyController extends Notifier<ProxyStatus> {
  static const strictKey = 'proxy.strict';
  static const lastKey = 'proxy.last';

  LocalProxyHandle? _local;
  StreamSubscription<LocalProxyEvent>? _events;
  bool _overrideActive = false;
  int _consecutiveFailures = 0;
  int _attempt = 0;

  @override
  ProxyStatus build() {
    ref.onDispose(() {
      _events?.cancel();
      _local?.stop();
    });
    return const ProxyStatus();
  }

  bool get strictMode => ref.read(sharedPreferencesProvider).getBool(strictKey) ?? false;

  /// Called once at startup, before any tab loads, so proxy-only mode can
  /// block direct traffic from the first request.
  Future<void> initialize() async {
    if (!strictMode) return;
    await _enterBlocking();
    final last = ref.read(sharedPreferencesProvider).getInt(lastKey);
    if (last != null) unawaited(connect(last));
  }

  Future<void> setStrictMode(bool enabled) async {
    await ref.read(sharedPreferencesProvider).setBool(strictKey, enabled);
    if (enabled) {
      if (state.state != ProxyConnectionState.connected) await _enterBlocking();
    } else if (state.state != ProxyConnectionState.connected && state.state != ProxyConnectionState.connecting) {
      await _tearDown();
      state = ProxyStatus(
        state: state.state,
        failure: state.failure,
        profileId: state.profileId,
        profileName: state.profileName,
      );
    }
  }

  Future<void> connect(int profileId) async {
    final attempt = ++_attempt;
    final repo = ref.read(proxyRepositoryProvider);
    final profile = await repo.byId(profileId);
    if (profile == null) return;
    state = state.copyWith(
      state: ProxyConnectionState.connecting,
      profileId: profile.id,
      profileName: profile.name,
      clearFailure: true,
    );
    try {
      if (!ref.read(engineInfoProvider).proxyOverride) {
        throw const ProxyFailure(ProxyFailureKind.unsupported);
      }
      final upstream = await repo.upstreamFor(profileId);
      if (upstream == null) return;
      final probeHost = ref.read(settingsProvider).engine.host;
      await ref.read(proxyProbeProvider)(upstream, probeHost.isEmpty ? 'www.google.com' : probeHost, 443);
      if (attempt != _attempt) return;
      final local = await _ensureLocal();
      local.configure(upstream: upstream, blockAll: false);
      await _ensureOverride(local.port);
      _consecutiveFailures = 0;
      await ref.read(sharedPreferencesProvider).setInt(lastKey, profileId);
      state = ProxyStatus(
        state: ProxyConnectionState.connected,
        profileId: profile.id,
        profileName: profile.name,
        localPort: local.port,
      );
    } on ProxyFailure catch (failure) {
      if (attempt != _attempt) return;
      await _onConnectFailed(profile, failure);
    } on Object catch (e) {
      if (attempt != _attempt) return;
      await _onConnectFailed(profile, ProxyFailure(ProxyFailureKind.unreachable, e.toString()));
    }
  }

  Future<void> _onConnectFailed(ProxyProfile profile, ProxyFailure failure) async {
    // Never fall back to a direct connection on our own: if traffic was going
    // through a proxy (or proxy-only mode is on) it stays blocked until the
    // user retries or disconnects.
    final block = strictMode || _overrideActive;
    if (block) {
      await _enterBlocking();
    } else {
      await _tearDown();
    }
    state = ProxyStatus(
      state: ProxyConnectionState.failed,
      profileId: profile.id,
      profileName: profile.name,
      failure: failure,
      localPort: _local?.port,
      blockingDirect: block,
    );
  }

  Future<void> retry() async {
    final id = state.profileId;
    if (id != null) await connect(id);
  }

  Future<void> disconnect() async {
    _attempt++;
    await ref.read(sharedPreferencesProvider).remove(lastKey);
    if (strictMode) {
      await _enterBlocking();
      state = ProxyStatus(localPort: _local?.port, blockingDirect: true);
    } else {
      await _tearDown();
      state = const ProxyStatus();
    }
  }

  Future<void> onProfileDeleted(int id) async {
    if (state.profileId == id) await disconnect();
    ref.read(proxyRevisionProvider.notifier).bump();
  }

  /// `host:port` that app-side downloads must use, or null for direct.
  /// Throws when proxy-only mode blocks traffic.
  String? downloadRoute() {
    final port = state.localPort;
    if (port == null) return null;
    if (state.blockingDirect && state.state != ProxyConnectionState.connected) {
      throw const ProxyFailure(ProxyFailureKind.blocked);
    }
    return '127.0.0.1:$port';
  }

  Future<LocalProxyHandle> _ensureLocal() async {
    final existing = _local;
    if (existing != null) return existing;
    final local = await ref.read(localProxyLauncherProvider)();
    _local = local;
    _events = local.events.listen(_onLocalEvent);
    return local;
  }

  Future<void> _ensureOverride(int port) async {
    if (_overrideActive) return;
    try {
      await ref.read(browserEngineProvider).setProxyOverride('http://127.0.0.1:$port');
    } on Object catch (e) {
      throw ProxyFailure(ProxyFailureKind.unsupported, e.toString());
    }
    _overrideActive = true;
  }

  Future<void> _enterBlocking() async {
    try {
      final local = await _ensureLocal();
      local.configure(upstream: null, blockAll: true);
      await _ensureOverride(local.port);
      state = state.copyWith(localPort: local.port, blockingDirect: true);
    } on ProxyFailure catch (failure) {
      state = state.copyWith(state: ProxyConnectionState.failed, failure: failure);
    }
  }

  Future<void> _tearDown() async {
    if (_overrideActive) {
      await ref.read(browserEngineProvider).clearProxyOverride();
      _overrideActive = false;
    }
    await _events?.cancel();
    _events = null;
    final local = _local;
    _local = null;
    await local?.stop();
  }

  void _onLocalEvent(LocalProxyEvent event) {
    if (state.blockingDirect && state.state != ProxyConnectionState.connected) return;
    if (event.ok) {
      _consecutiveFailures = 0;
      if (state.state == ProxyConnectionState.failed) {
        state = state.copyWith(state: ProxyConnectionState.connected, clearFailure: true);
      }
      return;
    }
    final kind = event.kind ?? ProxyFailureKind.unreachable;
    // A website that cannot be reached through a working proxy is not a proxy failure.
    if (kind == ProxyFailureKind.targetFailed) return;
    _consecutiveFailures++;
    if (_consecutiveFailures >= 2 && state.state == ProxyConnectionState.connected) {
      state = state.copyWith(state: ProxyConnectionState.failed, failure: ProxyFailure(kind, event.detail));
    }
  }
}
