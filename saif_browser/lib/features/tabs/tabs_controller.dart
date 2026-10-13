import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/url_resolver.dart';
import '../../engine/browser_engine.dart';
import '../../engine/engine_event.dart';
import '../downloads/downloads_controller.dart';
import '../proxy/proxy_controller.dart';
import '../proxy/proxy_models.dart';
import '../settings/settings_controller.dart';
import 'browser_tab.dart';
import 'page_error.dart';
import 'session_store.dart';

/// Find-in-page result for the active tab.
class FindState {
  const FindState({this.active = 0, this.total = 0});

  final int active;
  final int total;
}

final findStateProvider = NotifierProvider<_ValueNotifier<FindState>, FindState>(
  () => _ValueNotifier(const FindState()),
);

/// True while a page shows a full-screen video.
final fullscreenProvider = NotifierProvider<_ValueNotifier<bool>, bool>(() => _ValueNotifier(false));

class _ValueNotifier<T> extends Notifier<T> {
  _ValueNotifier(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore(ref.watch(appSupportDirProvider)));

final tabsProvider = NotifierProvider<TabsController, TabsState>(TabsController.new);

/// Owns the list of tabs and keeps it in sync with the native WebViews.
class TabsController extends Notifier<TabsState> {
  /// WebViews kept alive besides the visible one; older tabs are suspended.
  static const maxLiveBackgroundTabs = 4;
  static const maxRecentlyClosed = 25;

  StreamSubscription<EngineEvent>? _events;
  Timer? _saveTimer;
  final Set<String> _live = {};
  int _clock = 0;

  BrowserEngine get _engine => ref.read(browserEngineProvider);

  @override
  TabsState build() {
    _events = _engine.events.listen(_onEvent);
    listenSelf((_, next) => _syncSurface(next));
    ref.onDispose(() {
      _events?.cancel();
      _saveTimer?.cancel();
    });
    return const TabsState();
  }

  int _tick() => ++_clock;

  String? _shownKey;

  /// Tells the native browser surface which WebView to display. Switching
  /// tabs only swaps the native view; Flutter keeps one platform view.
  void _syncSurface(TabsState next) {
    final tab = next.active;
    final visible = tab != null && tab.nativeCreated && !tab.showNtp ? tab : null;
    final key = visible == null ? null : '${visible.id}#${visible.surfaceGeneration}';
    if (key == _shownKey) return;
    _shownKey = key;
    unawaited(_engine.showTab(visible?.id));
  }

  // ---------------------------------------------------------------- session

  /// Restores saved regular tabs (if enabled) and makes sure one tab exists.
  Future<void> restore({String? initialUrl}) async {
    final settings = ref.read(settingsProvider);
    final saved = settings.restoreTabs ? await ref.read(sessionStoreProvider).load() : null;
    final tabs = <BrowserTab>[];
    for (final t in saved?.tabs ?? const <SavedTab>[]) {
      final isPage = UrlResolver.isWebUrl(t.url);
      tabs.add(
        BrowserTab(
          id: newId(),
          incognito: false,
          url: isPage ? t.url : UrlResolver.newTabUrl,
          title: t.title,
          showNtp: !isPage,
          desktopMode: t.desktopMode,
          hasNtpEntry: true,
        ),
      );
    }
    state = state.copyWith(
      regular: tabs,
      activeRegularId: tabs.isEmpty ? null : tabs[saved!.activeIndex].id,
      recentlyClosed: saved?.recentlyClosed ?? const [],
    );
    if (initialUrl != null) {
      newTab(url: initialUrl);
    } else if (tabs.isEmpty) {
      newTab();
    } else {
      await _activate(state.activeRegularId!);
    }
  }

