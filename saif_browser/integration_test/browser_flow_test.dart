// End-to-end tests on a real Android device or emulator with network access:
//   flutter test integration_test -d <device-id>
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:saif_browser/app/bootstrap.dart';
import 'package:saif_browser/app/providers.dart';
import 'package:saif_browser/features/browser/browser_screen.dart';
import 'package:saif_browser/features/tabs/tabs_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> launch(WidgetTester tester) async {
    await bootstrap();
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(BrowserScreen)));
  }

  Future<void> waitFor(WidgetTester tester, bool Function() condition, {int seconds = 30}) async {
    for (var i = 0; i < seconds * 10; i++) {
      if (condition()) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('Condition not met within $seconds s');
  }

  testWidgets('loads a real website through the WebView with real loading events', (tester) async {
    final container = await launch(tester);
    await tester.tap(find.text('Search or type URL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'example.com');
    await tester.testTextInput.receiveAction(TextInputAction.go);

    await waitFor(tester, () => container.read(tabsProvider).active?.isLoading == true);
    await waitFor(tester, () => container.read(tabsProvider).active?.title == 'Example Domain');
    await waitFor(tester, () => container.read(tabsProvider).active?.isLoading == false);
    final tab = container.read(tabsProvider).active!;
    expect(tab.url, startsWith('https://example.com'));
    expect(tab.error, isNull);

    final history = await container.read(historyRepositoryProvider).page(query: 'example.com');
    expect(history, isNotEmpty);
  });

  testWidgets('multiple tabs load independently and back navigation works', (tester) async {
    final container = await launch(tester);
    final tabs = container.read(tabsProvider.notifier);
    await tabs.openInput('https://example.com');
    await waitFor(tester, () => container.read(tabsProvider).active?.title == 'Example Domain');
    await tabs.openInput('https://www.iana.org/help/example-domains');
    await waitFor(tester, () => container.read(tabsProvider).active?.canGoBack == true);
    expect(await tabs.handleBack(), isTrue);
    await waitFor(tester, () => container.read(tabsProvider).active?.url.startsWith('https://example.com') == true);

    final second = tabs.newTab(url: 'https://example.org');
    await waitFor(tester, () => container.read(tabsProvider).byId(second)?.isLoading == false);
    expect(container.read(tabsProvider).regular.length, greaterThanOrEqualTo(2));
  });

  testWidgets('DNS failures show an error page instead of a blank screen', (tester) async {
    final container = await launch(tester);
    await container.read(tabsProvider.notifier).openInput('https://does-not-exist.invalid');
    await waitFor(tester, () => container.read(tabsProvider).active?.error != null);
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });
}
