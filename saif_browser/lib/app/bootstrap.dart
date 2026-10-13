import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/app_database.dart';
import '../engine/browser_engine.dart';
import '../engine/engine_event.dart';
import '../engine/system_bridge.dart';
import '../features/proxy/proxy_controller.dart';
import '../features/settings/settings_controller.dart';
import '../features/tabs/tabs_controller.dart';
import 'app.dart';
import 'intent_router.dart';
import 'providers.dart';

/// Opens local storage, connects the native engine, applies settings and the
/// proxy (before any page loads), restores tabs, then shows the UI.
Future<void> bootstrap() async {
  final engine = MethodChannelBrowserEngine();
  final system = MethodChannelSystemBridge();
  final results = await Future.wait<Object>([
    AppDatabase.open(),
    SharedPreferences.getInstance(),
    engine.init(),
    getApplicationSupportDirectory().then((d) => d.path),
  ]);

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(results[0] as AppDatabase),
      sharedPreferencesProvider.overrideWithValue(results[1] as SharedPreferences),
      browserEngineProvider.overrideWithValue(engine),
      systemBridgeProvider.overrideWithValue(system),
      engineInfoProvider.overrideWithValue(results[2] as EngineInfo),
      appSupportDirProvider.overrideWithValue(results[3] as String),
    ],
  );

  await startBrowser(container);
  runApp(UncontrolledProviderScope(container: container, child: const SaifBrowserApp()));
}

/// Shared startup sequence (also used by integration tests).
Future<void> startBrowser(ProviderContainer container) async {
  final engine = container.read(browserEngineProvider);
  await engine.applySettings(container.read(engineSettingsProvider));
  container.listen<EngineSettings>(engineSettingsProvider, (previous, next) {
    if (previous != next) unawaited(engine.applySettings(next));
  });

  // Proxy-only mode must be in place before the first request.
  await container.read(proxyControllerProvider.notifier).initialize();

  final initial = await container.read(systemBridgeProvider).consumeInitialIntent();
  final router = container.read(intentRouterProvider);
  await container.read(tabsProvider.notifier).restore(initialUrl: router.urlFor(initial));
  router.listen();
}
