import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/app/app.dart';
import 'package:saif_browser/core/theme/app_colors.dart';
import 'package:saif_browser/core/theme/app_theme.dart';
import 'package:saif_browser/features/browser/widgets/page_error_view.dart';
import 'package:saif_browser/features/tabs/page_error.dart';
import 'package:saif_browser/features/tabs/tabs_controller.dart';

import '../support/fakes.dart';

Widget themed(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Accept platform-view creation calls for the WebView surface.
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
  });

  testWidgets('offline error page: icon, title, description and accent Retry button', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      themed(
        PageErrorView(
          error: PageError.fromWebView(
            url: 'https://example.com',
            code: -2,
            description: 'net::ERR_INTERNET_DISCONNECTED',
            online: false,
          ),
          onRetry: () => retried++,
          onBack: () {},
        ),
      ),
    );
    expect(find.text('No Internet Connection'), findsOneWidget);
    expect(find.text('Check your internet connection and try again.'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    expect(
      tester
          .widget<ColoredBox>(find.descendant(of: find.byType(PageErrorView), matching: find.byType(ColoredBox)).first)
          .color,
      AppColors.background,
    );

    final button = find.widgetWithText(FilledButton, 'Retry');
    expect(button, findsOneWidget);
    final style =
        tester.widget<FilledButton>(button).style ?? Theme.of(tester.element(button)).filledButtonTheme.style!;
    expect(style.backgroundColor!.resolve({}), AppColors.accent);
    expect(style.foregroundColor!.resolve({}), Colors.black);
    expect(tester.widget<Icon>(find.descendant(of: button, matching: find.byType(Icon))).icon, Icons.refresh_rounded);

    await tester.tap(button);
    expect(retried, 1);
  });

  testWidgets('SSL errors offer no way to bypass the certificate', (tester) async {
    await tester.pumpWidget(
      themed(
        PageErrorView(
          error: const PageError(kind: PageErrorKind.ssl, url: 'https://bad.example'),
          onRetry: () {},
          onBack: () {},
          canGoBack: true,
        ),
      ),
    );
    expect(find.text('Your connection is not private'), findsOneWidget);
    expect(find.text('Back to safety'), findsOneWidget);
    expect(find.textContaining('Continue'), findsNothing);
  });

  testWidgets('browser shell: new tab page, search and navigation', (tester) async {
    final h = await tester.runAsync(() => TestHarness.create());
    await tester.runAsync(() => h!.container.read(tabsProvider.notifier).restore());
    await tester.pumpWidget(UncontrolledProviderScope(container: h!.container, child: const SaifBrowserApp()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Saif'), findsOneWidget);
    expect(find.text('Search or type URL'), findsOneWidget);
    expect(find.byTooltip('Tabs (1 open)'), findsOneWidget);

    await tester.tap(find.text('Search or type URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'example.com');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(() => pump());
    await tester.pump(const Duration(milliseconds: 300));

    final id = h.container.read(tabsProvider).activeId!;
    expect(h.engine.calls, contains('createTab:$id:regular:https://example.com'));

    h.engine.emit(id, 'pageStarted', {'url': 'https://example.com/'});
    h.engine.emit(id, 'progress', {'value': 50});
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('example.com'), findsOneWidget);
    expect(find.byTooltip('Stop'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);

    h.engine.emit(id, 'error', {
      'url': 'https://example.com/',
      'code': -2,
      'description': 'net::ERR_INTERNET_DISCONNECTED',
      'online': false,
    });
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No Internet Connection'), findsOneWidget);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    expect(find.text('New private tab'), findsOneWidget);
    expect(find.text('Bookmarks'), findsOneWidget);
    await tester.tap(find.text('New private tab'));
    await tester.pumpAndSettle();
    expect(find.text('Private tab'), findsWidgets);
    expect(h.system.secure, isTrue, reason: 'private tabs are hidden from screenshots');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 15));
    await tester.runAsync(() async => h.dispose());
  });
}
