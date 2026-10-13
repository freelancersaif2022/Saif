// Test doubles hand socket and stream ownership to the code under test.
// ignore_for_file: close_sinks

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Plain HTTP origin server used as the "website" in network tests.
class TargetServer {
  TargetServer._(this.server);

  final HttpServer server;
  final List<HttpHeaders> requests = [];

  int get port => server.port;

  static Future<TargetServer> start({Uint8List? download}) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final target = TargetServer._(server);
    server.listen((request) async {
      target.requests.add(request.headers);
      if (request.uri.path == '/file.bin' && download != null) {
        final range = request.headers.value(HttpHeaders.rangeHeader);
        var start = 0;
        if (range != null) {
          start = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)!.group(1)!);
          request.response.statusCode = HttpStatus.partialContent;
        }
        request.response.headers.contentLength = download.length - start;
        request.response.add(download.sublist(start));
        await request.response.close();
        return;
      }
      if (request.uri.path == '/missing') {
        request.response.statusCode = 404;
        await request.response.close();
        return;
      }
      request.response.headers.contentType = ContentType.text;
      request.response.write('hello from target ${request.uri.path}');
      await request.response.close();
    });
    return target;
  }

  Future<void> close() => server.close(force: true);
}

Future<Socket> _connectMapped(String host, int port, int targetPort) {
  // "target.test" only exists inside the proxy, proving DNS happens there.
  if (host == 'target.test') return Socket.connect(InternetAddress.loopbackIPv4, targetPort);
  return Socket.connect(host, port);
}

/// Minimal HTTP proxy with optional Basic authentication.
class FakeHttpProxy {
  FakeHttpProxy._(this.server, this.username, this.password, this.targetPort);

  final ServerSocket server;
  final String? username;
  final String? password;
  final int targetPort;
  final List<String> requestLines = [];

  int get port => server.port;

  static Future<FakeHttpProxy> start({required int targetPort, String? username, String? password}) async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final proxy = FakeHttpProxy._(server, username, password, targetPort);
    server.listen(proxy._handle);
    return proxy;
  }

  Future<void> _handle(Socket client) async {
    final buffer = <int>[];
    Socket? upstream;
    final headDone = Completer<int>();
    client.listen(
      (data) {
        final up = upstream;
        if (up != null) {
          up.add(data);
          return;
        }
        buffer.addAll(data);
        final end = latin1.decode(buffer, allowInvalid: true).indexOf('\r\n\r\n');
        if (end >= 0 && !headDone.isCompleted) headDone.complete(end + 4);
      },
      onDone: () => upstream?.destroy(),
      onError: (Object _) => upstream?.destroy(),
    );
    final end = await headDone.future;
    final head = latin1.decode(buffer.sublist(0, end));
    final lines = head.split('\r\n');
    requestLines.add(lines.first);
    if (username != null) {
      final expected = 'Basic ${base64.encode(utf8.encode('$username:$password'))}';
      final auth = lines.firstWhere((l) => l.toLowerCase().startsWith('proxy-authorization:'), orElse: () => ':');
      if (auth.substring(auth.indexOf(':') + 1).trim() != expected) {
        client.add(latin1.encode('HTTP/1.1 407 Proxy Authentication Required\r\nContent-Length: 0\r\n\r\n'));
        await client.flush();
        client.destroy();
        return;
      }
    }
    final parts = lines.first.split(' ');
    final Socket up;
    if (parts[0] == 'CONNECT') {
      final hostPort = parts[1].split(':');
      up = await _connectMapped(hostPort[0], int.parse(hostPort[1]), targetPort);
      client.add(latin1.encode('HTTP/1.1 200 Connection established\r\n\r\n'));
      final rest = buffer.sublist(end);
      if (rest.isNotEmpty) up.add(rest);
    } else {
      final uri = Uri.parse(parts[1]);
      up = await _connectMapped(uri.host, uri.port, targetPort);
      up.add(buffer);
    }
    upstream = up;
    up.listen(client.add, onDone: client.destroy, onError: (Object _) => client.destroy());
  }

  Future<void> close() => server.close();
}

/// SOCKS5 proxy (RFC 1928) with optional username/password auth (RFC 1929).
class FakeSocksProxy {
  FakeSocksProxy._(this.server, this.username, this.password, this.targetPort);

  final ServerSocket server;
  final String? username;
  final String? password;
  final int targetPort;
  final List<String> requestedHosts = [];

  int get port => server.port;

  static Future<FakeSocksProxy> start({required int targetPort, String? username, String? password}) async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final proxy = FakeSocksProxy._(server, username, password, targetPort);
    server.listen(proxy._handle);
    return proxy;
  }

  Future<void> _handle(Socket client) async {
    final queue = <int>[];
    final waiters = <Completer<void>>[];
    Socket? upstream;
    client.listen(
      (data) {
        if (upstream != null) {
          upstream.add(data);
          return;
        }
        queue.addAll(data);
        for (final w in waiters) {
          if (!w.isCompleted) w.complete();
        }
        waiters.clear();
      },
      onDone: () => upstream?.destroy(),
      onError: (Object _) => upstream?.destroy(),
    );

    Future<List<int>> read(int n) async {
      while (queue.length < n) {
        final w = Completer<void>();
        waiters.add(w);
        await w.future;
      }
      final out = queue.sublist(0, n);
      queue.removeRange(0, n);
      return out;
    }

    final greeting = await read(2);
    final methods = await read(greeting[1]);
    if (username != null) {
      if (!methods.contains(2)) {
        client.add([5, 0xFF]);
        client.destroy();
        return;
      }
      client.add([5, 2]);
      await read(1);
      final ulen = (await read(1))[0];
      final user = utf8.decode(await read(ulen));
      final plen = (await read(1))[0];
      final pass = utf8.decode(await read(plen));
      if (user != username || pass != password) {
        client.add([1, 1]);
        client.destroy();
        return;
      }
      client.add([1, 0]);
    } else {
      client.add([5, 0]);
    }
    final request = await read(4);
    String host;
    if (request[3] == 3) {
      final len = (await read(1))[0];
      host = utf8.decode(await read(len));
    } else if (request[3] == 1) {
      host = InternetAddress.fromRawAddress(Uint8List.fromList(await read(4))).address;
    } else {
      host = InternetAddress.fromRawAddress(Uint8List.fromList(await read(16))).address;
    }
    final portBytes = await read(2);
    final port = (portBytes[0] << 8) | portBytes[1];
    requestedHosts.add(host);
    try {
      final up = await _connectMapped(host, port, targetPort);
      client.add([5, 0, 0, 1, 127, 0, 0, 1, 0, 0]);
      upstream = up;
      if (queue.isNotEmpty) {
        up.add(queue);
        queue.clear();
      }
      up.listen(client.add, onDone: client.destroy, onError: (Object _) => client.destroy());
    } on SocketException {
      client.add([5, 5, 0, 1, 0, 0, 0, 0, 0, 0]);
      client.destroy();
    }
  }

  Future<void> close() => server.close();
}

/// Sends a raw HTTP/1.0 GET over [socket] and returns the full response.
Future<String> rawGet(Socket socket, Stream<List<int>> input, String host, String path) async {
  socket.add(latin1.encode('GET $path HTTP/1.0\r\nHost: $host\r\n\r\n'));
  final bytes = await input.fold<List<int>>([], (a, b) => a..addAll(b)).timeout(const Duration(seconds: 10));
  return latin1.decode(bytes);
}
