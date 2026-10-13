import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/url_resolver.dart';
import '../../../shared/dialogs.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/host_favicon.dart';
import '../../bookmarks/bookmark.dart';
import '../../history/history_entry.dart';
import '../../shortcuts/shortcut_repository.dart';

class NtpData {
  const NtpData(this.shortcuts, this.topSites, this.bookmarks);

  final List<Shortcut> shortcuts;
  final List<TopSite> topSites;
  final List<Bookmark> bookmarks;
}

final ntpDataProvider = FutureProvider<NtpData>((ref) async {
  ref.watch(dataRevisionProvider);
  final results = await Future.wait([
    ref.read(shortcutRepositoryProvider).all(),
    ref.read(historyRepositoryProvider).topSites(limit: 8),
    ref.read(bookmarkRepositoryProvider).recent(limit: 8),
  ]);
  return NtpData(results[0] as List<Shortcut>, results[1] as List<TopSite>, results[2] as List<Bookmark>);
});

/// Local-only start page: shortcuts, most visited sites and bookmarks. No
/// feeds, suggestions or network requests.
class NewTabPage extends ConsumerWidget {
  const NewTabPage({
    super.key,
    required this.private,
    required this.onSearch,
    required this.onOpen,
    required this.isolationSupported,
  });

  final bool private;
  final VoidCallback onSearch;
  final void Function(String url) onOpen;
  final bool isolationSupported;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (private) return _PrivateIntro(onSearch: onSearch, isolationSupported: isolationSupported);
    final data = ref.watch(ntpDataProvider);
    final palette = context.palette;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 8),
              child: Column(
                children: [
                  const BrandMark(size: 64),
                  const SizedBox(height: 14),
                  Text(
                    'Saif',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
                  ),
                  const SizedBox(height: 26),
                  _SearchField(onTap: onSearch, palette: palette),
                ],
              ),
            ),
          ),
          ...switch (data) {
            AsyncData(:final value) => _content(context, ref, value),
            AsyncError() => [const SliverToBoxAdapter(child: SizedBox.shrink())],
            _ => [const SliverToBoxAdapter(child: SizedBox(height: 120))],
          },
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context, WidgetRef ref, NtpData data) {
    final shortcutUrls = data.shortcuts.map((s) => UrlResolver.hostOf(s.url)).toSet();
    final tiles = <Widget>[
      for (final s in data.shortcuts)
        _Tile(
          title: s.title,
          url: s.url,
          onTap: () => onOpen(s.url),
          onLongPress: () => _editShortcut(context, ref, s),
        ),
      for (final site
          in data.topSites.where((t) => !shortcutUrls.contains(t.host)).take(8 - data.shortcuts.length.clamp(0, 8)))
        _Tile(title: site.title, url: site.url, onTap: () => onOpen(site.url)),
      _AddTile(onTap: () => _editShortcut(context, ref, null)),
    ];
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
        sliver: SliverGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 0.82,
          children: tiles,
        ),
      ),
      if (data.bookmarks.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
            child: Text(
              'Bookmarks',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: data.bookmarks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final b = data.bookmarks[i];
                return ActionChip(
                  avatar: HostFavicon(url: b.url ?? '', size: 18),
                  label: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(b.title, overflow: TextOverflow.ellipsis),
                  ),
                  onPressed: () => onOpen(b.url!),
                );
              },
            ),
          ),
        ),
      ],
    ];
  }

  Future<void> _editShortcut(BuildContext context, WidgetRef ref, Shortcut? existing) async {
    final result = await showDialog<_ShortcutResult>(
      context: context,
      builder: (_) => _ShortcutDialog(existing: existing),
    );
    if (result == null) return;
    final repo = ref.read(shortcutRepositoryProvider);
    if (result.delete && existing != null) {
      await repo.delete(existing.id);
    } else if (existing != null) {
      await repo.update(existing.id, result.title, result.url);
    } else {
      await repo.add(result.title, result.url);
    }
    ref.read(dataRevisionProvider.notifier).bump();
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap, required this.palette});

  final VoidCallback onTap;
  final BrowserPalette palette;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 18),
              const Icon(Icons.search_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Search or type web address', style: TextStyle(color: palette.textSecondary, fontSize: 16)),
              ),
              Container(
                margin: const EdgeInsets.all(6),
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
                child: Icon(Icons.arrow_forward_rounded, color: palette.onAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.url, required this.onTap, this.onLongPress});

  final String title;
  final String url;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(16)),
              child: HostFavicon(url: url, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.add_rounded, color: palette.onAccent, size: 28),
            ),
            const SizedBox(height: 8),
            const Text('Add shortcut', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5)),
          ],
        ),
      ),
    );
  }
}

