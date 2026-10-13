import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'byte_reader.dart';
import 'proxy_models.dart';

/// An open byte stream to a target host, possibly through a proxy.
class Tunnel {
  Tunnel(this.socket, this.input);

  final Socket socket;

  /// Bytes from the target. Use this instead of listening to [socket].
  final Stream<Uint8List> input;

  void destroy() => socket.destroy();
}

/// Opens connections to target hosts through an upstream proxy.
///
/// * HTTP / HTTPS proxies: `CONNECT host:port` (HTTPS wraps the proxy
///   connection in TLS with normal certificate validation). Basic
///   authentication is sent when credentials are configured.
/// * SOCKS5: RFC 1928 with username/password (RFC 1929). Host names are sent
///   to the proxy unresolved (ATYP 3), so DNS happens at the proxy.
class UpstreamConnector {
  UpstreamConnector(this.proxy, {this.connectTimeout = const Duration(seconds: 15), this.securityContext});

  final UpstreamProxy proxy;
  final Duration connectTimeout;

  /// Overridable for tests; null uses the platform trust store.
  final SecurityContext? securityContext;

  /// Opens the connection to the proxy server itself (TLS for HTTPS proxies).
  Future<Socket> connectToProxy() async {
    try {
      final socket = await Socket.connect(proxy.host, proxy.port, timeout: connectTimeout);
      if (proxy.type != ProxyType.https) return socket;
      try {
        // The TLS handshake gets its own deadline so a silent server cannot hang us.
        return await SecureSocket.secure(socket, host: proxy.host, context: securityContext).timeout(connectTimeout);
      } on Object {
        socket.destroy();
        rethrow;
      }
    } on HandshakeException catch (e) {
      throw ProxyFailure(ProxyFailureKind.tls, e.message);
    } on TlsException catch (e) {
      throw ProxyFailure(ProxyFailureKind.tls, e.message);
    } on SocketException catch (e) {
      final timedOut = e.message.toLowerCase().contains('timed out');
      throw ProxyFailure(timedOut ? ProxyFailureKind.timeout : ProxyFailureKind.unreachable, e.osError?.message);
    } on TimeoutException {
      throw const ProxyFailure(ProxyFailureKind.timeout);
    }
  }

  Future<Tunnel> open(String host, int port) async {
    final socket = await connectToProxy();
    socket.setOption(SocketOption.tcpNoDelay, true);
    final reader = ByteReader(socket);
    try {
      if (proxy.type == ProxyType.socks5) {
        await _socksHandshake(socket, reader, host, port);
      } else {
        await _httpConnect(socket, reader, host, port);
      }
      return Tunnel(socket, reader.takeRest());
    } on ProxyFailure {
      socket.destroy();
      rethrow;
    } on TimeoutException {
      socket.destroy();
      throw const ProxyFailure(ProxyFailureKind.timeout);
    } on SocketClosed {
      socket.destroy();
      throw const ProxyFailure(ProxyFailureKind.protocol, 'connection closed by proxy');
    } on Object catch (e) {
      socket.destroy();
      throw ProxyFailure(ProxyFailureKind.protocol, e.toString());
    }
  }

  static String authority(String host, int port) => host.contains(':') ? '[$host]:$port' : '$host:$port';

  String? get basicAuthorization {
    if (!proxy.hasCredentials) return null;
    final token = base64.encode(utf8.encode('${proxy.username}:${proxy.password ?? ''}'));
    return 'Basic $token';
  }

