import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'live_link.dart';

const bool supported = true;

Future<LiveHost> host() async {
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
  final addresses = await _localAddresses();
  return _IoHost(server, addresses);
}

Future<LiveLink> join(List<String> addresses, int port) async {
  Object? lastError;
  // Try every address the host advertised (Wi-Fi, hotspot, ...).
  for (final a in addresses) {
    try {
      final s = await Socket.connect(a, port, timeout: const Duration(seconds: 4));
      s.setOption(SocketOption.tcpNoDelay, true);
      return _IoLink(s);
    } catch (e) {
      lastError = e;
    }
  }
  throw lastError ?? const SocketException('No address to connect to');
}

Future<List<String>> _localAddresses() async {
  final list = await NetworkInterface.list(type: InternetAddressType.IPv4, includeLoopback: false);
  final out = <String>[];
  // Wi-Fi / hotspot interfaces first, mobile data last.
  int rank(NetworkInterface n) {
    final name = n.name.toLowerCase();
    if (name.startsWith('wlan') || name.startsWith('ap') || name.startsWith('swlan') || name.contains('wifi')) return 0;
    if (name.startsWith('eth') || name.startsWith('en')) return 1;
    return 2;
  }

  final sorted = [...list]..sort((a, b) => rank(a).compareTo(rank(b)));
  for (final n in sorted) {
    for (final a in n.addresses) {
      if (!a.isLoopback && !a.isLinkLocal) out.add(a.address);
    }
  }
  return out;
}

class _IoHost implements LiveHost {
  _IoHost(this._server, this.addresses);
  final ServerSocket _server;
  @override
  final List<String> addresses;

  @override
  int get port => _server.port;

  @override
  Future<LiveLink> waitForGuest() async {
    final s = await _server.first;
    s.setOption(SocketOption.tcpNoDelay, true);
    return _IoLink(s);
  }

  @override
  Future<void> close() => _server.close();
}

class _IoLink implements LiveLink {
  _IoLink(this._socket) {
    _socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            try {
              _ctrl.add(jsonDecode(line) as Map<String, dynamic>);
            } catch (_) {}
          },
          onError: (Object e) => _ctrl.addError(e),
          onDone: () => _ctrl.close(),
          cancelOnError: true,
        );
  }

  final Socket _socket;
  // Single-subscription so messages arriving before the session listens are buffered.
  final _ctrl = StreamController<Map<String, dynamic>>();
  bool _closed = false;

  @override
  Stream<Map<String, dynamic>> get messages => _ctrl.stream;

  @override
  void send(Map<String, dynamic> msg) {
    if (_closed) return;
    try {
      _socket.write('${jsonEncode(msg)}\n');
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      await _socket.flush();
    } catch (_) {}
    _socket.destroy();
    if (!_ctrl.isClosed) await _ctrl.close();
  }
}
