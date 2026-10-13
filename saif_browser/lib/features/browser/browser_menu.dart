import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/dialogs.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../downloads/downloads_screen.dart';
import '../history/history_screen.dart';
import '../passwords/passwords_screen.dart';
import '../passwords/site_passwords_sheet.dart';
import '../proxy/proxy_screen.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_screen.dart';
import '../tabs/browser_tab.dart';
import '../tabs/tabs_controller.dart';
import 'site_info_sheet.dart';

Future<void> showBrowserMenu(
  BuildContext context,
  WidgetRef ref, {
  required BrowserTab tab,
  required bool bookmarked,
  required VoidCallback onFind,
  required VoidCallback onToggleBookmark,
  required Future<void> Function(Future<String?> Function() open) onOpenUrl,
}) {
  final tabs = ref.read(tabsProvider.notifier);
  final isPage = !tab.showNtp && UrlResolver.isWebUrl(tab.url);
  final navigator = Navigator.of(context);

  void push(Widget screen) => navigator.push(MaterialPageRoute<void>(builder: (_) => screen));

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      void close() => Navigator.pop(sheetContext);
      final palette = sheetContext.palette;
      Widget iconAction(IconData icon, String label, VoidCallback? onTap) => Expanded(
        child: IconButton(
          tooltip: label,
          onPressed: onTap == null
              ? null
              : () {
                  close();
                  onTap();
                },
          icon: Icon(icon),
          iconSize: 25,
        ),
      );
      Widget item(IconData icon, String label, VoidCallback onTap, {Widget? trailing, bool keepOpen = false}) =>
          ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: trailing,
            visualDensity: VisualDensity.compact,
            onTap: () {
              if (!keepOpen) close();
              onTap();
            },
          );
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    iconAction(Icons.arrow_forward_rounded, 'Forward', tab.canGoForward ? tabs.goForward : null),
                    iconAction(
                      bookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                      bookmarked ? 'Edit bookmark' : 'Bookmark',
                      isPage && !tab.incognito ? onToggleBookmark : null,
                    ),
                    iconAction(Icons.download_rounded, 'Downloads', () => push(const DownloadsScreen())),
                    iconAction(
                      Icons.info_outline_rounded,
                      'Page info',
                      isPage ? () => showSiteInfoSheet(context, ref, tab) : null,
                    ),
                    iconAction(
                      tab.isLoading ? Icons.close_rounded : Icons.refresh_rounded,
                      tab.isLoading ? 'Stop' : 'Reload',
                      tab.showNtp ? null : (tab.isLoading ? tabs.stop : tabs.reload),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            item(Icons.add_box_outlined, 'New tab', () => tabs.newTab(incognito: false)),
            item(Icons.visibility_off_outlined, 'New private tab', () => tabs.newTab(incognito: true)),
            if (tab.incognito)
              item(Icons.cancel_outlined, 'Close all private tabs', () => tabs.closeAll(private: true)),
            const Divider(indent: 20, endIndent: 20),
            item(Icons.star_outline_rounded, 'Bookmarks', () {
              onOpenUrl(() => navigator.push<String>(MaterialPageRoute(builder: (_) => const BookmarksScreen())));
            }),
            item(Icons.history_rounded, 'History', () {
              onOpenUrl(() => navigator.push<String>(MaterialPageRoute(builder: (_) => const HistoryScreen())));
            }),
            item(Icons.download_outlined, 'Downloads', () => push(const DownloadsScreen())),
            item(Icons.restore_page_outlined, 'Recently closed tabs', () => _showRecentlyClosed(context, ref)),
            const Divider(indent: 20, endIndent: 20),
            if (isPage) ...[
              item(Icons.share_outlined, 'Share…', () {
                ref.read(systemBridgeProvider).shareText(tab.url, subject: tab.title);
              }),
              item(Icons.find_in_page_outlined, 'Find in page', onFind),
              item(
                Icons.desktop_windows_outlined,
                'Desktop site',
                () => tabs.setDesktopMode(tab.id, !tab.desktopMode),
                trailing: Checkbox(
                  value: tab.desktopMode,
                  onChanged: (_) {
                    close();
                    tabs.setDesktopMode(tab.id, !tab.desktopMode);
                  },
                ),
              ),
              item(Icons.text_fields_rounded, 'Text size', () => _showZoom(context, ref, tab)),
              if (!tab.incognito)
                item(Icons.key_outlined, 'Passwords for this site', () => showSitePasswordsSheet(context, ref, tab)),
              const Divider(indent: 20, endIndent: 20),
            ],
            item(Icons.password_rounded, 'Password manager', () => push(const PasswordsScreen())),
            item(Icons.vpn_lock_outlined, 'Proxy', () => push(const ProxyScreen())),
            item(Icons.settings_outlined, 'Settings', () => push(const SettingsScreen())),
          ],
        ),
      );
    },
  );
}

Future<void> _showRecentlyClosed(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final closed = ref.watch(tabsProvider.select((s) => s.recentlyClosed));
        if (closed.isEmpty) {
          return const SizedBox(height: 200, child: Center(child: Text('No recently closed tabs')));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Recently closed', style: TextStyle(fontWeight: FontWeight.w700)),
              trailing: TextButton(
                onPressed: () => ref.read(tabsProvider.notifier).clearRecentlyClosed(),
                child: const Text('Clear'),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in closed)
                    ListTile(
                      leading: const Icon(Icons.tab_outlined),
                      title: Text(
                        c.title.isEmpty ? UrlResolver.displayText(c.url) : c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(UrlResolver.displayText(c.url), maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(tabsProvider.notifier).reopenClosed(c);
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> _showZoom(BuildContext context, WidgetRef ref, BrowserTab tab) {
  final fallback = ref.read(settingsProvider).textZoom;
  var value = (tab.textZoom ?? fallback).toDouble();
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Text size ${value.round()}%', style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Smaller',
                    onPressed: value <= 50
                        ? null
                        : () {
                            setState(() => value = (value - 10).clamp(50, 300));
                            ref.read(tabsProvider.notifier).setTextZoom(tab.id, value.round());
                          },
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Expanded(
                    child: Slider(
                      value: value,
                      min: 50,
                      max: 300,
                      divisions: 25,
                      label: '${value.round()}%',
                      onChanged: (v) => setState(() => value = v),
                      onChangeEnd: (v) => ref.read(tabsProvider.notifier).setTextZoom(tab.id, v.round()),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Larger',
                    onPressed: value >= 300
                        ? null
                        : () {
                            setState(() => value = (value + 10).clamp(50, 300));
                            ref.read(tabsProvider.notifier).setTextZoom(tab.id, value.round());
                          },
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ref.read(tabsProvider.notifier).setTextZoom(tab.id, null);
                  Navigator.pop(context);
                  showMessage(context, 'Text size reset to default');
                },
                child: const Text('Reset to default'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