  Future<void> _httpConnect(Socket socket, ByteReader reader, String host, int port) async {
    final target = authority(host, port);
    final head = StringBuffer()
      ..write('CONNECT $target HTTP/1.1\r\n')
      ..write('Host: $target\r\n');
    final auth = basicAuthorization;
    if (auth != null) head.write('Proxy-Authorization: $auth\r\n');
    head.write('\r\n');
    socket.add(latin1.encode(head.toString()));
    final response = latin1.decode(await reader.readHttpHead(timeout: connectTimeout));
    final status = int.tryParse(response.split('\r\n').first.split(' ').elementAtOrNull(1) ?? '');
    if (status == null) throw const ProxyFailure(ProxyFailureKind.protocol, 'bad CONNECT response');
    if (status == 407) {
      throw ProxyFailure(proxy.hasCredentials ? ProxyFailureKind.authFailed : ProxyFailureKind.authRequired);
    }
    if (status < 200 || status >= 300) {
      throw ProxyFailure(ProxyFailureKind.targetFailed, 'HTTP $status');
    }
  }

  Future<void> _socksHandshake(Socket socket, ByteReader reader, String host, int port) async {
    final useAuth = proxy.hasCredentials;
    socket.add(useAuth ? [5, 2, 0, 2] : [5, 1, 0]);
    final choice = await reader.readExactly(2, timeout: connectTimeout);
    if (choice[0] != 5) throw const ProxyFailure(ProxyFailureKind.protocol, 'not a SOCKS5 proxy');
    if (choice[1] == 0xFF) {
      throw ProxyFailure(useAuth ? ProxyFailureKind.authFailed : ProxyFailureKind.authRequired);
    }
    if (choice[1] == 2) {
      if (!useAuth) throw const ProxyFailure(ProxyFailureKind.authRequired);
      final user = utf8.encode(proxy.username!);
      final pass = utf8.encode(proxy.password ?? '');
      if (user.length > 255 || pass.length > 255) {
        throw const ProxyFailure(ProxyFailureKind.authFailed, 'credentials too long');
      }
      socket.add([1, user.length, ...user, pass.length, ...pass]);
      final status = await reader.readExactly(2, timeout: connectTimeout);
      if (status[1] != 0) throw const ProxyFailure(ProxyFailureKind.authFailed);
    } else if (choice[1] != 0) {
      throw const ProxyFailure(ProxyFailureKind.protocol, 'unsupported SOCKS auth method');
    }

    final request = BytesBuilder()..add([5, 1, 0]);
    final ip = InternetAddress.tryParse(host);
    if (ip != null && ip.type == InternetAddressType.IPv4) {
      request
        ..addByte(1)
        ..add(ip.rawAddress);
    } else if (ip != null && ip.type == InternetAddressType.IPv6) {
      request
        ..addByte(4)
        ..add(ip.rawAddress);
    } else {
      final name = utf8.encode(host);
      if (name.length > 255) throw const ProxyFailure(ProxyFailureKind.targetFailed, 'host name too long');
      request
        ..addByte(3)
        ..addByte(name.length)
        ..add(name);
    }
    request.add([(port >> 8) & 0xFF, port & 0xFF]);
    socket.add(request.takeBytes());

    final reply = await reader.readExactly(4, timeout: connectTimeout);
    if (reply[0] != 5) throw const ProxyFailure(ProxyFailureKind.protocol, 'bad SOCKS reply');
    if (reply[1] != 0) throw ProxyFailure(ProxyFailureKind.targetFailed, _socksError(reply[1]));
    final addressLength = switch (reply[3]) {
      1 => 4,
      4 => 16,
      3 => (await reader.readExactly(1, timeout: connectTimeout))[0],
      _ => throw const ProxyFailure(ProxyFailureKind.protocol, 'bad SOCKS address type'),
    };
    await reader.readExactly(addressLength + 2, timeout: connectTimeout);
  }

  static String _socksError(int code) => switch (code) {
    1 => 'general SOCKS server failure',
    2 => 'connection not allowed by ruleset',
    3 => 'network unreachable',
    4 => 'host unreachable',
    5 => 'connection refused',
    6 => 'TTL expired',
    7 => 'command not supported',
    8 => 'address type not supported',
    _ => 'SOCKS error $code',
  };
}
