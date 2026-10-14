import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Serves the bundled 3D engine (assets/game/**) to the WebView from a
/// loopback-only HTTP server. Using http://127.0.0.1 instead of file:// lets the
/// engine fetch and decode its audio and keeps WebGL/WebAudio in a normal
/// secure-enough origin. Only GET/HEAD of files under assets/game are served.
class AssetServer {
  AssetServer({AssetBundle? bundle, this.root = 'assets/game'}) : _bundle = bundle ?? rootBundle;

  static final AssetServer instance = AssetServer();

  final AssetBundle _bundle;
  final String root;
  HttpServer? _server;
  Completer<int>? _starting;

  int? get port => _server?.port;

  Uri pageUri({Map<String, String> query = const {'host': '1'}}) =>
      Uri(scheme: 'http', host: '127.0.0.1', port: port, path: '/index.html', queryParameters: query);

  Future<int> start() async {
    if (_server != null) return _server!.port;
    if (_starting != null) return _starting!.future;
    final c = _starting = Completer<int>();
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0, shared: false);
      server.autoCompress = false;
      server.listen(_handle, onError: (Object e) => debugPrint('asset server error: $e'));
      _server = server;
      c.complete(server.port);
    } catch (e) {
      _starting = null;
      c.completeError(e);
    }
    return c.future;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _starting = null;
  }

  static const _types = {
    'html': 'text/html; charset=utf-8',
    'js': 'text/javascript; charset=utf-8',
    'css': 'text/css; charset=utf-8',
    'json': 'application/json',
    'ogg': 'audio/ogg',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'svg': 'image/svg+xml',
  };

  /// Maps a request path to an asset key, or null if it is not allowed.
  String? assetKeyFor(String rawPath) {
    var path = Uri.decodeFull(rawPath);
    if (path.isEmpty || path == '/') path = '/index.html';
    if (path.contains('..') || path.contains('\\') || path.contains('\u0000')) return null;
    final ext = path.contains('.') ? path.substring(path.lastIndexOf('.') + 1).toLowerCase() : '';
    if (!_types.containsKey(ext)) return null;
    return '$root$path';
  }

  Future<void> _handle(HttpRequest req) async {
    final res = req.response;
    try {
      // Reject anything that is not from this device.
      if (!req.connectionInfo!.remoteAddress.isLoopback) {
        res.statusCode = HttpStatus.forbidden;
        return;
      }
      if (req.method != 'GET' && req.method != 'HEAD') {
        res.statusCode = HttpStatus.methodNotAllowed;
        return;
      }
      final key = assetKeyFor(req.uri.path);
      if (key == null) {
        res.statusCode = HttpStatus.forbidden;
        return;
      }
      ByteData data;
      try {
        data = await _bundle.load(key);
      } catch (_) {
        res.statusCode = HttpStatus.notFound;
        return;
      }
      final ext = key.substring(key.lastIndexOf('.') + 1).toLowerCase();
      res.headers.contentType = ContentType.parse(_types[ext]!);
      res.headers.set(HttpHeaders.cacheControlHeader, ext == 'html' ? 'no-store' : 'max-age=3600');
      res.headers.contentLength = data.lengthInBytes;
      if (req.method == 'GET') res.add(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    } catch (e) {
      debugPrint('asset server: $e');
      res.statusCode = HttpStatus.internalServerError;
    } finally {
      await res.close();
    }
  }
}
