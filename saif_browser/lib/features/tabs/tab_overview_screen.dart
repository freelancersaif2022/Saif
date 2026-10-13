import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/dialogs.dart';
import '../../shared/widgets/favicon_view.dart';
import 'browser_tab.dart';
import 'tabs_controller.dart';

/// Grid of open tabs with a regular/private switch. Long-press and drag a
/// card to reorder it.
class TabOverviewScreen extends ConsumerWidget {
  const TabOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tabsProvider);
    final controller = ref.read(tabsProvider.notifier);
    final private = state.privateMode;
    final tabs = state.visibleTabs;
    final dark = private;
    final bg = dark ? const Color(0xFF1C1D1F) : Theme.of(context).scaffoldBackgroundColor;
    final fg = dark ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Theme(
      data: dark ? Theme.of(context).copyWith(scaffoldBackgroundColor: bg) : Theme.of(context),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          foregroundColor: fg,
          title: SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, icon: const Icon(Icons.tab_outlined), label: Text('${state.regular.length}')),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.visibility_off_outlined),
                label: Text('${state.private.length}'),
              ),
            ],
            selected: {private},
            showSelectedIcon: false,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? Colors.black : fg,
              ),
            ),
            onSelectionChanged: (s) => controller.setPrivateMode(s.first),
          ),
          actions: [
            PopupMenuButton<String>(
              iconColor: fg,
              onSelected: (action) async {
                switch (action) {
                  case 'closeAll':
                    final ok = await confirm(
                      context,
                      title: private ? 'Close all private tabs?' : 'Close all tabs?',
                      confirmLabel: 'Close all',
                      destructive: true,
                    );
                    if (ok) {
                      await controller.closeAll(private: private);
                      if (context.mounted) Navigator.pop(context);
                    }
                  case 'reopen':
                    await controller.reopenClosed();
                    if (context.mounted) Navigator.pop(context);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'closeAll',
                  enabled: tabs.isNotEmpty,
                  child: Text(private ? 'Close all private tabs' : 'Close all tabs'),
                ),
                PopupMenuItem(
                  value: 'reopen',
                  enabled: state.recentlyClosed.isNotEmpty,
                  child: const Text('Reopen closed tab'),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            controller.newTab(incognito: private);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(private ? 'New private tab' : 'New tab'),
        ),
        body: tabs.isEmpty
            ? Center(
                child: Text(
                  private ? 'No private tabs' : 'No tabs',
                  style: TextStyle(color: fg.withValues(alpha: 0.7)),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: tabs.length,
                itemBuilder: (context, i) {
                  final tab = tabs[i];
                  final card = _TabCard(
                    tab: tab,
                    active: tab.id == state.activeId,
                    dark: dark,
                    onTap: () {
                      controller.switchTo(tab.id);
                      Navigator.pop(context);
                    },
                    onClose: () => controller.close(tab.id),
                    onDuplicate: () => controller.duplicate(tab.id),
                  );
                  return DragTarget<int>(
                    onWillAcceptWithDetails: (d) => d.data != i,
                    onAcceptWithDetails: (d) => controller.reorder(d.data, i, private: private),
                    builder: (context, candidates, _) => AnimatedScale(
                      scale: candidates.isEmpty ? 1 : 0.94,
                      duration: const Duration(milliseconds: 120),
                      child: LongPressDraggable<int>(
                        data: i,
                        feedback: SizedBox(
                          width: 160,
                          height: 220,
                          child: Material(
                            color: Colors.transparent,
                            child: Opacity(opacity: 0.9, child: card),
                          ),
                        ),
                        childWhenDragging: Opacity(opacity: 0.3, child: card),
                        child: card,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _TabCard extends StatelessWidget {
  const _TabCard({
    required this.tab,
    required this.active,
    required this.dark,
    required this.onTap,
    required this.onClose,
    required this.onDuplicate,
  });

  final BrowserTab tab;
  final bool active;
  final bool dark;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final surface = dark ? const Color(0xFF303134) : palette.surface;
    final fg = dark ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final thumbnail = tab.thumbnail;
    return Semantics(
      label: '${tab.displayTitle}${active ? ', current tab' : ''}',
      button: true,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: active ? palette.accent : Colors.transparent, width: 3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 0, 4),
                  child: Row(
                    children: [
                      FaviconView(bytes: tab.favicon, label: tab.displayTitle, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tab.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      PopupMenuButton<String>(
                        iconSize: 18,
                        iconColor: fg,
                        padding: EdgeInsets.zero,
                        tooltip: 'Tab options',
                        onSelected: (a) => a == 'duplicate' ? onDuplicate() : onClose(),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'duplicate', child: Text('Duplicate tab')),
                          PopupMenuItem(value: 'close', child: Text('Close tab')),
                        ],
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Close tab',
                        onPressed: onClose,
                        icon: Icon(Icons.close_rounded, size: 18, color: fg),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: dark ? const Color(0xFF202124) : Colors.white,
                    child: thumbnail != null && !tab.showNtp
                        ? Image.memory(
                            thumbnail,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            gaplessPlayback: true,
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaviconView(bytes: tab.favicon, label: tab.displayTitle, size: 40),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    tab.showNtp ? '' : UrlResolver.displayText(tab.url),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: fg.withValues(alpha: 0.6), fontSize: 11.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
