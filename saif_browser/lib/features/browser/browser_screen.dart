import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/url_resolver.dart';
import '../../engine/webview_surface.dart';
import '../bookmarks/bookmark_editor.dart';
import '../downloads/downloads_screen.dart';
import '../proxy/proxy_screen.dart';
import '../settings/browser_settings.dart';
import '../settings/settings_controller.dart';
import '../tabs/browser_tab.dart';
import '../tabs/tab_overview_screen.dart';
import '../tabs/tabs_controller.dart';
import 'browser_interactions.dart';
import 'browser_menu.dart';
import 'search_screen.dart';
import 'site_info_sheet.dart';
import 'widgets/address_bar.dart';
import 'widgets/bottom_toolbar.dart';
import 'widgets/chrome_colors.dart';
import 'widgets/find_bar.dart';
import 'widgets/new_tab_page.dart';
import 'widgets/page_error_view.dart';
import 'widgets/page_progress_bar.dart';

/// Whether [url] is bookmarked; refreshed when bookmarks change.
final isBookmarkedProvider = FutureProvider.family<bool, String>((ref, url) async {
  ref.watch(dataRevisionProvider);
  if (!UrlResolver.isWebUrl(url)) return false;
  return await ref.read(bookmarkRepositoryProvider).findByUrl(url) != null;
});

class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  bool _finding = false;

  TabsController get _tabs => ref.read(tabsProvider.notifier);

  Future<void> _openSearch(BrowserTab tab) async {
    final result = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 140),
        pageBuilder: (_, _, _) => SearchScreen(initialText: tab.showNtp ? '' : tab.url, private: tab.incognito),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
    if (result != null && result.isNotEmpty) await _tabs.openInput(result, tabId: tab.id);
  }

  Future<void> _openTabs(BrowserTab tab) async {
    await _tabs.captureThumbnail(tab.id);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TabOverviewScreen()));
  }

  Future<void> _openUrlFromScreen(Future<String?> Function() open) async {
    final url = await open();
    if (url != null && mounted) await _tabs.navigate(url);
  }

  Future<void> _toggleBookmark(BrowserTab tab, bool bookmarked) async {
    if (bookmarked) {
      final bookmark = await ref.read(bookmarkRepositoryProvider).findByUrl(tab.url);
      if (bookmark != null && mounted) await showBookmarkEditor(context, ref, bookmark: bookmark);
      return;
    }
    await ref.read(bookmarkRepositoryProvider).add(title: tab.displayTitle, url: tab.url);
    ref.read(dataRevisionProvider.notifier).bump();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bookmarked'),
        action: SnackBarAction(
          label: 'Edit',
          onPressed: () async {
            final bookmark = await ref.read(bookmarkRepositoryProvider).findByUrl(tab.url);
            if (bookmark != null && mounted) await showBookmarkEditor(context, ref, bookmark: bookmark);
          },
        ),
      ),
    );
  }

  Future<void> _onBack() async {
    if (ref.read(fullscreenProvider)) {
      await ref.read(browserEngineProvider).exitFullscreen();
      ref.read(fullscreenProvider.notifier).set(false);
      return;
    }
    if (_finding) {
      setState(() => _finding = false);
      return;
    }
    final handled = await _tabs.handleBack();
    if (!handled) await ref.read(systemBridgeProvider).moveToBack();
  }

  void _openProxy() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProxyScreen()));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tabsProvider);
    final tab = state.active;
    final settings = ref.watch(settingsProvider);
    if (tab == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final bookmarked = ref.watch(isBookmarkedProvider(tab.url)).value ?? false;
    final colors = ChromeColors.of(context, private: tab.incognito);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomAddress = settings.toolbarPosition == ToolbarPosition.bottom;

    final Widget topControls = _finding
        ? FindBar(tabId: tab.id, private: tab.incognito, onClose: () => setState(() => _finding = false))
        : AddressBar(
            tab: tab,
            tabCount: state.visibleTabs.length,
            onOpenSearch: () => _openSearch(tab),
            onOpenTabs: () => _openTabs(tab),
            onOpenMenu: () => showBrowserMenu(
              context,
              ref,
              tab: tab,
              bookmarked: bookmarked,
              onFind: () => setState(() => _finding = true),
              onToggleBookmark: () => _toggleBookmark(tab, bookmarked),
              onOpenUrl: _openUrlFromScreen,
            ),
            onSiteInfo: () => showSiteInfoSheet(context, ref, tab),
            onOpenProxy: _openProxy,
          );
    final progress = PageProgressBar(
      progress: tab.progress,
      visible: tab.isLoading && !tab.showNtp,
      color: tab.incognito ? colors.accent : const Color(0xFF111111),
    );
    final accentProgress = PageProgressBar(
      progress: tab.progress,
      visible: tab.isLoading && !tab.showNtp,
      color: colors.accent,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: BrowserInteractionHost(
        child: Scaffold(
          backgroundColor: colors.bar,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              if (!bottomAddress) ...[
                ColoredBox(
                  color: colors.bar,
                  child: SafeArea(bottom: false, child: topControls),
                ),
                Stack(
                  children: [
                    Divider(height: 1, color: colors.border),
                    progress,
                  ],
                ),
              ] else
                ColoredBox(
                  color: colors.bar,
                  child: SafeArea(bottom: false, child: const SizedBox.shrink()),
                ),
              Expanded(
                child: _PageArea(tab: tab, onSearch: () => _openSearch(tab), onOpenProxy: _openProxy),
              ),
              if (bottomAddress) ...[
                accentProgress,
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colors.border, width: 0.8)),
                  ),
                  child: SafeArea(top: false, bottom: keyboardOpen, child: topControls),
                ),
              ],
              if (!keyboardOpen)
                BottomToolbar(
                  tab: tab,
                  bookmarked: bookmarked,
                  onToggleBookmark: () => _toggleBookmark(tab, bookmarked),
                  onOpenDownloads: () =>
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DownloadsScreen())),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageArea extends ConsumerWidget {
  const _PageArea({required this.tab, required this.onSearch, required this.onOpenProxy});

  final BrowserTab tab;
  final VoidCallback onSearch;
  final VoidCallback onOpenProxy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.read(tabsProvider.notifier);
    final error = tab.error;
    final showWebView = tab.nativeCreated && !tab.showNtp;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
        if (showWebView) WebViewSurface(key: ValueKey('${tab.id}#${tab.surfaceGeneration}'), tabId: tab.id),
        if (tab.showNtp)
          NewTabPage(
            key: ValueKey('ntp-${tab.incognito}'),
            private: tab.incognito,
            onSearch: onSearch,
            onOpen: (url) => tabs.navigate(url, tabId: tab.id),
            isolationSupported: ref.read(engineInfoProvider).multiProfile,
          ),
        if (error != null && !tab.showNtp)
          PageErrorView(
            error: error,
            canGoBack: tab.canGoBack,
            onRetry: () => tabs.retry(tab.id),
            onBack: () async {
              final handled = await tabs.handleBack();
              if (!handled) await tabs.close(tab.id);
            },
            onProceedInsecure: () => tabs.proceedInsecure(tab.id),
            onOpenProxySettings: onOpenProxy,
          ),
      ],
    );
  }
}
