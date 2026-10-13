import 'dart:async';
import 'dart:isolate';

import 'local_proxy_server.dart';
import 'proxy_models.dart';

/// Runs [LocalProxyServer] on a background isolate so proxied traffic never
/// competes with the UI thread.
class LocalProxyIsolate {
  LocalProxyIsolate._(this._isolate, this._commands, this.port, this._events, this._receivePort);

  final Isolate _isolate;
  final SendPort _commands;
  final ReceivePort _receivePort;
  final StreamController<LocalProxyEvent> _events;
  final int port;

  Stream<LocalProxyEvent> get events => _events.stream;

  static Future<LocalProxyIsolate> spawn() async {
    final receive = ReceivePort();
    final isolate = await Isolate.spawn(_main, receive.sendPort, debugName: 'local-proxy');
    final ready = Completer<(SendPort, int)>();
    final events = StreamController<LocalProxyEvent>.broadcast();
    receive.listen((message) {
      if (message is Map && message['type'] == 'ready') {
        ready.complete((message['commands'] as SendPort, message['port'] as int));
      } else if (message is Map && message['type'] == 'event') {
        events.add(LocalProxyEvent.fromMap(message['event'] as Map<Object?, Object?>));
      } else if (message is Map && message['type'] == 'error' && !ready.isCompleted) {
        ready.completeError(StateError(message['message'] as String? ?? 'proxy failed'));
      }
    });
    try {
      final (commands, port) = await ready.future.timeout(const Duration(seconds: 10));
      return LocalProxyIsolate._(isolate, commands, port, events, receive);
    } on Object {
      isolate.kill(priority: Isolate.immediate);
      receive.close();
      await events.close();
      rethrow;
    }
  }

  void configure({UpstreamProxy? upstream, required bool blockAll}) {
    _commands.send({'type': 'configure', 'upstream': upstream?.toMap(), 'blockAll': blockAll});
  }

  Future<void> stop() async {
    _commands.send({'type': 'stop'});
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
    await _events.close();
  }

  static Future<void> _main(SendPort out) async {
    final server = LocalProxyServer(onEvent: (event) => out.send({'type': 'event', 'event': event.toMap()}));
    final commands = ReceivePort();
    try {
      final port = await server.start();
      out.send({'type': 'ready', 'commands': commands.sendPort, 'port': port});
    } on Object catch (e) {
      out.send({'type': 'error', 'message': e.toString()});
      return;
    }
    await for (final message in commands) {
      if (message is! Map) continue;
      switch (message['type']) {
        case 'configure':
          final upstream = message['upstream'] as Map<Object?, Object?>?;
          server.configure(
            upstream: upstream == null ? null : UpstreamProxy.fromMap(upstream),
            blockAll: message['blockAll'] == true,
          );
        case 'stop':
          await server.stop();
          commands.close();
      }
    }
  }
}
