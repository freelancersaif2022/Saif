import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/url_resolver.dart';
import '../../shared/dialogs.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/host_favicon.dart';
import '../../shared/widgets/section_header.dart';
import 'history_entry.dart';

/// Browsing history grouped by day, with search and deletion. Pops with a
/// URL when the user opens an entry.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const _pageSize = 100;
  final List<HistoryEntry> _entries = [];
  final _scroll = ScrollController();
  String _query = '';
  bool _searching = false;
  bool _hasMore = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) _loadMore();
    });
    _reload();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    _entries.clear();
    _hasMore = true;
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    _loading = true;
    final query = _query;
    final page = await ref
        .read(historyRepositoryProvider)
        .page(query: query, limit: _pageSize, offset: _entries.length);
    _loading = false;
    if (!mounted || query != _query) return;
    setState(() {
      _entries.addAll(page);
      _hasMore = page.length == _pageSize;
    });
  }

  Future<void> _clear() async {
    final range = await showModalBottomSheet<Duration>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const _ClearHistorySheet(),
    );
    if (range == null) return;
    final since = range == Duration.zero ? null : DateTime.now().subtract(range);
    final removed = await ref.read(historyRepositoryProvider).clear(since: since);
    await ref.read(faviconRepositoryProvider).prune();
    ref.read(dataRevisionProvider.notifier).bump();
    await _reload();
    if (mounted) {
      showMessage(
        context,
        removed == 1 ? '1 page removed from history' : '$removed pages removed from history',
        icon: Icons.delete_sweep_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final items = <Widget>[];
    String? heading;
    for (final e in _entries) {
      final h = Formatters.dayHeading(e.visitedAt, now);
      if (h != heading) {
        heading = h;
        items.add(SectionHeader(h));
      }
      items.add(
        Dismissible(
          key: ValueKey(e.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Theme.of(context).colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) async {
            setState(() => _entries.remove(e));
            await ref.read(historyRepositoryProvider).delete(e.id);
            ref.read(dataRevisionProvider.notifier).bump();
          },
          child: ListTile(
            leading: HostFavicon(url: e.url, size: 26),
            title: Text(
              e.title.isEmpty ? UrlResolver.displayText(e.url) : e.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${Formatters.time(e.visitedAt)} · ${UrlResolver.hostOf(e.url) ?? e.url}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.palette.textSecondary),
            ),
            trailing: IconButton(
              tooltip: 'Delete entry',
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () async {
                setState(() => _entries.remove(e));
                await ref.read(historyRepositoryProvider).delete(e.id);
                ref.read(dataRevisionProvider.notifier).bump();
              },
            ),
            onTap: () => Navigator.pop(context, e.url),
          ),
        ),
      );
    }
    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() {
          _searching = false;
          _query = '';
        });
        _reload();
      },
      child: Scaffold(
        appBar: AppBar(
          title: _searching
              ? TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search history',
                    border: InputBorder.none,
                    filled: false,
                  ),
                  onChanged: (v) {
                    _query = v;
                    _reload();
                  },
                )
              : const Text('History'),
          actions: [
            if (!_searching)
              IconButton(
                tooltip: 'Search',
                onPressed: () => setState(() => _searching = true),
                icon: const Icon(Icons.search_rounded),
              ),
            IconButton(
              tooltip: 'Clear browsing history',
              onPressed: _clear,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ],
        ),
        body: _entries.isEmpty && !_loading
            ? EmptyState(
                icon: Icons.history_rounded,
                title: _query.isEmpty ? 'No history yet' : 'No matching pages',
                message: _query.isEmpty
                    ? 'Pages you visit in regular tabs appear here. Private tabs are never recorded.'
                    : null,
              )
            : ListView(controller: _scroll, children: items),
      ),
    );
  }
}

class _ClearHistorySheet extends StatefulWidget {
  const _ClearHistorySheet();

  @override
  State<_ClearHistorySheet> createState() => _ClearHistorySheetState();
}

class _ClearHistorySheetState extends State<_ClearHistorySheet> {
  static const _ranges = [
    ('Last hour', Duration(hours: 1), Icons.schedule_rounded),
    ('Last 24 hours', Duration(days: 1), Icons.today_rounded),
    ('Last 7 days', Duration(days: 7), Icons.date_range_rounded),
    ('Last 4 weeks', Duration(days: 28), Icons.calendar_month_rounded),
    ('All time', Duration.zero, Icons.all_inclusive_rounded),
  ];

  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final error = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.delete_sweep_rounded, color: error),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clear browsing history',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text('Choose a time range', style: TextStyle(color: palette.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < _ranges.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: i == _selected ? palette.accent.withValues(alpha: 0.22) : palette.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: i == _selected ? palette.accent : Colors.transparent, width: 1.6),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _selected = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    child: Row(
                      children: [
                        Icon(_ranges[i].$3, size: 22),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _ranges[i].$1,
                            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(
                          i == _selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                          color: i == _selected ? Theme.of(context).colorScheme.onSurface : palette.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Only the history list is cleared. Cookies and saved passwords are kept '
            '(use Settings → Clear browsing data for those).',
            style: TextStyle(color: palette.textSecondary, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: error,
                    foregroundColor: Colors.white,
                    iconColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, _ranges[_selected].$2),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
