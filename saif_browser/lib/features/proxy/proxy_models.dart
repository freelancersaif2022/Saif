import 'package:flutter/foundation.dart';

enum ProxyType {
  http('HTTP'),
  https('HTTPS'),
  socks5('SOCKS5');

  const ProxyType(this.label);
  final String label;

  static ProxyType fromName(String name) => values.firstWhere((t) => t.name == name, orElse: () => ProxyType.http);
}

/// A proxy saved by the user. The password is stored encrypted and is not
/// part of this object.
@immutable
class ProxyProfile {
  const ProxyProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.host,
    required this.port,
    this.username,
    this.hasPassword = false,
  });

  final int id;
  final String name;
  final ProxyType type;
  final String host;
  final int port;
  final String? username;
  final bool hasPassword;

  String get address => '${host.contains(':') ? '[$host]' : host}:$port';
  bool get hasAuth => (username ?? '').isNotEmpty;
}

/// Upstream proxy settings handed to the local proxy layer (isolate-safe).
@immutable
class UpstreamProxy {
  const UpstreamProxy({required this.type, required this.host, required this.port, this.username, this.password});

  final ProxyType type;
  final String host;
  final int port;
  final String? username;
  final String? password;

  bool get hasCredentials => (username ?? '').isNotEmpty;

  Map<String, Object?> toMap() => {
    'type': type.name,
    'host': host,
    'port': port,
    'username': username,
    'password': password,
  };

  static UpstreamProxy fromMap(Map<Object?, Object?> map) => UpstreamProxy(
    type: ProxyType.fromName(map['type']! as String),
    host: map['host']! as String,
    port: map['port']! as int,
    username: map['username'] as String?,
    password: map['password'] as String?,
  );
}

/// Why a connection through the proxy failed.
enum ProxyFailureKind {
  unreachable('Could not connect to the proxy server'),
  timeout('The proxy server did not respond in time'),
  tls('Secure connection to the proxy failed'),
  authRequired('The proxy requires a username and password'),
  authFailed('The proxy rejected the username or password'),
  protocol('The proxy sent an invalid response'),
  targetFailed('The proxy could not reach the website'),
  blocked('Direct connections are blocked by proxy-only mode'),
  unsupported(
    'This Android System WebView cannot route traffic through a proxy. Update Android System WebView and try again.',
  );

  const ProxyFailureKind(this.message);
  final String message;
}

class ProxyFailure implements Exception {
  const ProxyFailure(this.kind, [this.detail]);

  final ProxyFailureKind kind;
  final String? detail;

  @override
  String toString() => detail == null ? kind.message : '${kind.message} ($detail)';
}

enum ProxyConnectionState { disconnected, connecting, connected, failed }

@immutable
class ProxyStatus {
  const ProxyStatus({
    this.state = ProxyConnectionState.disconnected,
    this.profileId,
    this.profileName,
    this.failure,
    this.localPort,
    this.blockingDirect = false,
  });

  final ProxyConnectionState state;
  final int? profileId;
  final String? profileName;
  final ProxyFailure? failure;

  /// Port of the local proxy layer the WebView is pointed at.
  final int? localPort;

  /// Proxy-only mode is on and no proxy is connected: everything is refused.
  final bool blockingDirect;

  bool get isActive => localPort != null;

  ProxyStatus copyWith({
    ProxyConnectionState? state,
    int? profileId,
    String? profileName,
    ProxyFailure? failure,
    bool clearFailure = false,
    int? localPort,
    bool clearPort = false,
    bool? blockingDirect,
  }) {
    return ProxyStatus(
      state: state ?? this.state,
      profileId: profileId ?? this.profileId,
      profileName: profileName ?? this.profileName,
      failure: clearFailure ? null : (failure ?? this.failure),
      localPort: clearPort ? null : (localPort ?? this.localPort),
      blockingDirect: blockingDirect ?? this.blockingDirect,
    );
  }
}
