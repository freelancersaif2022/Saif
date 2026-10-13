import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../downloads/downloads_controller.dart';
import '../../tabs/browser_tab.dart';
import '../../tabs/tabs_controller.dart';
import 'chrome_colors.dart';

/// Back, forward, home, bookmark and downloads controls.
class BottomToolbar extends ConsumerWidget {
  const BottomToolbar({
    super.key,
    required this.tab,
    required this.bookmarked,
    required this.onToggleBookmark,
    required this.onOpenDownloads,
  });

  final BrowserTab tab;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onOpenDownloads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ChromeColors.of(context, private: tab.incognito);
    final tabs = ref.read(tabsProvider.notifier);
    final activeDownloads = ref.watch(downloadsProvider.select((list) => list.where((d) => d.isActive).length));
    final canGoForward = tab.canGoForward || (tab.showNtp && tab.nativeCreated && !tab.url.startsWith('about:'));
    final canGoBack = !tab.showNtp && (tab.canGoBack || tab.hasNtpEntry || tab.parentId != null);

    Widget button(IconData icon, String tooltip, VoidCallback? onPressed, {Color? color}) => Expanded(
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed == null ? colors.secondary.withValues(alpha: 0.45) : (color ?? colors.foreground),
        ),
        iconSize: 25,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.bar,
        border: Border(top: BorderSide(color: colors.border, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              button(Icons.arrow_back_rounded, 'Back', canGoBack ? () => tabs.handleBack() : null),
              button(Icons.arrow_forward_rounded, 'Forward', canGoForward ? tabs.goForward : null),
              button(Icons.home_outlined, 'Home', tabs.goHome),
              button(
                bookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                bookmarked ? 'Edit bookmark' : 'Bookmark this page',
                tab.showNtp || tab.incognito ? null : onToggleBookmark,
              ),
              Expanded(
                child: IconButton(
                  tooltip: 'Downloads',
                  onPressed: onOpenDownloads,
                  icon: Badge(
                    isLabelVisible: activeDownloads > 0,
                    backgroundColor: colors.accent,
                    textColor: Colors.black,
                    label: Text('$activeDownloads'),
                    child: Icon(Icons.download_rounded, color: colors.foreground, size: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
