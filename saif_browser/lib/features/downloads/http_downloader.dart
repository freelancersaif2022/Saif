import 'dart:async';
import 'dart:io';

/// Downloads one URL to a file with dart:io, optionally through a proxy, with
/// resume support (HTTP Range) and cancellation.
class HttpDownloadTask {
  HttpDownloadTask({
    required this.url,
    required this.target,
    this.headers = const {},
    this.proxy,
    required this.onProgress,
  });

  final Uri url;
  final File target;
  final Map<String, String> headers;

  /// `host:port` of an HTTP proxy, or null for a direct connection.
  final String? proxy;
  final void Function(int received, int total) onProgress;

  HttpClient? _client;
  bool _canceled = false;

  bool get isCanceled => _canceled;

  void cancel() {
    _canceled = true;
    _client?.close(force: true);
  }

  /// Returns the final size. Throws [HttpDownloadException] on failure.
  Future<int> run() async {
    final client = _client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20)
      ..userAgent = null;
    if (proxy != null) client.findProxy = (_) => 'PROXY $proxy';
    IOSink? sink;
    try {
      var existing = await target.exists() ? await target.length() : 0;
      final request = await client.getUrl(url);
      request.followRedirects = true;
      request.maxRedirects = 10;
      headers.forEach(request.headers.set);
      if (existing > 0) request.headers.set(HttpHeaders.rangeHeader, 'bytes=$existing-');
      final response = await request.close();

      if (response.statusCode == HttpStatus.requestedRangeNotSatisfiable && existing > 0) {
        await response.drain<void>();
        onProgress(existing, existing);
        return existing;
      }
      if (response.statusCode != HttpStatus.ok && response.statusCode != HttpStatus.partialContent) {
        await response.drain<void>();
        throw HttpDownloadException('Server responded with HTTP ${response.statusCode}');
      }
      final resumed = response.statusCode == HttpStatus.partialContent && existing > 0;
      if (!resumed) existing = 0;
      final length = response.contentLength;
      final total = length >= 0 ? existing + length : -1;

      await target.parent.create(recursive: true);
      sink = target.openWrite(mode: resumed ? FileMode.append : FileMode.write);
      var received = existing;
      onProgress(received, total);
      await for (final chunk in response) {
        if (_canceled) throw const HttpDownloadException('Canceled');
        sink.add(chunk);
        received += chunk.length;
        onProgress(received, total);
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (total >= 0 && received < total) {
        throw HttpDownloadException('Connection closed early ($received of $total bytes)');
      }
      return received;
    } on HttpDownloadException {
      rethrow;
    } on SocketException catch (e) {
      throw HttpDownloadException(_canceled ? 'Canceled' : 'Network error: ${e.message}');
    } on HttpException catch (e) {
      throw HttpDownloadException(_canceled ? 'Canceled' : e.message);
    } on HandshakeException {
      throw const HttpDownloadException('Secure connection failed');
    } on FileSystemException catch (e) {
      throw HttpDownloadException('Could not write file: ${e.message}');
    } finally {
      await sink?.close().catchError((Object _) {});
      client.close(force: true);
      _client = null;
    }
  }
}

class HttpDownloadException implements Exception {
  const HttpDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}