class _ShortcutResult {
  const _ShortcutResult(this.title, this.url, {this.delete = false});

  final String title;
  final String url;
  final bool delete;
}

class _ShortcutDialog extends StatefulWidget {
  const _ShortcutDialog({this.existing});

  final Shortcut? existing;

  @override
  State<_ShortcutDialog> createState() => _ShortcutDialogState();
}

class _ShortcutDialogState extends State<_ShortcutDialog> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _url = TextEditingController(text: widget.existing?.url ?? '');
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    super.dispose();
  }

  void _save() {
    final url = UrlResolver.toUrl(_url.text);
    if (url == null) {
      setState(() => _error = 'Enter a valid web address');
      return;
    }
    final title = _title.text.trim().isEmpty ? (UrlResolver.hostOf(url) ?? url) : _title.text.trim();
    Navigator.pop(context, _ShortcutResult(title, url));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return AlertDialog(
      title: Text(editing ? 'Edit shortcut' : 'Add shortcut'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(labelText: 'URL', errorText: _error),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        if (editing)
          TextButton(
            onPressed: () async {
              final ok = await confirm(context, title: 'Remove shortcut?', confirmLabel: 'Remove', destructive: true);
              if (ok && context.mounted) Navigator.pop(context, const _ShortcutResult('', '', delete: true));
            },
            child: Text('Remove', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _PrivateIntro extends StatelessWidget {
  const _PrivateIntro({required this.onSearch, required this.isolationSupported});

  final VoidCallback onSearch;
  final bool isolationSupported;

  @override
  Widget build(BuildContext context) {
    const fg = Colors.white;
    const secondary = Color(0xFFBDC1C6);
    final accent = context.palette.accent;
    return ColoredBox(
      color: const Color(0xFF202124),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.centerLeft,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.visibility_off_rounded, size: 34, color: Colors.black),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Private tab',
            style: TextStyle(color: fg, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
          ),
          const SizedBox(height: 12),
          Text(
            isolationSupported
                ? 'Pages you open in private tabs are not saved to your history, and their cookies and site data '
                      'are kept separate from regular tabs and deleted when you close all private tabs. '
                      'Bookmarks you add and files you download are kept.'
                : 'Pages you open in private tabs are not saved to your history. Bookmarks you add and files '
                      'you download are kept.',
            style: const TextStyle(color: secondary, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 18),
          _bullet(
            isolationSupported
                ? 'Not saved: browsing history, cookies and site data, form input, passwords'
                : 'Not saved: browsing history, form input, passwords',
            fg,
          ),
          _bullet(
            'Your activity might still be visible to websites you visit, your employer or school, and your internet provider',
            fg,
          ),
          if (!isolationSupported) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF3C2A10), borderRadius: BorderRadius.circular(14)),
              child: const Text(
                'Your Android System WebView does not support separate browsing profiles, so private tabs share '
                'cookies and site storage with regular tabs on this device. History is still not saved. '
                'Update Android System WebView to enable full isolation.',
                style: TextStyle(color: Color(0xFFFFD08A), height: 1.45),
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded),
            label: const Text('Search privately'),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Icon(Icons.circle, size: 6, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: color, height: 1.45)),
        ),
      ],
    ),
  );
}
