import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/url_resolver.dart';
import '../engine/system_bridge.dart';
import '../features/settings/settings_controller.dart';
import '../features/tabs/tabs_controller.dart';
import 'providers.dart';

final intentRouterProvider = Provider<IntentRouter>((ref) {
  final router = IntentRouter(ref);
  ref.onDispose(router.dispose);
  return router;
});

/// Opens links and shared text from other apps in a new regular tab.
class IntentRouter {
  IntentRouter(this._ref);

  final Ref _ref;
  StreamSubscription<IncomingIntent>? _sub;

  String? urlFor(IncomingIntent? intent) {
    if (intent == null) return null;
    final url = intent.url;
    if (url != null && UrlResolver.isWebUrl(url)) return url;
    final text = intent.text?.trim();
    if (text == null || text.isEmpty) return null;
    final link = RegExp(r'https?://\S+').firstMatch(text)?.group(0);
    if (link != null) return link;
    return UrlResolver.resolve(text, _ref.read(settingsProvider).engine);
  }

  void listen() {
    _sub ??= _ref.read(systemBridgeProvider).intents.listen((intent) {
      final url = urlFor(intent);
      if (url != null) _ref.read(tabsProvider.notifier).newTab(url: url, incognito: false);
    });
  }

  void dispose() => _sub?.cancel();
}
