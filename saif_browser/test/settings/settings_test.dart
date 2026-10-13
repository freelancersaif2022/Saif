import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/app/providers.dart';
import 'package:saif_browser/features/settings/browser_settings.dart';
import 'package:saif_browser/features/settings/settings_controller.dart';
import 'package:saif_browser/features/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('defaults: light theme, lime accent, Google, privacy-preserving options', () {
    const s = BrowserSettings();
    expect(s.themeMode, ThemeMode.light);
    expect(s.accent, 'lime');
    expect(s.engine.id, 'google');
    expect(s.blockPopups, isTrue);
    expect(s.thirdPartyCookies, isFalse);
    expect(s.httpsFirst, isTrue);
    expect(s.blockPrivateScreenshots, isTrue);
  });

  test('settings persist and survive a restart', () async {
    final h = await TestHarness.create();
    await h.container
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            searchEngine: 'duckduckgo',
            themeMode: ThemeMode.dark,
            toolbarPosition: ToolbarPosition.bottom,
            textZoom: 130,
            javaScriptEnabled: false,
            downloadLocation: DownloadLocation.ask,
          ),
        );
    final prefs = h.container.read(sharedPreferencesProvider);
    final restored = SettingsRepository(prefs).load();
    expect(restored.searchEngine, 'duckduckgo');
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.toolbarPosition, ToolbarPosition.bottom);
    expect(restored.textZoom, 130);
    expect(restored.javaScriptEnabled, isFalse);
    expect(restored.downloadLocation, DownloadLocation.ask);
    h.dispose();
  });

  test('corrupted or partial settings fall back to defaults', () async {
    SharedPreferences.setMockInitialValues({'settings.v1': '{not json'});
    expect(SettingsRepository(await SharedPreferences.getInstance()).load(), const BrowserSettings());
    SharedPreferences.setMockInitialValues({
      'settings.v1': '{"textZoom": 999, "themeMode": "neon", "blockPopups": false}',
    });
    final s = SettingsRepository(await SharedPreferences.getInstance()).load();
    expect(s.textZoom, 300);
    expect(s.themeMode, ThemeMode.light);
    expect(s.blockPopups, isFalse);
  });

  test('reset restores defaults', () async {
    final h = await TestHarness.create();
    final c = h.container.read(settingsProvider.notifier);
    await c.update((s) => s.copyWith(accent: 'sky'));
    await c.reset();
    expect(h.container.read(settingsProvider), const BrowserSettings());
    h.dispose();
  });

  test('engine settings are derived from preferences and pushed to WebView', () async {
    final h = await TestHarness.create();
    var engine = h.container.read(engineSettingsProvider);
    expect(engine.mobileUserAgent, isNot(contains('; wv')));
    expect(engine.desktopUserAgent, contains('X11'));
    expect(engine.blockPopups, isTrue);
    await h.container
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(userAgentMode: UserAgentMode.custom, customUserAgent: 'MyAgent/1.0', blockPopups: false),
        );
    engine = h.container.read(engineSettingsProvider);
    expect(engine.mobileUserAgent, 'MyAgent/1.0');
    expect(engine.blockPopups, isFalse);
    h.dispose();
  });
}
