// Renders key screens to PNG files for visual review:
//   flutter test test_screens --dart-define=OUT=/path/to/dir
// Not part of the regular suite.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/app/app.dart';
import 'package:saif_browser/app/providers.dart';
import 'package:saif_browser/features/downloads/downloads_screen.dart';
import 'package:saif_browser/features/proxy/proxy_screen.dart';
import 'package:saif_browser/features/settings/settings_screen.dart';
import 'package:saif_browser/features/tabs/tab_overview_screen.dart';
import 'package:saif_browser/features/tabs/tabs_controller.dart';

import '../test/support/fakes.dart';

final _root = GlobalKey();
const out = String.fromEnvironment('OUT', defaultValue: '/tmp/saif_screens');

Future<void> loadFonts() async {
  const dir = '/opt/flutter-sdk/flutter/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final f in ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf', 'Roboto-Black.ttf']) {
    roboto.addFont(Future.value(ByteData.sublistView(File('$dir/$f').readAsBytesSync())));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File('$dir/MaterialIcons-Regular.otf').readAsBytesSync())));
  await icons.load();
}

Future<void> snap(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 400));
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_root));
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1));
  final bytes = await tester.runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
  Directory(out).createSync(recursive: true);
  File('$out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screens', (tester) async {
    await tester.runAsync(loadFonts);
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform_views,
      (call) async => switch (call.method) {
        'create' => 0,
        'resize' => {
          'width': (call.arguments as Map<Object?, Object?>)['width'],
          'height': (call.arguments as Map<Object?, Object?>)['height'],
        },
        _ => null,
      },
    );
    final h = (await tester.runAsync(() => TestHarness.create()))!;
    await tester.runAsync(() async {
      await h.container.read(shortcutRepositoryProvider).add('Wikipedia', 'https://wikipedia.org/');
      await h.container.read(historyRepositoryProvider).recordVisit('https://news.ycombinator.com/', 'Hacker News');
      await h.container.read(bookmarkRepositoryProvider).add(title: 'Flutter docs', url: 'https://docs.flutter.dev/');
      await h.container.read(tabsProvider.notifier).restore();
    });
    final theme = ThemeData(fontFamily: 'Roboto');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: RepaintBoundary(
          key: _root,
          child: Theme(data: theme, child: const TrexBrowserApp()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump(const Duration(seconds: 1));
    await snap(tester, '01_new_tab_page');

    final tabs = h.container.read(tabsProvider.notifier);
    await tester.runAsync(() => tabs.openInput('example.com'));
    final id = h.container.read(tabsProvider).activeId!;
    h.engine.emit(id, 'pageStarted', {'url': 'https://example.com/'});
    h.engine.emit(id, 'progress', {'value': 45});
    await tester.pump(const Duration(milliseconds: 500));
    await snap(tester, '02_loading');

    h.engine.emit(id, 'error', {
      'url': 'https://example.com/',
      'code': -2,
      'description': 'net::ERR_INTERNET_DISCONNECTED',
      'online': false,
    });
    await snap(tester, '03_offline_error');

    await tester.tap(find.byTooltip('More options'));
    await tester.pump(const Duration(seconds: 1));
    await snap(tester, '04_menu');
    Navigator.of(tester.element(find.text('New tab').first)).pop();
    await tester.pump(const Duration(seconds: 1));

    final nav = Navigator.of(tester.element(find.byType(Scaffold).first));
    for (final (name, screen) in [
      ('05_tabs', const TabOverviewScreen()),
      ('06_settings', const SettingsScreen()),
      ('07_proxy', const ProxyScreen()),
      ('08_downloads', const DownloadsScreen()),
    ]) {
      nav.push(MaterialPageRoute<void>(builder: (_) => screen));
      await tester.pump(const Duration(seconds: 1));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(seconds: 1));
      await snap(tester, name);
      nav.pop();
      await tester.pump(const Duration(seconds: 1));
    }

    nav.push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.scrollUntilVisible(find.text('Protect private tabs'), 300, scrollable: find.byType(Scrollable).last);
    await tester.pump(const Duration(seconds: 1));
    await snap(tester, '10_settings_scrolled');
    await tester.tap(find.text('Version 1.0.0 · T-rex Engine').first, warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));
    await snap(tester, '11_about');
    nav.pop();
    await tester.pump(const Duration(seconds: 1));
    nav.pop();
    await tester.pump(const Duration(seconds: 1));

    tabs.newTab(incognito: true);
    await tester.pump(const Duration(seconds: 1));
    await snap(tester, '09_private_tab');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 15));
    await tester.runAsync(() async => h.dispose());
  });
}