  void _scheduleSave() {
    if (!ref.mounted) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), saveNow);
  }

  Future<void> saveNow() async {
    _saveTimer?.cancel();
    if (!ref.mounted) return;
    if (!ref.read(settingsProvider).restoreTabs) {
      await ref.read(sessionStoreProvider).clear();
      return;
    }
    await ref.read(sessionStoreProvider).save(state);
  }

  // ---------------------------------------------------------------- helpers

  void _update(String id, BrowserTab Function(BrowserTab tab) change, {bool persist = false}) {
    if (!ref.mounted) return;
    var touchedRegular = false;
    List<BrowserTab> apply(List<BrowserTab> list) {
      var changed = false;
      final result = [
        for (final t in list)
          if (t.id == id)
            (() {
              changed = true;
              if (!t.incognito) touchedRegular = true;
              return change(t);
            })()
          else
            t,
      ];
      return changed ? result : list;
    }

    state = state.copyWith(regular: apply(state.regular), private: apply(state.private));
    if (persist && touchedRegular) _scheduleSave();
  }

  BrowserTab? tab(String id) => state.byId(id);

  Future<void> _ensureNative(BrowserTab tab) async {
    if (tab.nativeCreated) return;
    await _engine.createTab(
      tab.id,
      incognito: tab.incognito,
      url: tab.showNtp ? null : tab.url,
      desktopMode: tab.desktopMode,
    );
    if (tab.textZoom != null) await _engine.setTextZoom(tab.id, tab.textZoom);
    _update(tab.id, (t) => t.copyWith(nativeCreated: true));
  }

  Future<void> _activate(String id) async {
    final target = state.byId(id);
    if (target == null) return;
    state = target.incognito
        ? state.copyWith(activePrivateId: id, privateMode: true)
        : state.copyWith(activeRegularId: id, privateMode: false);
    _update(id, (t) => t.copyWith(lastActive: _tick()));
    if (!target.showNtp) {
      await _ensureNative(target);
      _live.add(id);
    }
    await _enforceBudget();
    _scheduleSave();
  }

  /// Suspends least-recently-used background WebViews to bound memory use.
  Future<void> _enforceBudget() async {
    final activeId = state.activeId;
    final candidates = state.all.where((t) => t.id != activeId && _live.contains(t.id)).toList()
      ..sort((a, b) => b.lastActive.compareTo(a.lastActive));
    for (final t in candidates.skip(maxLiveBackgroundTabs)) {
      _live.remove(t.id);
      await _engine.suspendTab(t.id);
    }
  }

  // ---------------------------------------------------------------- tab ops

  /// Opens a tab. Without [url] it shows the new tab page.
  String newTab({String? url, bool? incognito, bool activate = true, String? afterId}) {
    final private = incognito ?? state.privateMode;
    final isPage = url != null && url != UrlResolver.newTabUrl;
    final tab = BrowserTab(
      id: newId(),
      incognito: private,
      url: isPage ? url : UrlResolver.newTabUrl,
      showNtp: !isPage,
      desktopMode: ref.read(settingsProvider).desktopModeDefault,
      hasNtpEntry: !isPage,
      isLoading: isPage,
    );
    final list = private ? state.private : state.regular;
    final index = afterId == null ? list.length : list.indexWhere((t) => t.id == afterId) + 1;
    final updated = [...list]..insert(index.clamp(0, list.length), tab);
    state = private ? state.copyWith(private: updated) : state.copyWith(regular: updated);
    if (activate) {
      unawaited(_activate(tab.id));
    } else if (isPage) {
      unawaited(
        _ensureNative(tab).then((_) {
          _live.add(tab.id);
          return _enforceBudget();
        }),
      );
    }
    _scheduleSave();
    return tab.id;
  }

  Future<void> switchTo(String id) => _activate(id);

  /// Navigates [tabId] (default: active tab) to typed input or a URL.
  Future<void> openInput(String input, {String? tabId}) async {
    final engine = ref.read(settingsProvider).engine;
    final typedUrl = UrlResolver.toUrl(input);
    if (typedUrl != null && typedUrl.toLowerCase().startsWith('http://')) {
      // Typing an http:// address is an explicit choice to allow it.
      final host = UrlResolver.hostOf(typedUrl);
      if (host != null) await _engine.allowHttpHost(host);
    }
    await navigate(typedUrl ?? engine.searchUrl(input), tabId: tabId);
  }

  Future<void> navigate(String url, {String? tabId}) async {
    final id = tabId ?? state.activeId;
    if (id == null) {
      newTab(url: url);
      return;
    }
    final tab = state.byId(id);
    if (tab == null) return;
    if (url == UrlResolver.newTabUrl) {
      showNewTabPage(id);
      return;
    }
    _update(
      id,
      (t) =>
          t.copyWith(url: url, showNtp: false, isLoading: true, progress: 0, clearError: true, clearHttpStatus: true),
      persist: true,
    );
    if (!tab.nativeCreated) {
      await _ensureNative(state.byId(id)!);
      _live.add(id);
      await _enforceBudget();
    } else {
      await _engine.loadUrl(id, url);
    }
  }

  void showNewTabPage(String id) {
    final tab = state.byId(id);
    if (tab == null) return;
    if (tab.nativeCreated && tab.isLoading) unawaited(_engine.stop(id));
    _update(id, (t) => t.copyWith(showNtp: true, isLoading: false, clearError: true), persist: true);
  }

  Future<void> goHome() async {
    final id = state.activeId;
    if (id == null) return;
    final home = ref.read(settingsProvider).homepage.trim();
    if (home.isEmpty) {
      showNewTabPage(id);
    } else {
      await openInput(home, tabId: id);
    }
  }

  Future<void> close(String id) async {
    final tab = state.byId(id);
    if (tab == null) return;
    final list = tab.incognito ? state.private : state.regular;
    final index = list.indexWhere((t) => t.id == id);
    final remaining = [...list]..removeAt(index);
    _live.remove(id);
    if (tab.nativeCreated) await _engine.disposeTab(id);

    var closed = state.recentlyClosed;
    if (!tab.incognito && !tab.showNtp && UrlResolver.isWebUrl(tab.url)) {
      closed = [ClosedTab(url: tab.url, title: tab.title, index: index), ...closed].take(maxRecentlyClosed).toList();
    }

    final wasActive =
        state.activeId == id || (tab.incognito ? state.activePrivateId == id : state.activeRegularId == id);
    String? nextId;
    if (wasActive && remaining.isNotEmpty) {
      final parent = tab.parentId == null ? null : remaining.where((t) => t.id == tab.parentId).firstOrNull;
      nextId = parent?.id ?? remaining[(index - 1).clamp(0, remaining.length - 1)].id;
    }

    if (tab.incognito) {
      state = state.copyWith(
        private: remaining,
        activePrivateId: nextId,
        clearActivePrivate: wasActive && nextId == null,
        recentlyClosed: closed,
      );
      if (remaining.isEmpty) {
        await endPrivateSession();
        return;
      }
    } else {
      state = state.copyWith(
        regular: remaining,
        activeRegularId: nextId,
        clearActiveRegular: wasActive && nextId == null,
        recentlyClosed: closed,
      );
      if (remaining.isEmpty) {
        newTab(incognito: false, activate: !state.privateMode);
        _scheduleSave();
        return;
      }
    }
    if (nextId != null && (tab.incognito == state.privateMode)) await _activate(nextId);
    _scheduleSave();
  }

  Future<void> closeAll({required bool private}) async {
    final ids = (private ? state.private : state.regular).map((t) => t.id).toList();
    for (final id in ids) {
      final tab = state.byId(id);
      if (tab != null && tab.nativeCreated) await _engine.disposeTab(id);
      _live.remove(id);
    }
    if (private) {
      state = state.copyWith(private: const [], clearActivePrivate: true);
      await endPrivateSession();
    } else {
      final closed = [
        for (final t in state.regular)
          if (UrlResolver.isWebUrl(t.url) && !t.showNtp) ClosedTab(url: t.url, title: t.title, index: 0),
        ...state.recentlyClosed,
      ].take(maxRecentlyClosed).toList();
      state = state.copyWith(regular: const [], clearActiveRegular: true, recentlyClosed: closed);
      newTab(incognito: false, activate: !state.privateMode);
    }
    _scheduleSave();
  }

  /// Ends private browsing: destroys private WebViews and deletes their profile.
  Future<bool> endPrivateSession() async {
    for (final t in state.private) {
      _live.remove(t.id);
    }
    state = state.copyWith(private: const [], clearActivePrivate: true, privateMode: false);
    final isolated = await _engine.endIncognitoSession();
    if (!ref.mounted) return isolated;
    await ref.read(downloadsProvider.notifier).forgetIncognito();
    if (!ref.mounted) return isolated;
    if (state.regular.isEmpty) {
      newTab(incognito: false);
    } else if (state.activeRegularId != null) {
      await _activate(state.activeRegularId!);
    }
    return isolated;
  }

  Future<void> setPrivateMode(bool private) async {
    if (private == state.privateMode) return;
    if (private && state.private.isEmpty) {
      newTab(incognito: true);
      return;
    }
    final id = private ? state.activePrivateId : state.activeRegularId;
    if (id != null) {
      await _activate(id);
    } else {
      state = state.copyWith(privateMode: private);
    }
  }

  String? duplicate(String id) {
    final tab = state.byId(id);
    if (tab == null) return null;
    return newTab(url: tab.showNtp ? null : tab.url, incognito: tab.incognito, afterId: id);
  }

  void reorder(int oldIndex, int newIndex, {required bool private}) {
    final list = [...(private ? state.private : state.regular)];
    if (oldIndex < 0 || oldIndex >= list.length) return;
    final tab = list.removeAt(oldIndex);
    list.insert(newIndex.clamp(0, list.length), tab);
    state = private ? state.copyWith(private: list) : state.copyWith(regular: list);
    _scheduleSave();
  }

  Future<void> reopenClosed([ClosedTab? which]) async {
    if (state.recentlyClosed.isEmpty) return;
    final entry = which ?? state.recentlyClosed.first;
    state = state.copyWith(recentlyClosed: state.recentlyClosed.where((c) => c != entry).toList());
    if (state.privateMode) state = state.copyWith(privateMode: false);
    newTab(url: entry.url, incognito: false);
  }

  void clearRecentlyClosed() {
    state = state.copyWith(recentlyClosed: const []);
    _scheduleSave();
  }

  // ---------------------------------------------------------------- page ops

  Future<void> goBack() async {
    final tab = state.active;
    if (tab != null && tab.nativeCreated) await _engine.goBack(tab.id);
  }

  Future<void> goForward() async {
    final tab = state.active;
    if (tab == null) return;
    if (tab.showNtp && tab.nativeCreated && UrlResolver.isWebUrl(tab.url)) {
      _update(tab.id, (t) => t.copyWith(showNtp: false));
      return;
    }
    if (tab.nativeCreated) await _engine.goForward(tab.id);
  }

  Future<void> reload() async {
    final tab = state.active;
    if (tab == null || tab.showNtp) return;
    final error = tab.error;
    if (error != null) {
      await retry(tab.id);
      return;
    }
    if (!tab.nativeCreated) {
      await navigate(tab.url, tabId: tab.id);
    } else {
      await _engine.reload(tab.id);
    }
  }

  Future<void> stop() async {
    final tab = state.active;
    if (tab == null || !tab.nativeCreated) return;
    await _engine.stop(tab.id);
    _update(tab.id, (t) => t.copyWith(isLoading: false));
  }

  /// Retries the navigation that produced the current error page.
  Future<void> retry(String id) async {
    final tab = state.byId(id);
    final error = tab?.error;
    if (tab == null) return;
    final url = error?.url ?? tab.url;
    if (error?.kind == PageErrorKind.crashed) {
      _update(id, (t) => t.copyWith(clearError: true, surfaceGeneration: t.surfaceGeneration + 1));
      await _engine.loadUrl(id, url);
      return;
    }
    if (error?.kind == PageErrorKind.proxy) {
      final proxy = ref.read(proxyControllerProvider);
      if (proxy.state == ProxyConnectionState.failed) {
        await ref.read(proxyControllerProvider.notifier).retry();
      }
    }
    await navigate(url, tabId: id);
  }

  /// Continues to an http:// page after the HTTPS-first warning.
  Future<void> proceedInsecure(String id) async {
    final error = state.byId(id)?.error;
    if (error == null || error.kind != PageErrorKind.insecure) return;
    final host = UrlResolver.hostOf(error.url);
    if (host != null) await _engine.allowHttpHost(host);
    await navigate(error.url, tabId: id);
  }

  Future<void> setDesktopMode(String id, bool enabled) async {
    final tab = state.byId(id);
    if (tab == null) return;
    _update(id, (t) => t.copyWith(desktopMode: enabled), persist: true);
    if (tab.nativeCreated) await _engine.setDesktopMode(id, enabled);
  }

  Future<void> setTextZoom(String id, int? percent) async {
    final tab = state.byId(id);
    if (tab == null) return;
    _update(id, (t) => percent == null ? t.copyWith(clearTextZoom: true) : t.copyWith(textZoom: percent));
    if (tab.nativeCreated) await _engine.setTextZoom(id, percent);
  }

  Future<Uint8List?> captureThumbnail(String id) async {
    final tab = state.byId(id);
    if (tab == null || !tab.nativeCreated || tab.showNtp) return null;
    final bytes = await _engine.captureThumbnail(id);
    if (bytes != null) _update(id, (t) => t.copyWith(thumbnail: bytes));
    return bytes;
  }

  /// Handles the system back gesture. Returns false when the app should go
  /// to the background.
  Future<bool> handleBack() async {
    final tab = state.active;
    if (tab == null) return false;
    if (tab.showNtp) {
      if (tab.nativeCreated && UrlResolver.isWebUrl(tab.url)) {
        _update(tab.id, (t) => t.copyWith(showNtp: false));
        return true;
      }
      if (tab.parentId != null) {
        await close(tab.id);
        return true;
      }
      return false;
    }
    if (tab.canGoBack) {
      if (tab.error != null) _update(tab.id, (t) => t.copyWith(clearError: true));
      await _engine.goBack(tab.id);
      return true;
    }
    if (tab.parentId != null && state.byId(tab.parentId!) != null) {
      await close(tab.id);
      return true;
    }
    if (tab.hasNtpEntry) {
      showNewTabPage(tab.id);
      return true;
    }
    return false;
  }

  // ---------------------------------------------------------------- events

  void _onEvent(EngineEvent e) {
    final tab = state.byId(e.tabId);
    switch (e.type) {
      case 'newTab':
        _onPopup(e);
        return;
      case 'fullscreen':
        ref.read(fullscreenProvider.notifier).set(e.flag('active'));
        return;
      case 'findResult':
        ref
            .read(findStateProvider.notifier)
            .set(FindState(active: e.integer('active') ?? 0, total: e.integer('total') ?? 0));
        return;
    }
    if (tab == null) return;
    switch (e.type) {
      case 'pageStarted':
        final url = e.str('url') ?? tab.url;
        final sameHost = UrlResolver.hostOf(url) == UrlResolver.hostOf(tab.url);
        _update(
          tab.id,
          (t) => t.copyWith(
            url: url,
            isLoading: true,
            progress: 0,
            showNtp: false,
            clearError: true,
            clearHttpStatus: true,
            clearFavicon: !sameHost,
            canGoBack: e.flag('canGoBack'),
            canGoForward: e.flag('canGoForward'),
          ),
          persist: true,
        );
      case 'progress':
        final value = (e.integer('value') ?? 0).clamp(0, 100) / 100;
        _update(tab.id, (t) => t.copyWith(progress: value, isLoading: value < 1 && t.isLoading));
      case 'pageFinished':
        final url = e.str('url') ?? tab.url;
        final title = e.str('title') ?? tab.title;
        _update(
          tab.id,
          (t) => t.copyWith(
            url: url,
            title: title == url ? t.title : title,
            isLoading: false,
            progress: 1,
            canGoBack: e.flag('canGoBack'),
            canGoForward: e.flag('canGoForward'),
          ),
          persist: true,
        );
        _recordVisit(tab, url, title);
      case 'urlChanged':
        final url = e.str('url') ?? tab.url;
        _update(
          tab.id,
          (t) => t.copyWith(url: url, canGoBack: e.flag('canGoBack'), canGoForward: e.flag('canGoForward')),
          persist: true,
        );
        if (!tab.isLoading && url != tab.url) _recordVisit(tab, url, tab.title);
      case 'title':
        final title = e.str('title') ?? '';
        if (title.isEmpty || title == e.str('url')) return;
        _update(tab.id, (t) => t.copyWith(title: title), persist: true);
        if (!tab.incognito && e.str('url') != null) {
          _background(ref.read(historyRepositoryProvider).updateTitle(e.str('url')!, title));
        }
      case 'favicon':
        final bytes = e.bytes('bytes');
        if (bytes == null) return;
        _update(tab.id, (t) => t.copyWith(favicon: bytes));
        final host = UrlResolver.hostOf(e.str('url'));
        if (!tab.incognito && host != null) _background(ref.read(faviconRepositoryProvider).save(host, bytes));
      case 'error':
        final error = PageError.fromWebView(
          url: e.str('url') ?? tab.url,
          code: e.integer('code') ?? PageError.errorUnknown,
          description: e.str('description'),
          online: e.data['online'] != false,
        );
        _setError(tab.id, _withProxyDetail(error));
      case 'httpError':
        final proxyKind = e.str('proxyError');
        if (proxyKind != null) {
          final kind = ProxyFailureKind.values.where((k) => k.name == proxyKind).firstOrNull;
          _setError(
            tab.id,
            _withProxyDetail(PageError(kind: PageErrorKind.proxy, url: e.str('url') ?? tab.url, detail: kind?.message)),
          );
        } else {
          _update(tab.id, (t) => t.copyWith(httpStatus: e.integer('status')));
        }
      case 'sslError':
        _setError(
          tab.id,
          PageError(kind: PageErrorKind.ssl, url: e.str('url') ?? tab.url, code: e.integer('primaryError')),
        );
      case 'insecureNavigation':
        final url = e.str('url') ?? tab.url;
        _setError(tab.id, PageError(kind: PageErrorKind.insecure, url: url));
      case 'rendererGone':
        final crashed = e.flag('crashed');
        _live.remove(tab.id);
        if (crashed) {
          _setError(tab.id, PageError(kind: PageErrorKind.crashed, url: e.str('url') ?? tab.url));
        } else if (state.activeId == tab.id) {
          // Killed to reclaim memory while visible: re-embed a fresh WebView.
          _update(tab.id, (t) => t.copyWith(surfaceGeneration: t.surfaceGeneration + 1));
          _live.add(tab.id);
        }
      case 'closeRequested':
        if (tab.parentId != null) unawaited(close(tab.id));
    }
  }

  PageError _withProxyDetail(PageError error) {
    if (error.kind != PageErrorKind.proxy) return error;
    final status = ref.read(proxyControllerProvider);
    final detail = status.failure?.toString() ?? error.detail;
    return PageError(
      kind: error.kind,
      url: error.url,
      code: error.code,
      description: error.description,
      detail: detail,
    );
  }

  void _setError(String id, PageError error) {
    _update(id, (t) => t.copyWith(error: error, url: error.url, isLoading: false, progress: 1, showNtp: false));
  }

  /// Leaves a blocked navigation (certificate error or insecure-site
  /// warning) and shows whatever the WebView still displays. The WebView
  /// never committed the blocked page, so this must not go back in history.
  Future<void> dismissError(String id) async {
    final tab = state.byId(id);
    if (tab == null) return;
    final current = tab.nativeCreated ? await _engine.currentUrl(id) : null;
    if (UrlResolver.isWebUrl(current)) {
      _update(id, (t) => t.copyWith(url: current, clearError: true, isLoading: false), persist: true);
      return;
    }
    if (tab.parentId != null) {
      await close(id);
    } else {
      showNewTabPage(id);
    }
  }

  void _recordVisit(BrowserTab tab, String url, String title) {
    if (tab.incognito || !UrlResolver.isWebUrl(url)) return;
    final current = state.byId(tab.id);
    if (current?.error != null) return;
    _background(
      ref.read(historyRepositoryProvider).recordVisit(url, title == url ? '' : title).then((_) {
        if (ref.mounted) ref.read(dataRevisionProvider.notifier).bump();
      }),
    );
  }

  /// History and favicon writes are best effort: a storage error must never
  /// break navigation.
  void _background(Future<void> work) {
    unawaited(work.catchError((Object _) {}));
  }

  void _onPopup(EngineEvent e) {
    final parentId = e.str('parentId');
    final parent = parentId == null ? null : state.byId(parentId);
    final incognito = e.flag('incognito');
    final tab = BrowserTab(
      id: e.tabId,
      incognito: incognito,
      url: '',
      showNtp: false,
      isLoading: true,
      nativeCreated: true,
      parentId: parent?.id,
    );
    final list = incognito ? state.private : state.regular;
    final index = parent == null ? list.length : list.indexWhere((t) => t.id == parent.id) + 1;
    final updated = [...list]..insert(index.clamp(0, list.length), tab);
    state = incognito ? state.copyWith(private: updated) : state.copyWith(regular: updated);
    unawaited(_activate(tab.id));
  }
}
