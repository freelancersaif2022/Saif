import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:saif_browser/app/providers.dart';
import 'package:saif_browser/core/utils/url_resolver.dart';
import 'package:saif_browser/features/downloads/downloads_controller.dart';
import 'package:saif_browser/features/settings/settings_controller.dart';
import 'package:saif_browser/features/tabs/page_error.dart';
import 'package:saif_browser/features/tabs/tabs_controller.dart';

import '../support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestHarness h;
  late TabsController tabs;

  Future<void> setUpHarness({Directory? dir}) async {
    h = await TestHarness.create(directory: dir);
    tabs = h.container.read(tabsProvider.notifier);
    await tabs.restore();
    await pump();
  }

  String activeId() => h.container.read(tabsProvider).activeId!;

  void loadPage(String tabId, String url, {String title = 'Title', bool canGoBack = false}) {
    h.engine.emit(tabId, 'pageStarted', {'url': url, 'canGoBack': canGoBack, 'canGoForward': false});
    h.engine.emit(tabId, 'progress', {'value': 60});
    h.engine.emit(tabId, 'title', {'title': title, 'url': url});
    h.engine.emit(tabId, 'pageFinished', {'url': url, 'title': title, 'canGoBack': canGoBack, 'canGoForward': false});
  }

  tearDown(() => h.dispose());

  test('starts with one new tab page tab', () async {
    await setUpHarness();
    final state = h.container.read(tabsProvider);
    expect(state.regular, hasLength(1));
    expect(state.active!.showNtp, isTrue);
    expect(h.engine.created, isEmpty, reason: 'no WebView until the user navigates');
  });

  test('typing a URL creates the WebView and navigates', () async {
    await setUpHarness();
    await tabs.openInput('example.com');
    final id = activeId();
    expect(h.engine.calls, contains('createTab:$id:regular:https://example.com'));
    final tab = h.container.read(tabsProvider).active!;
    expect(tab.showNtp, isFalse);
    expect(tab.isLoading, isTrue);

    await tabs.openInput('flutter riverpod');
    expect(h.engine.loaded[id], 'https://www.google.com/search?q=flutter+riverpod');
  });

  test('typing an http:// address allows that host explicitly', () async {
    await setUpHarness();
    await tabs.openInput('http://neverssl.com');
    expect(h.engine.allowedHttpHosts, ['neverssl.com']);
  });

  test('loading state follows real WebView events', () async {
    await setUpHarness();
    await tabs.openInput('example.com');
    final id = activeId();
    h.engine.emit(id, 'pageStarted', {'url': 'https://example.com/', 'canGoBack': false});
    expect(h.container.read(tabsProvider).active!.progress, 0);
    h.engine.emit(id, 'progress', {'value': 42});
    expect(h.container.read(tabsProvider).active!.progress, closeTo(0.42, 0.001));
    expect(h.container.read(tabsProvider).active!.isLoading, isTrue);
    h.engine.emit(id, 'title', {'title': 'Example Domain', 'url': 'https://example.com/'});
    h.engine.emit(id, 'pageFinished', {'url': 'https://example.com/', 'title': 'Example Domain'});
    final tab = h.container.read(tabsProvider).active!;
    expect(tab.isLoading, isFalse);
    expect(tab.title, 'Example Domain');
    expect(tab.isSecure, isTrue);
  });

  test('back, forward, reload and stop go to the active WebView', () async {
    await setUpHarness();
    await tabs.openInput('a.example');
    final id = activeId();
    loadPage(id, 'https://a.example/');
    loadPage(id, 'https://b.example/', canGoBack: true);
    expect(await tabs.handleBack(), isTrue);
    expect(h.engine.calls, contains('goBack:$id'));
    h.engine.emit(id, 'urlChanged', {'url': 'https://a.example/', 'canGoBack': false, 'canGoForward': true});
    await tabs.goForward();
    expect(h.engine.calls, contains('goForward:$id'));
    await tabs.reload();
    expect(h.engine.calls, contains('reload:$id'));
    h.engine.emit(id, 'pageStarted', {'url': 'https://a.example/'});
    await tabs.stop();
    expect(h.engine.calls, contains('stop:$id'));
    expect(h.container.read(tabsProvider).active!.isLoading, isFalse);
  });

  test('back from the first page returns to the new tab page, then the app goes to background', () async {
    await setUpHarness();
    await tabs.openInput('a.example');
    loadPage(activeId(), 'https://a.example/');
    expect(await tabs.handleBack(), isTrue);
    expect(h.container.read(tabsProvider).active!.showNtp, isTrue);
    expect(await tabs.handleBack(), isTrue, reason: 'returns to the page that is still loaded');
    expect(h.container.read(tabsProvider).active!.showNtp, isFalse);
    tabs.showNewTabPage(activeId());
    final fresh = tabs.newTab();
    await pump();
    expect(activeId(), fresh);
    expect(await tabs.handleBack(), isFalse);
  });

  test('multiple tabs: switch, duplicate, reorder, close and reopen', () async {
    await setUpHarness();
    await tabs.openInput('one.example');
    final first = activeId();
    loadPage(first, 'https://one.example/', title: 'One');
    final second = tabs.newTab(url: 'https://two.example/');
    await pump();
    expect(activeId(), second);
    expect(h.engine.calls, contains('visible:$first:false'));

    await tabs.switchTo(first);
    expect(activeId(), first);

    final copy = tabs.duplicate(first)!;
    await pump();
    final order = h.container.read(tabsProvider).regular.map((t) => t.id).toList();
    expect(order, [first, copy, second]);

    tabs.reorder(2, 0, private: false);
    expect(h.container.read(tabsProvider).regular.first.id, second);

    await tabs.switchTo(first);
    await tabs.close(first);
    expect(h.engine.disposed, contains(first));
    expect(h.container.read(tabsProvider).regular.map((t) => t.id), isNot(contains(first)));
    expect(h.container.read(tabsProvider).recentlyClosed.first.url, 'https://one.example/');
    // Closing one tab leaves the others' native state untouched.
    expect(h.engine.disposed, isNot(contains(second)));

    await tabs.reopenClosed();
    await pump();
    expect(h.container.read(tabsProvider).active!.url, 'https://one.example/');
  });

  test('closing the last regular tab opens a fresh one', () async {
    await setUpHarness();
    await tabs.close(activeId());
    await pump();
    expect(h.container.read(tabsProvider).regular, hasLength(1));
  });

  test('background WebViews beyond the budget are suspended', () async {
    await setUpHarness();
    final ids = <String>[];
    for (var i = 0; i < TabsController.maxLiveBackgroundTabs + 3; i++) {
      ids.add(tabs.newTab(url: 'https://site$i.example/'));
      await pump();
    }
    expect(h.engine.suspended, hasLength(2), reason: 'the two least recently used tabs');
    expect(h.engine.suspended, containsAll([ids[0], ids[1]]));
    expect(h.engine.suspended, isNot(contains(activeId())));
  });

  test('history is recorded for regular tabs only', () async {
    await setUpHarness();
    await tabs.openInput('history.example');
    loadPage(activeId(), 'https://history.example/', title: 'Recorded');
    await pump(10);
    var page = await h.container.read(historyRepositoryProvider).page();
    expect(page.single.title, 'Recorded');

    tabs.newTab(incognito: true);
    await pump();
    await tabs.openInput('secret.example');
    final privateId = activeId();
    expect(h.engine.calls, contains('createTab:$privateId:private:https://secret.example'));
    loadPage(privateId, 'https://secret.example/', title: 'Secret');
    h.engine.emit(privateId, 'favicon', {'bytes': null, 'url': 'https://secret.example/'});
    await pump(10);
    page = await h.container.read(historyRepositoryProvider).page();
    expect(page.map((e) => e.url), isNot(contains('https://secret.example/')));
  });

  test('closing the last private tab ends the private session', () async {
    await setUpHarness();
    final privateId = tabs.newTab(url: 'https://private.example/', incognito: true);
    await pump();
    expect(h.container.read(tabsProvider).privateMode, isTrue);
    await tabs.close(privateId);
    await pump();
    final state = h.container.read(tabsProvider);
    expect(h.engine.endIncognitoCalls, 1);
    expect(state.private, isEmpty);
    expect(state.privateMode, isFalse);
    expect(state.recentlyClosed.where((c) => c.url.contains('private')), isEmpty);
    expect(h.engine.lastClear, isNull, reason: 'regular cookies are never touched');
  });

  test('session: regular tabs are restored after restart, private tabs are not', () async {
    final dir = await Directory.systemTemp.createTemp('saif_session');
    await setUpHarness(dir: dir);
    await tabs.openInput('keep.example');
    loadPage(activeId(), 'https://keep.example/', title: 'Keep');
    tabs.newTab(url: 'https://second.example/');
    await pump();
    tabs.newTab(url: 'https://private.example/', incognito: true);
    await pump();
    await tabs.saveNow();
    h.dispose();

    await setUpHarness(dir: dir);
    final state = h.container.read(tabsProvider);
    expect(state.regular.map((t) => t.url), ['https://keep.example/', 'https://second.example/']);
    expect(state.private, isEmpty);
    expect(state.privateMode, isFalse);
    expect(state.active!.url, 'https://second.example/');
    expect(h.engine.created, [state.active!.id], reason: 'only the visible tab loads at startup');
    await dir.delete(recursive: true);
  });

  test('restore can be turned off in settings', () async {
    final dir = await Directory.systemTemp.createTemp('saif_session');
    await setUpHarness(dir: dir);
    await tabs.openInput('keep.example');
    await h.container.read(settingsProvider.notifier).update((s) => s.copyWith(restoreTabs: false));
    await tabs.saveNow();
    h.dispose();
    await setUpHarness(dir: dir);
    expect(h.container.read(tabsProvider).regular.single.showNtp, isTrue);
    await dir.delete(recursive: true);
  });

  test('main-frame errors show an error page and retry reloads', () async {
    await setUpHarness();
    await tabs.openInput('down.example');
    final id = activeId();
    h.engine.emit(id, 'error', {
      'url': 'https://down.example/',
      'code': -2,
      'description': 'net::ERR_INTERNET_DISCONNECTED',
      'online': false,
    });
    var tab = h.container.read(tabsProvider).active!;
    expect(tab.error!.kind, PageErrorKind.offline);
    expect(tab.isLoading, isFalse);
    await tabs.retry(id);
    tab = h.container.read(tabsProvider).active!;
    expect(tab.error, isNull);
    expect(h.engine.loaded[id], 'https://down.example/');
  });

  test('HTTP 404 is not treated as an error page; proxy failures are', () async {
    await setUpHarness();
    await tabs.openInput('x.example');
    final id = activeId();
    h.engine.emit(id, 'httpError', {'url': 'https://x.example/', 'status': 404});
    expect(h.container.read(tabsProvider).active!.error, isNull);
    expect(h.container.read(tabsProvider).active!.httpStatus, 404);
    h.engine.emit(id, 'httpError', {'url': 'http://x.example/', 'status': 502, 'proxyError': 'authFailed'});
    expect(h.container.read(tabsProvider).active!.error!.kind, PageErrorKind.proxy);
  });

  test('SSL errors and insecure navigation interstitial', () async {
    await setUpHarness();
    await tabs.openInput('bad-cert.example');
    final id = activeId();
    h.engine.emit(id, 'sslError', {'url': 'https://bad-cert.example/', 'primaryError': 3});
    expect(h.container.read(tabsProvider).active!.error!.kind, PageErrorKind.ssl);

    h.engine.emit(id, 'insecureNavigation', {'url': 'http://plain.example/'});
    expect(h.container.read(tabsProvider).active!.error!.kind, PageErrorKind.insecure);
    await tabs.proceedInsecure(id);
    expect(h.engine.allowedHttpHosts, contains('plain.example'));
    expect(h.engine.loaded[id], 'http://plain.example/');
  });

  test('popups open as child tabs and back closes them', () async {
    await setUpHarness();
    await tabs.openInput('parent.example');
    final parent = activeId();
    h.engine.emit('popup-1', 'newTab', {'parentId': parent, 'incognito': false});
    await pump();
    expect(activeId(), 'popup-1');
    expect(await tabs.handleBack(), isTrue);
    await pump();
    expect(activeId(), parent);
    expect(h.engine.disposed, contains('popup-1'));
  });

  test('renderer crash shows an error and reload re-embeds a fresh WebView', () async {
    await setUpHarness();
    await tabs.openInput('crash.example');
    final id = activeId();
    h.engine.emit(id, 'rendererGone', {'crashed': true, 'url': 'https://crash.example/'});
    var tab = h.container.read(tabsProvider).active!;
    expect(tab.error!.kind, PageErrorKind.crashed);
    final generation = tab.surfaceGeneration;
    await tabs.retry(id);
    tab = h.container.read(tabsProvider).active!;
    expect(tab.surfaceGeneration, generation + 1);
    expect(tab.error, isNull);
  });

  test('desktop mode and text zoom are per tab', () async {
    await setUpHarness();
    await tabs.openInput('d.example');
    final id = activeId();
    await tabs.setDesktopMode(id, true);
    await tabs.setTextZoom(id, 150);
    expect(h.engine.calls, containsAll(['desktop:$id:true', 'zoom:$id:150']));
    expect(h.container.read(tabsProvider).active!.desktopMode, isTrue);
  });

  test('home opens the new tab page or the configured homepage', () async {
    await setUpHarness();
    await tabs.openInput('a.example');
    await tabs.goHome();
    expect(h.container.read(tabsProvider).active!.showNtp, isTrue);
    await h.container.read(settingsProvider.notifier).update((s) => s.copyWith(homepage: 'https://home.example/'));
    await tabs.goHome();
    expect(h.engine.loaded[activeId()], 'https://home.example/');
  });

  test('private downloads are forgotten when the private session ends', () async {
    await setUpHarness();
    final downloads = h.container.read(downloadsProvider.notifier);
    await downloads.ensureLoaded();
    final privateId = tabs.newTab(url: 'https://p.example/', incognito: true);
    await pump();
    await downloads.start(
      DownloadRequest(url: 'data:text/plain;base64,aGVsbG8=', fileName: 'note.txt', incognito: true, tabId: privateId),
    );
    expect(h.container.read(downloadsProvider), hasLength(1));
    await tabs.close(privateId);
    await pump();
    expect(h.container.read(downloadsProvider), isEmpty);
  });

  test('new tab URL constant is internal', () {
    expect(UrlResolver.isWebUrl(UrlResolver.newTabUrl), isFalse);
  });
}
