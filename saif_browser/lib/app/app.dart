import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/browser/browser_screen.dart';
import '../features/settings/settings_controller.dart';
import '../features/tabs/tabs_controller.dart';
import 'secure_window.dart';

class TrexBrowserApp extends ConsumerWidget {
  const TrexBrowserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = AppColors.accentFor(settings.accent);

    // Hide private pages from screenshots and the recent-apps preview.
    ref.listen<bool>(
      tabsProvider.select((s) => s.privateMode && s.private.isNotEmpty),
      (_, private) => ref
          .read(secureWindowProvider.notifier)
          .set('private', private && ref.read(settingsProvider).blockPrivateScreenshots),
    );
    ref.listen<bool>(settingsProvider.select((s) => s.blockPrivateScreenshots), (_, block) {
      final tabs = ref.read(tabsProvider);
      ref.read(secureWindowProvider.notifier).set('private', block && tabs.privateMode && tabs.private.isNotEmpty);
    });

    return MaterialApp(
      title: 'Trex Browser',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: accent),
      darkTheme: AppTheme.dark(accent: accent),
      themeMode: settings.themeMode,
      home: const BrowserScreen(),
    );
  }
}
