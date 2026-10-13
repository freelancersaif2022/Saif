import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/url_resolver.dart';
import '../../proxy/proxy_controller.dart';
import '../../proxy/proxy_models.dart';
import '../../settings/settings_controller.dart';
import '../../tabs/browser_tab.dart';
import '../../tabs/page_error.dart';
import '../../tabs/tabs_controller.dart';
import 'chrome_colors.dart';

/// Address pill with security state, proxy indicator, reload/stop, tab
/// counter and menu button.
class AddressBar extends ConsumerWidget {
  const AddressBar({
    super.key,
    required this.tab,
    required this.tabCount,
    required this.onOpenSearch,
    required this.onOpenTabs,
    required this.onOpenMenu,
    required this.onSiteInfo,
    required this.onOpenProxy,
  });

  final BrowserTab tab;
  final int tabCount;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenTabs;
  final VoidCallback onOpenMenu;
  final VoidCallback onSiteInfo;
  final VoidCallback onOpenProxy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ChromeColors.of(context, private: tab.incognito);
    final proxy = ref.watch(proxyControllerProvider);
    final engine = ref.watch(settingsProvider.select((s) => s.engine));
    final searchTerms = tab.showNtp ? null : UrlResolver.searchTermsFor(tab.url, engine);
    final text = tab.showNtp ? '' : (searchTerms ?? UrlResolver.displayText(tab.url));

    return Container(
      color: colors.bar,
      padding: const EdgeInsets.fromLTRB(10, 6, 2, 6),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: colors.pill,
              borderRadius: BorderRadius.circular(26),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onOpenSearch,
                child: SizedBox(
                  height: 46,
                  child: Row(
                    children: [
                      _SecurityButton(tab: tab, colors: colors, onTap: onSiteInfo),
                      Expanded(
                        child: Text(
                          text.isEmpty ? (tab.incognito ? 'Search privately or type URL' : 'Search or type URL') : text,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 15.5,
                            color: text.isEmpty ? colors.secondary : colors.foreground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (proxy.isActive || proxy.state != ProxyConnectionState.disconnected)
                        _ProxyChip(status: proxy, colors: colors, onTap: onOpenProxy),
                      if (!tab.showNtp)
                        IconButton(
                          tooltip: tab.isLoading ? 'Stop' : 'Reload',
                          onPressed: () {
                            final tabs = ref.read(tabsProvider.notifier);
                            tab.isLoading ? tabs.stop() : tabs.reload();
                          },
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: Icon(
                              tab.isLoading ? Icons.close_rounded : Icons.refresh_rounded,
                              key: ValueKey(tab.isLoading),
                              color: colors.foreground,
                              size: 22,
                            ),
                          ),
                        ),
                      if (tab.showNtp) const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _TabCountButton(count: tabCount, colors: colors, onTap: onOpenTabs),
          IconButton(
            tooltip: 'More options',
            onPressed: onOpenMenu,
            icon: Icon(Icons.more_vert_rounded, color: colors.foreground),
          ),
        ],
      ),
    );
  }
}

class _SecurityButton extends StatelessWidget {
  const _SecurityButton({required this.tab, required this.colors, required this.onTap});

  final BrowserTab tab;
  final ChromeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    Color color = colors.foreground;
    String tooltip;
    if (tab.showNtp) {
      icon = tab.incognito ? Icons.visibility_off_outlined : Icons.search_rounded;
      tooltip = 'Search';
    } else if (tab.error?.kind == PageErrorKind.ssl || tab.error?.kind == PageErrorKind.insecure) {
      icon = Icons.gpp_bad_outlined;
      color = Theme.of(context).colorScheme.error;
      tooltip = 'Not secure';
    } else if (tab.isSecure) {
      icon = Icons.lock_outline_rounded;
      tooltip = 'Connection is secure';
    } else if (UrlResolver.isWebUrl(tab.url)) {
      icon = Icons.no_encryption_gmailerrorred_outlined;
      color = Theme.of(context).colorScheme.error;
      tooltip = 'Not secure';
    } else {
      icon = Icons.info_outline_rounded;
      tooltip = 'Page info';
    }
    return IconButton(
      tooltip: tooltip,
      onPressed: tab.showNtp ? null : onTap,
      icon: Icon(icon, size: 19, color: color),
      disabledColor: colors.secondary,
    );
  }
}

class _ProxyChip extends StatelessWidget {
  const _ProxyChip({required this.status, required this.colors, required this.onTap});

  final ProxyStatus status;
  final ChromeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final failed =
        status.state == ProxyConnectionState.failed ||
        (status.blockingDirect &&
            status.state != ProxyConnectionState.connected &&
            status.state != ProxyConnectionState.connecting);
    final connecting = status.state == ProxyConnectionState.connecting;
    final error = Theme.of(context).colorScheme.error;
    final Color bg = failed ? error : (connecting ? colors.border : colors.accent);
    final Color fg = failed ? Colors.white : Colors.black;
    final label = failed
        ? (status.blockingDirect && status.state == ProxyConnectionState.disconnected ? 'Blocked' : 'Proxy error')
        : (connecting ? 'Connecting' : 'Proxy');
    return Semantics(
      button: true,
      label: 'Proxy status: $label',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (connecting)
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1.6, color: colors.foreground),
                )
              else
                Icon(failed ? Icons.error_outline_rounded : Icons.shield_outlined, size: 13, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: connecting ? colors.foreground : fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabCountButton extends StatelessWidget {
  const _TabCountButton({required this.count, required this.colors, required this.onTap});

  final int count;
  final ChromeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Tabs ($count open)',
      onPressed: onTap,
      icon: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: colors.foreground, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          count > 99 ? ':D' : '$count',
          style: TextStyle(fontSize: count > 9 ? 10.5 : 12.5, fontWeight: FontWeight.w800, color: colors.foreground),
        ),
      ),
    );
  }
}
