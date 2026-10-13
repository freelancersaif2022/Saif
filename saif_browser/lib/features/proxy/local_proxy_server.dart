import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'byte_reader.dart';
import 'proxy_models.dart';
import 'upstream_connector.dart';

/// Event reported by the local proxy layer.
class LocalProxyEvent {
  const LocalProxyEvent.success() : ok = true, kind = null, detail = null;
  const LocalProxyEvent.failure(ProxyFailureKind this.kind, this.detail) : ok = false;

  final bool ok;
  final ProxyFailureKind? kind;
  final String? detail;

  Map<String, Object?> toMap() => {'ok': ok, 'kind': kind?.name, 'detail': detail};

  static LocalProxyEvent fromMap(Map<Object?, Object?> map) {
    if (map['ok'] == true) return const LocalProxyEvent.success();
    final kind = ProxyFailureKind.values.firstWhere(
      (k) => k.name == map['kind'],
      orElse: () => ProxyFailureKind.protocol,
    );
    return LocalProxyEvent.failure(kind, map['detail'] as String?);
  }
}

/// A loopback-only HTTP proxy that the WebView is pointed at. It forwards
/// every request through the configured upstream (HTTP, HTTPS or SOCKS5,
/// with authentication), which WebView cannot do on its own for SOCKS5 auth.
///
/// There is never a silent direct fallback: when [blockAll] is set or the
/// upstream fails, the request fails with a 502 and an `X-Saif-Proxy-Error`
/// header that the browser turns into an error page.
class LocalProxyServer {
  LocalProxyServer({required this.onEvent, this.securityContext});

  final void Function(LocalProxyEvent event) onEvent;
  final SecurityContext? securityContext;

  static const errorHeader = 'X-Saif-Proxy-Error';

  ServerSocket? _server;
  final Set<Socket> _sockets = {};
  UpstreamProxy? _upstream;
  bool _blockAll = true;
  DateTime _lastSuccessEvent = DateTime.fromMillisecondsSinceEpoch(0);

  int? get port => _server?.port;

  /// Sets where traffic goes. `upstream == null && !blockAll` connects
  /// directly (used only by tests).
  void configure({UpstreamProxy? upstream, required bool blockAll}) {
    _upstream = upstream;
    _blockAll = blockAll;
  }

