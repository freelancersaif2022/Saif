import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'asset_server.dart';

/// Messages sent by the engine (see engine_src/src/core/bridge.js).
sealed class EngineEvent {
  const EngineEvent();

  static EngineEvent? parse(String raw) {
    Object? json;
    try {
      json = jsonDecode(raw);
    } catch (_) {
      return null;
    }
    if (json is! Map) return null;
    final m = json.map((k, v) => MapEntry(k.toString(), v));
    switch (m['type']) {
      case 'loading':
        return EngineLoading((m['progress'] is num) ? (m['progress'] as num).toDouble().clamp(0, 1) : 0);
      case 'ready':
        return const EngineReady();
      case 'paused':
        return const EnginePaused();
      case 'resumed':
        return const EngineResumed();
      case 'restarted':
        return const EngineRestarted();
      case 'gameOver':
        final s = m['stats'];
        return EngineGameOver(s is Map ? s.map((k, v) => MapEntry(k.toString(), v)) : const {});
      case 'haptic':
        return EngineHaptic(m['kind'] == 'heavy');
      case 'layoutSaved':
      case 'layoutDone':
        return EngineLayout(_layout(m['layout']), done: m['type'] == 'layoutDone');
      case 'perf':
        return EnginePerf((m['fps'] as num?)?.toInt() ?? 0);
      case 'error':
        return EngineError(m['message']?.toString() ?? 'unknown error');
    }
    return null;
  }

  static Map<String, Map<String, double>> _layout(Object? v) {
    if (v is! Map) return {};
    final out = <String, Map<String, double>>{};
    v.forEach((k, p) {
      if (p is Map && p['x'] is num && p['y'] is num) {
        out[k.toString()] = {'x': (p['x'] as num).toDouble(), 'y': (p['y'] as num).toDouble()};
      }
    });
    return out;
  }
}

class EngineLoading extends EngineEvent {
  const EngineLoading(this.progress);
  final double progress;
}

class EngineReady extends EngineEvent {
  const EngineReady();
}

class EnginePaused extends EngineEvent {
  const EnginePaused();
}

class EngineResumed extends EngineEvent {
  const EngineResumed();
}

class EngineRestarted extends EngineEvent {
  const EngineRestarted();
}

class EngineGameOver extends EngineEvent {
  const EngineGameOver(this.stats);
  final Map<String, Object?> stats;
}

class EngineHaptic extends EngineEvent {
  const EngineHaptic(this.heavy);
  final bool heavy;
}

class EngineLayout extends EngineEvent {
  const EngineLayout(this.layout, {required this.done});
  final Map<String, Map<String, double>> layout;
  final bool done;
}

class EnginePerf extends EngineEvent {
  const EnginePerf(this.fps);
  final int fps;
}

class EngineError extends EngineEvent {
  const EngineError(this.message);
  final String message;
}

/// Owns the WebView that hosts the 3D engine and talks to window.game.
class GameBridge {
  GameBridge({required this.config, required this.onEvent});

  final Map<String, Object?> config;
  final void Function(EngineEvent event) onEvent;
  late final WebViewController controller;
  bool _booted = false;

  Future<void> init() async {
    final port = await AssetServer.instance.start();
    PlatformWebViewControllerCreationParams params = const PlatformWebViewControllerCreationParams();
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(params);
    }
    controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF070907))
      ..addJavaScriptChannel('GameBridge', onMessageReceived: (m) {
        final e = EngineEvent.parse(m.message);
        if (e != null) onEvent(e);
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => _boot(),
        onWebResourceError: (err) {
          if (err.isForMainFrame ?? false) onEvent(EngineError('${err.errorCode}: ${err.description}'));
        },
        // The engine never navigates; block anything that is not the local server.
        onNavigationRequest: (req) => Uri.tryParse(req.url)?.host == '127.0.0.1' ? NavigationDecision.navigate : NavigationDecision.prevent,
      ));
    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      // Engine audio starts without an extra tap.
      await platform.setMediaPlaybackRequiresUserGesture(false);
      if (kDebugMode) await AndroidWebViewController.enableDebugging(true);
    }
    await controller.loadRequest(Uri.parse('http://127.0.0.1:$port/index.html?host=1'));
  }

  Future<void> _boot() async {
    if (_booted) return;
    _booted = true;
    await run('window.game.boot(${jsonEncode(config)}).catch(function(e){window.GameBridge.postMessage(JSON.stringify({type:"error",message:String(e&&e.stack||e)}));});');
  }

  Future<void> run(String js) async {
    try {
      await controller.runJavaScript(js);
    } catch (e) {
      debugPrint('runJavaScript failed: $e');
    }
  }

  Future<void> pause() => run('window.game && window.game.pause(false)');
  Future<void> resume() => run('window.game && window.game.resume()');
  Future<void> restart() => run('window.game && window.game.restart()');
  Future<void> quit() => run('window.game && window.game.quit()');
  Future<void> setSettings(Map<String, Object?> s) => run('window.game && window.game.setSettings(${jsonEncode(s)})');
  Future<void> resetLayout() => run('window.game && window.game.resetLayout()');
}
