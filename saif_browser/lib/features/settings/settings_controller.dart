import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/user_agents.dart';
import '../../engine/engine_event.dart';
import 'browser_settings.dart';

final settingsProvider = NotifierProvider<SettingsController, BrowserSettings>(SettingsController.new);

class SettingsController extends Notifier<BrowserSettings> {
  @override
  BrowserSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> update(BrowserSettings Function(BrowserSettings current) change) async {
    final next = change(state);
    if (next == state) return;
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> reset() async {
    await ref.read(settingsRepositoryProvider).reset();
    state = const BrowserSettings();
  }
}

/// WebView settings derived from user preferences and the device WebView.
final engineSettingsProvider = Provider<EngineSettings>((ref) {
  final s = ref.watch(settingsProvider);
  final info = ref.watch(engineInfoProvider);
  final base = info.defaultUserAgent;
  final mobile = switch (s.userAgentMode) {
    UserAgentMode.chrome => UserAgents.mobile(base),
    UserAgentMode.webview => base,
    UserAgentMode.custom => s.customUserAgent.trim().isEmpty ? UserAgents.mobile(base) : s.customUserAgent.trim(),
  };
  return EngineSettings(
    javaScriptEnabled: s.javaScriptEnabled,
    blockPopups: s.blockPopups,
    acceptCookies: s.acceptCookies,
    thirdPartyCookies: s.thirdPartyCookies,
    textZoom: s.textZoom,
    mobileUserAgent: mobile,
    desktopUserAgent: UserAgents.desktop(base),
    safeBrowsing: s.safeBrowsing,
    httpsFirst: s.httpsFirst,
    capturePasswords: s.offerToSavePasswords,
  );
});