  Future<int> start({int port = 0}) async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    _server = server;
    server.listen(_handle, onError: (Object _) {});
    return server.port;
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    for (final s in _sockets.toList()) {
      s.destroy();
    }
    _sockets.clear();
  }

  void _track(Socket socket) {
    _sockets.add(socket);
    socket.done.then((_) => _sockets.remove(socket), onError: (Object _) => _sockets.remove(socket));
  }

  void _reportSuccess() {
    final now = DateTime.now();
    if (now.difference(_lastSuccessEvent) < const Duration(seconds: 1)) return;
    _lastSuccessEvent = now;
    onEvent(const LocalProxyEvent.success());
  }

  Future<void> _handle(Socket client) async {
    _track(client);
    final reader = ByteReader(client);
    Uint8List headBytes;
    try {
      headBytes = await reader.readHttpHead();
    } on Object {
      client.destroy();
      return;
    }
    final head = latin1.decode(headBytes);
    final lines = head.split('\r\n');
    final requestLine = lines.first.split(' ');
    if (requestLine.length < 3) {
      _respondError(client, 400, ProxyFailureKind.protocol, connect: false);
      return;
    }
    final method = requestLine[0].toUpperCase();
    final target = requestLine[1];
    final version = requestLine[2];
    final isConnect = method == 'CONNECT';

    if (_blockAll) {
      _respondError(client, 502, ProxyFailureKind.blocked, connect: isConnect);
      return;
    }

    try {
      if (isConnect) {
        final hostPort = _parseAuthority(target, 443);
        if (hostPort == null) {
          _respondError(client, 400, ProxyFailureKind.protocol, connect: true);
          return;
        }
        final tunnel = await _openTunnel(hostPort.$1, hostPort.$2);
        _track(tunnel.socket);
        client.add(latin1.encode('HTTP/1.1 200 Connection Established\r\n\r\n'));
        _splice(reader.takeRest(), client, tunnel.input, tunnel.socket);
        _reportSuccess();
        return;
      }

      final uri = Uri.tryParse(target);
      if (uri == null || uri.scheme != 'http' || uri.host.isEmpty) {
        _respondError(client, 400, ProxyFailureKind.protocol, connect: false);
        return;
      }
      final headers = _forwardHeaders(lines.skip(1));
      final upstream = _upstream;
      if (upstream != null && upstream.type != ProxyType.socks5) {
        // HTTP(S) proxy: forward the absolute-form request to the proxy itself.
        final connector = UpstreamConnector(upstream, securityContext: securityContext);
        final socket = await connector.connectToProxy();
        _track(socket);
        final auth = connector.basicAuthorization;
        final out = StringBuffer('$method $target $version\r\n');
        headers.forEach(out.write);
        if (auth != null) out.write('Proxy-Authorization: $auth\r\n');
        out.write('Connection: close\r\n\r\n');
        socket.add(latin1.encode(out.toString()));
        _splice(reader.takeRest(), client, socket, socket);
      } else {
        final port = uri.hasPort ? uri.port : 80;
        final tunnel = await _openTunnel(uri.host, port);
        _track(tunnel.socket);
        final path = uri.hasQuery
            ? '${uri.path.isEmpty ? '/' : uri.path}?${uri.query}'
            : (uri.path.isEmpty ? '/' : uri.path);
        final out = StringBuffer('$method $path $version\r\n');
        headers.forEach(out.write);
        out.write('Connection: close\r\n\r\n');
        tunnel.socket.add(latin1.encode(out.toString()));
        _splice(reader.takeRest(), client, tunnel.input, tunnel.socket);
      }
      _reportSuccess();
    } on ProxyFailure catch (failure) {
      onEvent(LocalProxyEvent.failure(failure.kind, failure.detail));
      _respondError(client, 502, failure.kind, connect: isConnect);
    } on Object catch (e) {
      onEvent(LocalProxyEvent.failure(ProxyFailureKind.unreachable, e.toString()));
      _respondError(client, 502, ProxyFailureKind.unreachable, connect: isConnect);
    }
  }

  Future<Tunnel> _openTunnel(String host, int port) async {
    final upstream = _upstream;
    if (upstream == null) {
      try {
        // Ownership passes to the Tunnel; _splice destroys it.
        // ignore: close_sinks
        final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 15));
        return Tunnel(socket, socket);
      } on SocketException catch (e) {
        throw ProxyFailure(ProxyFailureKind.targetFailed, e.message);
      }
    }
    return UpstreamConnector(upstream, securityContext: securityContext).open(host, port);
  }

  /// Copies bytes both ways and tears both sockets down when either side ends.
  void _splice(Stream<Uint8List> fromClient, Socket client, Stream<Uint8List> fromTarget, Socket target) {
    var closed = false;
    void close() {
      if (closed) return;
      closed = true;
      client.destroy();
      target.destroy();
    }

    target.addStream(fromClient).then((_) => close(), onError: (Object _) => close());
    client.addStream(fromTarget).then((_) => close(), onError: (Object _) => close());
  }

  static List<String> _forwardHeaders(Iterable<String> lines) {
    const dropped = {'proxy-connection', 'proxy-authorization', 'connection', 'keep-alive'};
    final result = <String>[];
    for (final line in lines) {
      if (line.isEmpty) continue;
      final colon = line.indexOf(':');
      if (colon <= 0) continue;
      if (dropped.contains(line.substring(0, colon).trim().toLowerCase())) continue;
      result.add('$line\r\n');
    }
    return result;
  }

  static (String, int)? _parseAuthority(String value, int defaultPort) {
    if (value.startsWith('[')) {
      final end = value.indexOf(']');
      if (end < 0) return null;
      final host = value.substring(1, end);
      final rest = value.substring(end + 1);
      final port = rest.startsWith(':') ? int.tryParse(rest.substring(1)) : defaultPort;
      return port == null ? null : (host, port);
    }
    final colon = value.lastIndexOf(':');
    if (colon < 0) return (value, defaultPort);
    final port = int.tryParse(value.substring(colon + 1));
    if (port == null || port <= 0 || port > 65535) return null;
    return (value.substring(0, colon), port);
  }

  void _respondError(Socket client, int status, ProxyFailureKind kind, {required bool connect}) {
    final reason = status == 400 ? 'Bad Request' : 'Bad Gateway';
    final body = connect ? '' : _errorPage(kind);
    final bytes = utf8.encode(body);
    final head =
        'HTTP/1.1 $status $reason\r\n'
        '$errorHeader: ${kind.name}\r\n'
        'Content-Type: text/html; charset=utf-8\r\n'
        'Cache-Control: no-store\r\n'
        'Connection: close\r\n'
        'Content-Length: ${bytes.length}\r\n\r\n';
    try {
      client.add(latin1.encode(head));
      if (bytes.isNotEmpty) client.add(bytes);
      client.flush().whenComplete(client.destroy).catchError((Object _) {});
    } on Object {
      client.destroy();
    }
  }

  static String _errorPage(ProxyFailureKind kind) =>
      '<!doctype html><meta name="viewport" content="width=device-width">'
      '<title>Proxy connection failed</title>'
      '<body style="font-family:sans-serif;padding:24px">'
      '<h2>Proxy connection failed</h2><p>${const HtmlEscape().convert(kind.message)}</p></body>';
}
