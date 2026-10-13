import 'dart:async';
import 'dart:typed_data';

/// Buffers a socket stream so protocol handshakes can read exact byte counts
/// and then hand the rest of the stream (with backpressure) to a pipe.
class ByteReader {
  ByteReader(Stream<Uint8List> source) {
    _subscription = source.listen(_onData, onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  late final StreamSubscription<Uint8List> _subscription;
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  Completer<void>? _waiter;
  Object? _error;
  bool _done = false;
  StreamController<Uint8List>? _rest;

  void _onData(Uint8List data) {
    final rest = _rest;
    if (rest != null) {
      rest.add(data);
      return;
    }
    _buffer.add(data);
    _wake();
  }

  void _onError(Object error) {
    _error = error;
    _rest?.addError(error);
    _wake();
  }

  void _onDone() {
    _done = true;
    _rest?.close();
    _wake();
  }

  void _wake() {
    final w = _waiter;
    _waiter = null;
    w?.complete();
  }

  Future<void> _waitForData(Duration timeout) {
    final w = _waiter = Completer<void>();
    return w.future.timeout(timeout);
  }

  Future<Uint8List> readExactly(int count, {Duration timeout = const Duration(seconds: 20)}) async {
    while (_buffer.length < count) {
      if (_error != null) throw _error!;
      if (_done) throw const SocketClosed();
      await _waitForData(timeout);
    }
    final all = _buffer.takeBytes();
    final head = Uint8List.sublistView(all, 0, count);
    if (all.length > count) _buffer.add(Uint8List.sublistView(all, count));
    return Uint8List.fromList(head);
  }

  /// Reads up to and including the blank line that ends an HTTP header block.
  Future<Uint8List> readHttpHead({int maxBytes = 65536, Duration timeout = const Duration(seconds: 30)}) async {
    while (true) {
      final bytes = _buffer.toBytes();
      final end = _headerEnd(bytes);
      if (end >= 0) {
        _buffer.clear();
        if (bytes.length > end) _buffer.add(Uint8List.sublistView(bytes, end));
        return Uint8List.sublistView(bytes, 0, end);
      }
      if (bytes.length > maxBytes) throw const FormatException('Header too large');
      if (_error != null) throw _error!;
      if (_done) throw const SocketClosed();
      await _waitForData(timeout);
    }
  }

  static int _headerEnd(Uint8List b) {
    for (var i = 3; i < b.length; i++) {
      if (b[i] == 10 && b[i - 1] == 13 && b[i - 2] == 10 && b[i - 3] == 13) return i + 1;
    }
    return -1;
  }

  /// The remaining bytes (buffered first) as a stream that pauses the socket
  /// when the consumer is slow.
  Stream<Uint8List> takeRest() {
    final controller = _rest = StreamController<Uint8List>(
      onPause: _subscription.pause,
      onResume: _subscription.resume,
      onCancel: _subscription.cancel,
    );
    if (_buffer.isNotEmpty) controller.add(_buffer.takeBytes());
    if (_error != null) controller.addError(_error!);
    if (_done) controller.close();
    return controller.stream;
  }

  Future<void> cancel() => _subscription.cancel();
}

class SocketClosed implements Exception {
  const SocketClosed();

  @override
  String toString() => 'Connection closed';
}
